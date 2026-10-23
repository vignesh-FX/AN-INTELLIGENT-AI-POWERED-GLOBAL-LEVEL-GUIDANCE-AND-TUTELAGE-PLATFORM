from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from db import get_db
from models import Comment, Post, SavedPost, User, UserBlock, Community
from schemas import ProfileUpdate
from security import get_current_user, get_optional_user, rate_limit
from services import routing, search
from services.content import iso, serialize_posts, user_brief, _valid_uuid
from services.quality import expert_quality
from services.reputation import badge_list, evaluate_badges
from routes.auth import full_user

router = APIRouter(tags=["users"])

LEARNER_FIELDS = ("education", "institution", "work_status", "skills", "interests", "skill_level", "learning_goals", "help_topics")
EXPERT_FIELDS = ("title", "organization", "years_experience", "education", "expertise_areas", "skills", "projects",
                 "certifications", "biography", "mentoring_areas", "professional_interests")


@router.put("/me/profile")
def update_profile(data: ProfileUpdate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    sent = data.model_dump(exclude_unset=True)
    for k in ("name", "avatar_url", "languages"):
        if k in sent and (sent[k] is not None or k == "avatar_url"):
            setattr(user, k, sent[k])
    prof = user.learner_profile if user.user_type == "learner" else user.expert_profile
    fields = LEARNER_FIELDS if user.user_type == "learner" else EXPERT_FIELDS
    for k in fields:
        if k in sent and sent[k] is not None:
            setattr(prof, k, sent[k])
    if user.user_type == "expert":
        if not prof.expertise_areas:
            raise HTTPException(422, "An expert needs at least one area of expertise")
        routing.engine.invalidate()
        routing.route_open_questions_for_expert(db, user.id)
    db.commit()
    search.index.invalidate()
    return full_user(db, user)


@router.get("/users/{username}")
def public_profile(username: str, viewer: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    u = db.scalar(select(User).where(func.lower(User.username) == username.lower(), User.is_active.is_(True)))
    if not u:
        raise HTTPException(404, "User not found")
    badges = badge_list(evaluate_badges(db, u))
    db.commit()
    out = {**user_brief(u), "languages": u.languages or [], "created_at": iso(u.created_at), "badges": badges,
           "is_me": bool(viewer and viewer.id == u.id),
           "is_blocked": bool(viewer and db.get(UserBlock, (viewer.id, u.id))),
           "stats": {
               "posts": db.scalar(select(func.count()).select_from(Post).where(Post.author_id == u.id, Post.is_removed.is_(False))),
               "comments": db.scalar(select(func.count()).select_from(Comment).where(
                   Comment.author_id == u.id, Comment.is_deleted.is_(False), Comment.is_removed.is_(False))),
           }}
    if u.user_type == "expert" and u.expert_profile:
        p = u.expert_profile
        out["profile"] = {k: getattr(p, k) for k in EXPERT_FIELDS}
        out["quality"] = expert_quality(db, u.id)
    elif u.learner_profile:
        p = u.learner_profile
        out["profile"] = {k: getattr(p, k) for k in ("education", "institution", "skills", "interests", "skill_level",
                                                      "learning_goals", "help_topics")}
    recent = db.scalars(select(Post).where(Post.author_id == u.id, Post.is_removed.is_(False)).order_by(Post.created_at.desc()).limit(10)).all()
    visible = [p for p in recent if not p.community.is_private]
    out["recent_posts"] = serialize_posts(db, visible, viewer)
    return out


@router.post("/users/{user_id}/block", status_code=204, dependencies=[Depends(rate_limit("block", 30, 60))])
def block(user_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not _valid_uuid(user_id) or not db.get(User, user_id):
        raise HTTPException(404, "User not found")
    if user_id == user.id:
        raise HTTPException(400, "You can't block yourself")
    if not db.get(UserBlock, (user.id, user_id)):
        db.add(UserBlock(blocker_id=user.id, blocked_id=user_id)); db.commit()


@router.delete("/users/{user_id}/block", status_code=204)
def unblock(user_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    b = db.get(UserBlock, (user.id, user_id)) if _valid_uuid(user_id) else None
    if b:
        db.delete(b); db.commit()


@router.get("/me/questions")
def my_questions(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    posts = db.scalars(select(Post).where(Post.author_id == user.id, Post.post_type.in_(("question", "help_request")),
                                          Post.is_removed.is_(False)).order_by(Post.created_at.desc()).limit(100)).all()
    return serialize_posts(db, posts, user)


@router.get("/me/answers")
def my_answers(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Answers and replies the user has written, newest first, with the post they belong to."""
    rows = db.execute(select(Comment, Post).join(Post, Post.id == Comment.post_id).where(
        Comment.author_id == user.id, Comment.is_deleted.is_(False), Comment.is_removed.is_(False), Post.is_removed.is_(False)
    ).order_by(Comment.created_at.desc()).limit(100)).all()
    from services.content import vote_info
    from sqlalchemy import select as sel
    from models import AnswerRating
    ids = [c.id for c, _ in rows]
    votes = vote_info(db, "comment", ids, user.id)
    ratings = {cid: (float(a), n) for cid, a, n in db.execute(
        sel(AnswerRating.comment_id, func.avg(AnswerRating.rating), func.count()).where(AnswerRating.comment_id.in_(ids))
        .group_by(AnswerRating.comment_id))} if ids else {}
    return [{"id": c.id, "body": c.body, "is_answer": c.is_answer, "is_accepted": c.is_accepted,
             "created_at": iso(c.created_at), "score": votes[c.id][0],
             "rating": {"average": round(ratings[c.id][0], 2), "count": ratings[c.id][1]} if c.id in ratings else None,
             "post": {"id": p.id, "title": p.title, "community": p.community.name}} for c, p in rows]


@router.get("/me/saved")
def saved(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    posts = db.scalars(select(Post).join(SavedPost, SavedPost.post_id == Post.id).where(
        SavedPost.user_id == user.id, Post.is_removed.is_(False)).order_by(SavedPost.created_at.desc()).limit(100)).all()
    return serialize_posts(db, posts, user)
