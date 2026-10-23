from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from db import get_db
from models import Community, CommunityMember, Post, QuestionRelevance, User
from schemas import RelevanceStatusIn
from security import get_current_user, get_optional_user, require_expert
from services import routing
from services.content import _valid_uuid, comment_counts, serialize_posts
from services.feed_rank import rank_posts

router = APIRouter(prefix="/feed", tags=["feed"])
PAGE = 20


@router.get("/expert")
def expert_feed(status: str = Query("new", pattern="^(new|saved|ignored|answered|all)$"), page: int = Query(1, ge=1),
                user: User = Depends(require_expert), db: Session = Depends(get_db)):
    """“Questions For Your Expertise” — rows written by the routing engine, re-ranked with the final feed score."""
    stmt = select(QuestionRelevance, Post).join(Post, Post.id == QuestionRelevance.post_id).where(
        QuestionRelevance.expert_id == user.id, Post.is_removed.is_(False))
    if status == "new":
        stmt = stmt.where(QuestionRelevance.status == "new")
    elif status != "all":
        stmt = stmt.where(QuestionRelevance.status == status)
    rows = db.execute(stmt.order_by(Post.created_at.desc()).limit(300)).all()
    counts = comment_counts(db, [p.id for _, p in rows])
    scored = []
    for rel, post in rows:
        fs = routing.final_feed_score(rel, post.created_at, counts[post.id][0])
        scored.append((fs["score"], rel, post, fs))
    scored.sort(key=lambda x: x[0], reverse=True)
    start = (page - 1) * PAGE
    window = scored[start:start + PAGE]
    items = serialize_posts(db, [p for _, _, p, _ in window], user)
    for item, (score, rel, _, fs) in zip(items, window):
        item["match"] = {"percent": round(score * 100), "similarity_percent": round(rel.similarity * 100),
                         "components": fs["components"], "matched_terms": rel.matched_terms or [], "status": rel.status}
    return {"items": items, "has_more": len(scored) > start + PAGE,
            "counts": {s: db.query(QuestionRelevance).join(Post, Post.id == QuestionRelevance.post_id).filter(
                QuestionRelevance.expert_id == user.id, QuestionRelevance.status == s, Post.is_removed.is_(False)).count()
                for s in ("new", "saved", "ignored", "answered")}}


@router.post("/expert/{post_id}/status", status_code=204)
def set_status(post_id: str, data: RelevanceStatusIn, user: User = Depends(require_expert), db: Session = Depends(get_db)):
    rel = db.get(QuestionRelevance, (post_id, user.id)) if _valid_uuid(post_id) else None
    if not rel:
        raise HTTPException(404, "This question isn't in your feed")
    if rel.status == "answered":
        raise HTTPException(400, "You already answered this question")
    rel.status = data.status
    db.commit()


@router.get("/home")
def home_feed(sort: str = Query("hot", pattern="^(hot|new|top)$"), page: int = Query(1, ge=1),
              user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Posts from the communities the user belongs to; falls back to public trending if they haven't joined any."""
    joined = [r[0] for r in db.execute(select(CommunityMember.community_id).where(
        CommunityMember.user_id == user.id, CommunityMember.status == "active"))]
    stmt = select(Post).where(Post.is_removed.is_(False))
    stmt = stmt.where(Post.community_id.in_(joined)) if joined else stmt.join(Community, Community.id == Post.community_id).where(Community.is_private.is_(False))
    posts = db.scalars(stmt.order_by(Post.created_at.desc()).limit(300)).all()
    ranked = rank_posts(db, posts, sort)
    start = (page - 1) * PAGE
    return {"items": serialize_posts(db, ranked[start:start + PAGE], user), "has_more": len(ranked) > start + PAGE,
            "joined_any": bool(joined)}


@router.get("/trending")
def trending(user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    since = datetime.now(timezone.utc) - timedelta(days=7)
    posts = db.scalars(select(Post).join(Community, Community.id == Post.community_id).where(
        Post.is_removed.is_(False), Community.is_private.is_(False), Post.created_at > since)
        .order_by(Post.created_at.desc()).limit(200)).all()
    return serialize_posts(db, rank_posts(db, posts, "hot")[:8], user)
