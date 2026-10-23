"""Ranking for post lists: hot (votes + comments, time-decayed), new, top."""
import math
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from models import Post
from services.content import comment_counts, vote_info


def _age_hours(dt: datetime) -> float:
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return max(0.0, (datetime.now(timezone.utc) - dt).total_seconds() / 3600)


def hot_score(score: int, comments: int, created_at: datetime) -> float:
    """Reddit/HN-style: engagement raised to <1 power, divided by a gravity term on age."""
    engagement = max(0, score) + 0.7 * comments + 1
    return engagement / math.pow(_age_hours(created_at) + 2, 1.5)


def rank_posts(db: Session, posts: list[Post], sort: str, pin_first: bool = False) -> list[Post]:
    ids = [p.id for p in posts]
    votes = vote_info(db, "post", ids, None)
    counts = comment_counts(db, ids)
    if sort == "new":
        key = lambda p: p.created_at.replace(tzinfo=timezone.utc) if p.created_at.tzinfo is None else p.created_at
    elif sort == "top":
        key = lambda p: (votes[p.id][0], counts[p.id][0])
    else:
        key = lambda p: hot_score(votes[p.id][0], counts[p.id][0], p.created_at)
    ranked = sorted(posts, key=key, reverse=True)
    if pin_first:
        ranked.sort(key=lambda p: not p.is_pinned)       # stable: pinned float to the top, order otherwise kept
    return ranked
