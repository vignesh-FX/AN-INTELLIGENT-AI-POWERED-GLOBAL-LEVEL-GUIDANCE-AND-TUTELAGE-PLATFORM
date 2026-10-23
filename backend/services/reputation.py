"""Reputation events (idempotent, auditable) and behaviour-based badges."""
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from models import (
    AnswerRating, Comment, Post, PostTag, Tag, User, UserBadge, ReputationEvent, HelpfulVote, Vote,
)
from services.quality import expert_stats

POINTS = {
    "post_upvote": 2, "post_downvote": -1, "comment_upvote": 2, "comment_downvote": -1,
    "answer_accepted": 15, "answer_helpful": 2, "answer_rating_high": 3, "answer_rating_low": -1,
}


def set_event(db: Session, user_id: str, ref_key: str, kind: str, points: int) -> None:
    """Create/update/remove the single reputation event identified by ref_key, then refresh the cached total.
    Because every source action owns one ref_key, repeating or reverting it can never double-count."""
    ev = db.scalar(select(ReputationEvent).where(ReputationEvent.ref_key == ref_key))
    if points == 0:
        if ev:
            db.delete(ev)
    elif ev:
        ev.kind, ev.points = kind, points
    else:
        db.add(ReputationEvent(user_id=user_id, ref_key=ref_key, kind=kind, points=points))
    db.flush()
    total = db.scalar(select(func.coalesce(func.sum(ReputationEvent.points), 0)).where(ReputationEvent.user_id == user_id))
    user = db.get(User, user_id)
    if user:
        user.reputation = max(0, int(total or 0))


# ── badges ───────────────────────────────────────────────────────────────────────
TOPIC_BADGES = {
    "ai_contributor": ("AI Contributor", {"ai", "ml", "machine", "learning", "dl", "llm", "neural_network", "deep"}),
    "python_expert": ("Python Expert", {"python"}),
    "nlp_expert": ("NLP Expert", {"nlp", "rag", "transformer", "embedding", "llm"}),
}
BADGE_LABELS = {
    "top_answerer": "Top Answerer", "highly_helpful": "Highly Helpful Expert",
    "community_contributor": "Community Contributor",
    **{k: v[0] for k, v in TOPIC_BADGES.items()},
}


def _topic_counts(db: Session, user: User) -> dict[str, int]:
    """Contributions (posts + answers/comments) grouped by tag on the post they relate to."""
    from services.text import tokenize
    rows = db.execute(
        select(Tag.name).select_from(Comment).join(PostTag, PostTag.post_id == Comment.post_id)
        .join(Tag, Tag.id == PostTag.tag_id)
        .where(Comment.author_id == user.id, Comment.is_deleted.is_(False), Comment.is_removed.is_(False))
    ).all()
    own = db.execute(select(Tag.name).select_from(Post).join(PostTag, PostTag.post_id == Post.id)
                     .join(Tag, Tag.id == PostTag.tag_id).where(Post.author_id == user.id, Post.is_removed.is_(False))).all()
    counts = {key: 0 for key in TOPIC_BADGES}
    for (name,) in rows + own:
        toks = set(tokenize(name, bigrams=False))
        for key, (_, terms) in TOPIC_BADGES.items():
            if toks & terms:
                counts[key] += 1
    return counts


def evaluate_badges(db: Session, user: User) -> list[str]:
    """Award badges strictly from recorded behaviour. Returns the full set of badge keys the user holds."""
    earned: set[str] = set()
    topics = _topic_counts(db, user)
    for key, n in topics.items():
        if n >= 3:
            earned.add(key)
    n_contrib = (db.scalar(select(func.count()).select_from(Comment).where(
        Comment.author_id == user.id, Comment.is_deleted.is_(False), Comment.is_removed.is_(False))) or 0) + \
        (db.scalar(select(func.count()).select_from(Post).where(Post.author_id == user.id, Post.is_removed.is_(False))) or 0)
    n_comm = db.scalar(select(func.count(func.distinct(Post.community_id))).select_from(Comment).join(
        Post, Post.id == Comment.post_id).where(Comment.author_id == user.id)) or 0
    if n_contrib >= 10 and n_comm >= 2:
        earned.add("community_contributor")
    if user.user_type == "expert":
        s = expert_stats(db, user.id)
        if s.answers >= 10:
            earned.add("top_answerer")
        if s.rating_count >= 10 and s.rating_sum / s.rating_count >= 4.5 and \
                s.helpful_voters and s.helpful / s.helpful_voters >= 0.85:
            earned.add("highly_helpful")
    have = {b for (b,) in db.execute(select(UserBadge.badge_key).where(UserBadge.user_id == user.id)).all()}
    for key in earned - have:
        db.add(UserBadge(user_id=user.id, badge_key=key))
    for key in have - earned:      # badges must reflect current behaviour
        db.query(UserBadge).filter(UserBadge.user_id == user.id, UserBadge.badge_key == key).delete()
    db.flush()
    return sorted(earned)


def badge_list(keys: list[str]) -> list[dict]:
    return [{"key": k, "label": BADGE_LABELS.get(k, k)} for k in keys]
