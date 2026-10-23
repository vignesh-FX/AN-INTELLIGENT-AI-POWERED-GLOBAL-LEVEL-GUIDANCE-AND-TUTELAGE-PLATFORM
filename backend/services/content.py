"""Shared read-side helpers: aggregates (votes, reactions, ratings), permissions and serializers.
Aggregates are computed from the source rows on every read, so counts can never drift from the database."""
import math
from collections import defaultdict
from datetime import datetime
from typing import Iterable, Optional

from fastapi import HTTPException
from sqlalchemy import case, func, select
from sqlalchemy.orm import Session

from models import (
    AnswerRating, Comment, Community, CommunityBan, CommunityMember, HelpfulVote, Post, Reaction,
    SavedPost, User, UserBlock, Vote,
)
from services.quality import bayesian_rating, expert_quality, feedback_counts, global_rating_mean
from config import settings

REACTIONS = ["👍", "❤️", "🎉", "💡", "🤔", "🙏"]


def iso(dt: Optional[datetime]) -> Optional[str]:
    if not dt:
        return None
    if dt.tzinfo is None:
        from datetime import timezone
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.isoformat()


# ── permissions ──────────────────────────────────────────────────────────────────
def membership(db: Session, community_id: str, user_id: Optional[str]) -> Optional[CommunityMember]:
    if not user_id:
        return None
    return db.get(CommunityMember, (community_id, user_id))


def is_active_member(m: Optional[CommunityMember]) -> bool:
    return bool(m and m.status == "active")


def is_moderator(m: Optional[CommunityMember]) -> bool:
    return bool(m and m.status == "active" and m.role in ("moderator", "owner"))


def is_banned(db: Session, community_id: str, user_id: str) -> bool:
    return db.get(CommunityBan, (community_id, user_id)) is not None


def assert_can_view(db: Session, community: Community, user: Optional[User]) -> None:
    if community.is_private and not is_active_member(membership(db, community.id, user.id if user else None)):
        raise HTTPException(404, "Community not found")      # don't reveal that it exists


def assert_can_interact(db: Session, community: Community, user: User) -> None:
    """Commenting/voting: public → any signed-in, non-banned user; private → members only."""
    if is_banned(db, community.id, user.id):
        raise HTTPException(403, "You are banned from this community")
    assert_can_view(db, community, user)


def get_post_or_404(db: Session, post_id: str, user: Optional[User], include_removed: bool = False) -> Post:
    post = db.get(Post, post_id) if _valid_uuid(post_id) else None
    if not post or (post.is_removed and not include_removed):
        raise HTTPException(404, "Post not found")
    assert_can_view(db, post.community, user)
    return post


def _valid_uuid(v: str) -> bool:
    import uuid
    try:
        uuid.UUID(str(v)); return True
    except ValueError:
        return False


# ── aggregates ───────────────────────────────────────────────────────────────────
def vote_info(db: Session, target_type: str, ids: list[str], viewer_id: Optional[str]) -> dict[str, tuple[int, int]]:
    out = {i: (0, 0) for i in ids}
    if not ids:
        return out
    for tid, total in db.execute(select(Vote.target_id, func.sum(Vote.value)).where(
            Vote.target_type == target_type, Vote.target_id.in_(ids)).group_by(Vote.target_id)):
        out[tid] = (int(total), 0)
    if viewer_id:
        for tid, v in db.execute(select(Vote.target_id, Vote.value).where(
                Vote.target_type == target_type, Vote.target_id.in_(ids), Vote.user_id == viewer_id)):
            out[tid] = (out[tid][0], int(v))
    return out


def reaction_info(db: Session, target_type: str, ids: list[str], viewer_id: Optional[str]) -> dict[str, tuple[dict, list]]:
    counts: dict[str, dict] = defaultdict(dict)
    mine: dict[str, list] = defaultdict(list)
    if ids:
        for tid, emoji, n in db.execute(select(Reaction.target_id, Reaction.emoji, func.count()).where(
                Reaction.target_type == target_type, Reaction.target_id.in_(ids)).group_by(Reaction.target_id, Reaction.emoji)):
            counts[tid][emoji] = n
        if viewer_id:
            for tid, emoji in db.execute(select(Reaction.target_id, Reaction.emoji).where(
                    Reaction.target_type == target_type, Reaction.target_id.in_(ids), Reaction.user_id == viewer_id)):
                mine[tid].append(emoji)
    return {i: (counts.get(i, {}), mine.get(i, [])) for i in ids}


def comment_counts(db: Session, post_ids: list[str]) -> dict[str, tuple[int, int]]:
    """post_id → (visible comment count, answer count)."""
    out = {i: (0, 0) for i in post_ids}
    if post_ids:
        for pid, total, answers in db.execute(select(
                Comment.post_id, func.count(), func.sum(case((Comment.is_answer.is_(True), 1), else_=0))).where(
                Comment.post_id.in_(post_ids), Comment.is_deleted.is_(False), Comment.is_removed.is_(False)
                ).group_by(Comment.post_id)):
            out[pid] = (int(total), int(answers or 0))
    return out



def saved_ids(db: Session, viewer_id: Optional[str], post_ids: list[str]) -> set:
    if not viewer_id or not post_ids:
        return set()
    return {r[0] for r in db.execute(select(SavedPost.post_id).where(
        SavedPost.user_id == viewer_id, SavedPost.post_id.in_(post_ids)))}


def blocked_ids(db: Session, viewer_id: Optional[str]) -> set:
    if not viewer_id:
        return set()
    return {r[0] for r in db.execute(select(UserBlock.blocked_id).where(UserBlock.blocker_id == viewer_id))}


# ── serializers ──────────────────────────────────────────────────────────────────
def user_brief(u: User, extra: Optional[dict] = None) -> dict:
    d = {"id": u.id, "username": u.username, "name": u.name, "avatar_url": u.avatar_url,
         "user_type": u.user_type, "reputation": u.reputation}
    if u.user_type == "expert" and u.expert_profile:
        d["title"] = u.expert_profile.title
    if extra:
        d.update(extra)
    return d


def community_brief(c: Community) -> dict:
    return {"id": c.id, "slug": c.slug, "name": c.name, "is_private": c.is_private, "avatar_url": c.avatar_url}


def serialize_posts(db: Session, posts: Iterable[Post], viewer: Optional[User]) -> list[dict]:
    posts = list(posts)
    ids = [p.id for p in posts]
    vid = viewer.id if viewer else None
    votes = vote_info(db, "post", ids, vid)
    reacts = reaction_info(db, "post", ids, vid)
    counts = comment_counts(db, ids)
    saved = saved_ids(db, vid, ids)
    out = []
    for p in posts:
        score, mine = votes[p.id]
        rc, rm = reacts[p.id]
        total, answers = counts[p.id]
        out.append({
            "id": p.id, "post_type": p.post_type, "title": p.title, "body": p.body, "field": p.field,
            "skill_level": p.skill_level, "resource_kind": p.resource_kind, "status": p.status,
            "is_pinned": p.is_pinned, "tags": sorted(t.name for t in p.tags),
            "attachments": [{"id": a.id, "kind": a.kind, "url": a.url, "name": a.name, "mime": a.mime, "size": a.size}
                            for a in p.attachments],
            "community": community_brief(p.community), "author": user_brief(p.author),
            "created_at": iso(p.created_at), "updated_at": iso(p.updated_at), "last_activity_at": iso(p.last_activity_at),
            "score": score, "my_vote": mine, "comment_count": total, "answer_count": answers,
            "reactions": rc, "my_reactions": rm, "saved": p.id in saved,
        })
    return out


def _answer_rank(avg_rating: float, n: int, helpful_pos: int, helpful_tot: int, score: int, mean: float) -> float:
    """Ranking signal for the "Best" sort: Bayesian rating + helpfulness + votes, so tiny samples don't dominate."""
    bayes = bayesian_rating(avg_rating * n, n, mean, settings.quality_prior_count)
    helpful = (helpful_pos + 3) / (helpful_tot + 4)
    return bayes / 5 * 0.6 + helpful * 0.25 + (1 / (1 + math.exp(-score / 4))) * 0.15


def build_thread(db: Session, post: Post, viewer: Optional[User], sort: str = "best") -> list[dict]:
    """Return the comment tree (nested `children`) with every field the UI needs."""
    rows = list(db.scalars(select(Comment).where(Comment.post_id == post.id).order_by(Comment.created_at)))
    ids = [c.id for c in rows]
    vid = viewer.id if viewer else None
    votes = vote_info(db, "comment", ids, vid)
    reacts = reaction_info(db, "comment", ids, vid)
    blocked = blocked_ids(db, vid)
    answer_ids = [c.id for c in rows if c.is_answer]
    fb = feedback_counts(db, answer_ids)
    rating_rows = defaultdict(list)
    mine_rating, mine_helpful = {}, set()
    if answer_ids:
        for cid, rater, r in db.execute(select(AnswerRating.comment_id, AnswerRating.rater_id, AnswerRating.rating)
                                        .where(AnswerRating.comment_id.in_(answer_ids))):
            rating_rows[cid].append(r)
            if rater == vid:
                mine_rating[cid] = r
        if vid:
            mine_helpful = {r[0] for r in db.execute(select(HelpfulVote.comment_id).where(
                HelpfulVote.user_id == vid, HelpfulVote.comment_id.in_(answer_ids)))}
        helpful_counts = dict(db.execute(select(HelpfulVote.comment_id, func.count()).where(
            HelpfulVote.comment_id.in_(answer_ids)).group_by(HelpfulVote.comment_id)).all())
    else:
        helpful_counts = {}
    mean = global_rating_mean(db) if answer_ids else settings.quality_default_mean
    experts = {c.author_id for c in rows if c.is_answer}
    quality = {e: expert_quality(db, e) for e in experts}

    nodes: dict[str, dict] = {}
    for c in rows:
        score, my_vote = votes[c.id]
        rc, rm = reacts[c.id]
        hidden = c.is_deleted or c.is_removed
        node = {
            "id": c.id, "post_id": c.post_id, "parent_id": c.parent_id,
            "author": None if c.is_deleted else user_brief(c.author),
            "body": "[deleted]" if c.is_deleted else "[removed by a moderator]" if c.is_removed else c.body,
            "is_answer": c.is_answer, "is_accepted": c.is_accepted, "is_deleted": c.is_deleted,
            "is_removed": c.is_removed, "created_at": iso(c.created_at), "edited_at": iso(c.edited_at),
            "score": 0 if hidden else score, "my_vote": my_vote, "reactions": {} if hidden else rc, "my_reactions": rm,
            "blocked": c.author_id in blocked, "children": [], "reply_count": 0,
        }
        if c.is_answer and not hidden:
            rs = rating_rows.get(c.id, [])
            pos, tot = fb.get(c.id, (0, 0))
            avg = sum(rs) / len(rs) if rs else 0
            node["rating"] = {"average": round(avg, 2) if rs else None, "count": len(rs), "mine": mine_rating.get(c.id)}
            node["helpful"] = {"count": helpful_counts.get(c.id, 0), "percent": round(100 * pos / tot) if tot else None,
                               "mine": c.id in mine_helpful}
            node["_rank"] = _answer_rank(avg, len(rs), pos, tot, score, mean)
            q = quality.get(c.author_id)
            if q and node["author"]:
                node["author"]["quality_score"] = q["score"]
                node["author"]["answers"] = q["answers"]
        nodes[c.id] = node
    roots: list[dict] = []
    for c in rows:
        n = nodes[c.id]
        parent = nodes.get(c.parent_id) if c.parent_id else None
        (parent["children"] if parent else roots).append(n)

    def tally(n) -> int:        # total descendants
        n["reply_count"] = sum(1 + tally(ch) for ch in n["children"])
        return n["reply_count"]
    for r in roots:
        tally(r)

    def key(n):
        if sort == "newest":
            return n["created_at"]
        if sort == "active":
            return (n["reply_count"], n["score"], n["created_at"])
        return (n["is_accepted"], n.get("_rank", 0), n["score"], n["reply_count"])     # best
    def order(items, top: bool):
        items.sort(key=key, reverse=True)
        if sort == "newest" and not top:       # replies read naturally oldest → newest
            items.sort(key=lambda n: n["created_at"])
        for it in items:
            order(it["children"], False)
    order(roots, True)
    # mark the best answer (top ranked non-accepted answer with any positive signal)
    answers = [n for n in nodes.values() if n["is_answer"] and not (n["is_deleted"] or n["is_removed"])]
    if answers:
        top = max(answers, key=lambda n: (n.get("_rank", 0), n["score"]))
        top["is_best"] = bool((top["rating"]["count"] or top["score"] > 0 or (top["helpful"]["count"])) and not top["is_accepted"])
    for n in nodes.values():
        n.pop("_rank", None)
        n.setdefault("is_best", False)
    return roots
