"""
Keyword + TF-IDF/cosine search across questions, discussions, resources, communities, learners and experts.
This is lexical retrieval (classical IR), not semantic search. The index is rebuilt lazily (TTL or on write);
swap `SearchIndex.build/query` for sentence-embeddings + a vector DB later without touching the routes.
"""
import threading
import time
from dataclasses import dataclass, field
from typing import Optional

from sqlalchemy import select
from sqlalchemy.orm import Session

from models import Community, CommunityMember, ExpertProfile, LearnerProfile, Post, User
from services.text import tokenize
from services.tfidf import TfidfModel, Vector, cosine

TTL = 60


@dataclass
class Doc:
    kind: str          # question | discussion | resource | community | learner | expert
    id: str
    title: str
    tags: set
    vec: Vector = field(default_factory=dict)
    community_id: Optional[str] = None   # for privacy filtering
    private: bool = False


class SearchIndex:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._docs: list[Doc] = []
        self._model: Optional[TfidfModel] = None
        self._built = 0.0
        self._dirty = True

    def invalidate(self) -> None:
        self._dirty = True

    def build(self, db: Session) -> None:
        raw: list[tuple[Doc, str]] = []
        posts = db.execute(select(Post, Community.is_private).join(Community, Community.id == Post.community_id)
                           .where(Post.is_removed.is_(False))).all()
        for p, private in posts:
            kind = "question" if p.post_type == "question" else "resource" if p.post_type == "resource" else "discussion"
            tags = {t.name.lower() for t in p.tags}
            raw.append((Doc(kind, p.id, p.title, tags, community_id=p.community_id, private=private),
                        f"{p.title}\n{p.title}\n{p.body}\n{' '.join(tags)}\n{p.field or ''}"))
        for c in db.scalars(select(Community)):
            raw.append((Doc("community", c.id, c.name, set(), community_id=c.id, private=c.is_private),
                        f"{c.name}\n{c.name}\n{c.description}"))
        for u in db.scalars(select(User).where(User.is_active.is_(True))):
            text, kind = f"{u.name}\n{u.username}", u.user_type
            if u.user_type == "expert" and u.expert_profile:
                p = u.expert_profile
                text += "\n" + " ".join([p.title or "", " ".join(p.expertise_areas or []), " ".join(p.skills or []),
                                         " ".join(p.mentoring_areas or []), p.biography or ""])
            elif u.learner_profile:
                p = u.learner_profile
                text += "\n" + " ".join([" ".join(p.skills or []), " ".join(p.interests or []), p.learning_goals or ""])
            raw.append((Doc(kind, u.id, u.name, {u.username.lower()}), text))
        model = TfidfModel().fit([tokenize(t) for _, t in raw])
        for d, t in raw:
            d.vec = model.transform(tokenize(t))
        with self._lock:
            self._docs, self._model, self._built, self._dirty = [d for d, _ in raw], model, time.time(), False

    def query(self, db: Session, q: str, kinds: Optional[set], viewer_communities: set, limit: int = 30) -> list[tuple[Doc, float]]:
        if self._dirty or self._model is None or time.time() - self._built > TTL:
            self.build(db)
        qv = self._model.transform(tokenize(q))
        ql = q.lower().strip()
        out = []
        for d in self._docs:
            if kinds and d.kind not in kinds:
                continue
            if d.private and d.community_id not in viewer_communities:
                continue
            score = cosine(qv, d.vec)
            if ql and ql in d.title.lower():
                score += 0.35                       # exact phrase in title
            elif ql and ql in d.tags:
                score += 0.2
            if score > 0.04:
                out.append((d, score))
        out.sort(key=lambda x: x[1], reverse=True)
        return out[:limit]


index = SearchIndex()


def viewer_community_ids(db: Session, user_id: Optional[str]) -> set:
    if not user_id:
        return set()
    return {r[0] for r in db.execute(select(CommunityMember.community_id).where(
        CommunityMember.user_id == user_id, CommunityMember.status == "active")).all()}
