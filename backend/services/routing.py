"""
Question → Expert feed routing engine.

   Question (title + description + tags + field + community)
        → preprocessing → TF-IDF vector
        → cosine similarity against every expert's expertise vector
        → explainable component scores → ranked → stored in `question_relevance` (the experts' feeds)

The learner never sees the expert ranking; it is only used to decide whose feed receives the question.
"""
import math
import threading
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from config import settings
from models import (
    Comment, CommunityMember, ExpertProfile, Post, QuestionRelevance, Tag, PostTag, User,
)
from services.text import normalize_term, tokenize
from services.tfidf import TfidfModel, Vector, cosine, top_shared_terms


# ── documents ────────────────────────────────────────────────────────────────────
def question_document(title: str, body: str, tags: list[str], field: Optional[str], community_name: str = "") -> str:
    """Title and tags are repeated so they weigh more than free text."""
    parts = [title, title, body or "", " ".join(tags), " ".join(tags), field or "", field or "", community_name]
    return "\n".join(p for p in parts if p)


def expert_document(profile: ExpertProfile, answered_topics: list[str]) -> str:
    """Expert expertise text built from skills, expertise, title, experience, projects, certifications,
    mentoring areas, interests, communities and previous answer topics."""
    j = lambda xs: " ".join(xs or [])
    exp = f"{profile.years_experience} years experience" if profile.years_experience else ""
    parts = [
        j(profile.expertise_areas), j(profile.expertise_areas),
        j(profile.skills), j(profile.skills),
        j(profile.mentoring_areas), j(profile.mentoring_areas),
        profile.title or "", j(profile.projects), j(profile.certifications),
        j(profile.professional_interests), profile.biography or "", profile.education or "", exp,
        " ".join(answered_topics),
    ]
    return "\n".join(p for p in parts if p)


# ── model cache ──────────────────────────────────────────────────────────────────
@dataclass
class ExpertEntry:
    user_id: str
    vector: Vector
    expertise_terms: set          # stemmed unigrams from skills / expertise / mentoring / answered topics
    field_terms: set              # stemmed unigrams from title/expertise/mentoring (for field matching)


class RoutingEngine:
    """Holds the fitted TF-IDF model + expert vectors. Rebuilt when experts change or after a TTL."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._model: Optional[TfidfModel] = None
        self._experts: dict[str, ExpertEntry] = {}
        self._built_at = 0.0
        self._dirty = True

    def invalidate(self) -> None:
        self._dirty = True

    def _answered_topics(self, db: Session, expert_id: str) -> list[str]:
        rows = db.execute(
            select(Post.title, Tag.name)
            .select_from(Comment).join(Post, Post.id == Comment.post_id)
            .outerjoin(PostTag, PostTag.post_id == Post.id).outerjoin(Tag, Tag.id == PostTag.tag_id)
            .where(Comment.author_id == expert_id, Comment.is_answer.is_(True), Comment.is_deleted.is_(False))
            .order_by(Comment.created_at.desc()).limit(60)
        ).all()
        out, seen = [], set()
        for title, tag in rows:
            if tag and tag not in seen:
                seen.add(tag); out.append(tag)
            if title and title not in seen and len(out) < 40:
                seen.add(title); out.append(title)
        return out

    def build(self, db: Session) -> None:
        experts = db.execute(select(ExpertProfile, User).join(User, User.id == ExpertProfile.user_id)
                             .where(User.is_active.is_(True))).all()
        docs: dict[str, str] = {}
        extra: dict[str, tuple[set, set]] = {}
        for prof, user in experts:
            answered = self._answered_topics(db, user.id)
            docs[user.id] = expert_document(prof, answered)
            core = " ".join((prof.expertise_areas or []) + (prof.skills or []) + (prof.mentoring_areas or []) + answered)
            fld = " ".join((prof.expertise_areas or []) + (prof.mentoring_areas or []) + [prof.title or ""])
            extra[user.id] = (set(tokenize(core, bigrams=False)), set(tokenize(fld, bigrams=False)))

        # IDF is fitted on expert documents + recent questions: a broader corpus gives more stable term weights.
        recent_q = db.execute(select(Post.title, Post.body).where(Post.post_type == "question", Post.is_removed.is_(False))
                              .order_by(Post.created_at.desc()).limit(300)).all()
        corpus = [tokenize(d) for d in docs.values()] + [tokenize(f"{t}\n{b or ''}") for t, b in recent_q]
        model = TfidfModel().fit(corpus)
        entries = {
            uid: ExpertEntry(uid, model.transform(tokenize(doc)), *extra[uid]) for uid, doc in docs.items()
        }
        with self._lock:
            self._model, self._experts = model, entries
            self._built_at, self._dirty = time.time(), False

    def ensure(self, db: Session) -> None:
        if self._dirty or self._model is None or time.time() - self._built_at > settings.routing_model_ttl_seconds:
            self.build(db)

    # ── scoring ──────────────────────────────────────────────────────────────────
    def score_question(self, db: Session, post: Post, tag_names: list[str]) -> list[dict]:
        self.ensure(db)
        model = self._model
        community_name = post.community.name if post.community else ""
        q_tokens = tokenize(question_document(post.title, post.body, tag_names, post.field, community_name))
        q_vec = model.transform(q_tokens)
        if not q_vec:
            return []
        field_tokens = set(tokenize(post.field or "", bigrams=False))
        tag_tokens = [t for t in (normalize_term(x) for x in tag_names) if t]

        member_of = {r[0] for r in db.execute(select(CommunityMember.user_id).where(
            CommunityMember.community_id == post.community_id, CommunityMember.status == "active")).all()}
        answered_here = {r[0] for r in db.execute(
            select(Comment.author_id).join(Post, Post.id == Comment.post_id)
            .where(Post.community_id == post.community_id, Comment.is_answer.is_(True)).distinct()).all()}

        results = []
        for entry in self._experts.values():
            if entry.user_id == post.author_id:
                continue
            sim = cosine(q_vec, entry.vector)
            field_score = (len(field_tokens & (entry.field_terms | entry.expertise_terms)) / len(field_tokens)) if field_tokens else 0.0
            if tag_tokens:
                hit = sum(1 for t in tag_tokens if set(t.split("_")) & entry.expertise_terms)
                tag_score = hit / len(tag_tokens)
            else:
                tag_score = 0.0
            community_score = 1.0 if entry.user_id in member_of else (0.5 if entry.user_id in answered_here else 0.0)
            results.append({
                "expert_id": entry.user_id, "similarity": sim, "field_score": field_score,
                "tag_score": tag_score, "community_score": community_score,
                "matched_terms": top_shared_terms(q_vec, entry.vector, 6),
            })
        return results

    def route_question(self, db: Session, post: Post, tag_names: list[str]) -> list[QuestionRelevance]:
        """Score every expert, keep the top-K above the similarity threshold, persist them to their feeds."""
        scored = self.score_question(db, post, tag_names)
        eligible = [r for r in scored if r["similarity"] >= settings.routing_min_similarity]
        eligible.sort(key=lambda r: base_score(r), reverse=True)
        chosen = eligible[: settings.routing_top_k]
        prev = {r.expert_id: r for r in db.scalars(select(QuestionRelevance).where(QuestionRelevance.post_id == post.id))}
        old_status = {k: v.status for k, v in prev.items()}
        db.query(QuestionRelevance).filter(QuestionRelevance.post_id == post.id).delete()
        db.flush()
        keep = {r["expert_id"] for r in chosen} | {k for k, v in old_status.items() if v == "answered"}
        rows = []
        for r in scored:
            if r["expert_id"] not in keep:
                continue
            row = QuestionRelevance(post_id=post.id, status=old_status.get(r["expert_id"], "new"), **{k: r[k] for k in (
                "expert_id", "similarity", "field_score", "tag_score", "community_score", "matched_terms")})
            db.add(row)
            rows.append(row)
        db.flush()
        return rows


engine = RoutingEngine()


def route_open_questions_for_expert(db: Session, expert_id: str, days: int = 30, limit: int = 100) -> int:
    """When an expert joins or edits their expertise, let them see recent open questions that now fit.
    Saved / ignored / answered rows are kept; only still-'new' rows are recomputed."""
    from datetime import timedelta
    db.query(QuestionRelevance).filter(QuestionRelevance.expert_id == expert_id,
                                       QuestionRelevance.status == "new").delete()
    since = datetime.now(timezone.utc) - timedelta(days=days)
    qs = db.scalars(select(Post).where(Post.post_type == "question", Post.is_removed.is_(False),
                                       Post.created_at > since, Post.author_id != expert_id)
                    .order_by(Post.created_at.desc()).limit(limit)).all()
    kept = {r[0] for r in db.execute(select(QuestionRelevance.post_id).where(QuestionRelevance.expert_id == expert_id))}
    added = 0
    for post in qs:
        if post.id in kept:
            continue
        scored = engine.score_question(db, post, [t.name for t in post.tags])
        mine = next((r for r in scored if r["expert_id"] == expert_id), None)
        if not mine or mine["similarity"] < settings.routing_min_similarity:
            continue
        better = sum(1 for r in scored if r["similarity"] >= settings.routing_min_similarity and base_score(r) > base_score(mine))
        if better >= settings.routing_top_k:
            continue
        db.add(QuestionRelevance(post_id=post.id, **{k: mine[k] for k in (
            "expert_id", "similarity", "field_score", "tag_score", "community_score", "matched_terms")}))
        added += 1
    db.flush()
    return added


# ── final feed scoring (explainable, configurable) ───────────────────────────────
def _w() -> dict:
    return settings.feed_weights


def base_score(c: dict) -> float:
    """Static part of the feed score (similarity, field, tag, community) — used to pick recipients."""
    w = _w()
    num = (w["similarity"] * c["similarity"] + w["field"] * c["field_score"]
           + w["tag"] * c["tag_score"] + w["community"] * c["community_score"])
    return num / sum(w.values())


def recency_score(created_at: datetime) -> float:
    if created_at.tzinfo is None:
        created_at = created_at.replace(tzinfo=timezone.utc)
    age_h = max(0.0, (datetime.now(timezone.utc) - created_at).total_seconds() / 3600)
    return 0.5 ** (age_h / settings.recency_half_life_hours)


def activity_score(comment_count: int) -> float:
    return min(1.0, math.log1p(comment_count) / math.log1p(20))


def final_feed_score(rel: QuestionRelevance, created_at: datetime, comment_count: int) -> dict:
    """Final Question Feed Score = Σ weight·component / Σ weight. Returns the score and every component."""
    w = _w()
    comp = {
        "similarity": rel.similarity, "field": rel.field_score, "tag": rel.tag_score,
        "community": rel.community_score, "recency": recency_score(created_at),
        "activity": activity_score(comment_count),
    }
    total = sum(w[k] * comp[k] for k in comp) / sum(w.values())
    return {"score": round(total, 4), "components": {k: round(v, 4) for k, v in comp.items()}}
