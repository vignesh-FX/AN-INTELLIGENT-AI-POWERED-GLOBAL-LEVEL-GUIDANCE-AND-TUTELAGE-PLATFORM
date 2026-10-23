import re
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from config import settings
from db import get_db
from models import (
    AnswerRating, Attachment, Comment, Community, HelpfulVote, Post, PostTag, QuestionRelevance, Reaction,
    Report, SavedPost, Tag, User, Vote,
)
from schemas import (
    CommentCreate, CommentUpdate, HelpfulIn, PostCreate, PostUpdate, RatingIn, ReactionIn, VoteIn,
)
from security import get_current_user, get_optional_user, rate_limit
from services import moderation, routing, search
from services.content import (
    REACTIONS, _valid_uuid, assert_can_interact, build_thread, get_post_or_404, is_active_member, is_moderator,
    membership, reaction_info, serialize_posts, vote_info,
)
from services.notifications import mentioned_users, notify
from services.quality import feedback_counts
from services.reputation import POINTS, evaluate_badges, set_event

router = APIRouter(tags=["posts"])
MAX_DEPTH = 10


def utcnow():
    return datetime.now(timezone.utc)


def get_or_create_tags(db: Session, names: list[str]) -> list[Tag]:
    out = []
    for n in names:
        n = n.strip().lower()
        if not n:
            continue
        t = db.scalar(select(Tag).where(Tag.name == n))
        if not t:
            t = Tag(name=n); db.add(t); db.flush()
        out.append(t)
    return out


def _screen(db: Session, user: User, *texts: str) -> moderation.Verdict:
    v = moderation.screen(db, user.id, *texts)
    if v.action == "block":
        raise HTTPException(422, f"Your content could not be published: {v.reason}.")
    return v


def _auto_flag(db: Session, community_id: str | None, target_type: str, target_id: str, reason: str) -> None:
    db.add(Report(reporter_id=None, target_type=target_type, target_id=target_id, community_id=community_id,
                  reason="abuse" if "language" in reason.lower() else "spam", details=f"Auto-flagged: {reason}"))


# ── posts ─────────────────────────────────────────────────────────────────────
@router.post("/posts", status_code=201, dependencies=[Depends(rate_limit("post", 30, 3600))])
def create_post(data: PostCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not _valid_uuid(data.community_id):
        raise HTTPException(404, "Community not found")
    community = db.get(Community, data.community_id)
    if not community:
        raise HTTPException(404, "Community not found")
    from services.content import is_banned
    if is_banned(db, community.id, user.id):
        raise HTTPException(403, "You are banned from this community")
    m = membership(db, community.id, user.id)
    if not is_active_member(m):
        raise HTTPException(403, "Join this community before posting in it" if not m else "Your request to join is still awaiting approval")
    if data.post_type in ("question", "help_request") and user.user_type != "learner":
        raise HTTPException(403, "Questions are asked by learners; experts answer them")
    if data.post_type == "announcement" and not is_moderator(m):
        raise HTTPException(403, "Only moderators can post announcements")
    if data.post_type == "resource" and not data.attachments and not re.search(r"https?://", data.body):
        raise HTTPException(422, "A resource needs a file or a link")
    verdict = _screen(db, user, data.title, data.body)

    post = Post(author_id=user.id, community_id=community.id, post_type=data.post_type, title=data.title,
                body=data.body, field=data.field, skill_level=data.skill_level,
                resource_kind=(data.resource_kind or "link") if data.post_type == "resource" else None,
                is_pinned=data.post_type == "announcement")
    post.tags = get_or_create_tags(db, data.tags)
    post.attachments = [Attachment(**a.model_dump()) for a in data.attachments]
    db.add(post); db.flush()
    if verdict.action == "flag":
        _auto_flag(db, community.id, "post", post.id, verdict.reason)

    routed = 0
    if post.post_type == "question":
        rows = routing.engine.route_question(db, post, [t.name for t in post.tags])
        routed = len(rows)
        ranked = sorted(rows, key=lambda r: routing.final_feed_score(r, utcnow(), 0)["score"], reverse=True)
        sent = 0
        for r in ranked:
            if sent >= settings.routing_notify_max:
                break
            if routing.final_feed_score(r, utcnow(), 0)["score"] >= settings.routing_notify_min_score:
                notify(db, r.expert_id, "new_question", f"New relevant question: {post.title[:140]}",
                       actor_id=None, post_id=post.id)
                sent += 1
    for u in mentioned_users(db, f"{data.title}\n{data.body}"):
        notify(db, u.id, "mention", f"{user.name} mentioned you in a post", actor_id=user.id, post_id=post.id)
    if post.post_type == "announcement":
        from models import CommunityMember
        for mid in db.scalars(select(CommunityMember.user_id).where(
                CommunityMember.community_id == community.id, CommunityMember.status == "active")):
            notify(db, mid, "announcement", f"{community.name}: {post.title[:140]}", actor_id=user.id, post_id=post.id)
    db.commit()
    search.index.invalidate()
    out = serialize_posts(db, [post], user)[0]
    out["routed_expert_count"] = routed
    return out


@router.get("/posts/{post_id}")
def get_post(post_id: str, user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    post = get_post_or_404(db, post_id, user)
    return serialize_posts(db, [post], user)[0]


@router.put("/posts/{post_id}")
def edit_post(post_id: str, data: PostUpdate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = get_post_or_404(db, post_id, user)
    if post.author_id != user.id:
        raise HTTPException(403, "Only the author can edit this post")
    sent = data.model_dump(exclude_unset=True)
    _screen(db, user, sent.get("title", post.title), sent.get("body", post.body))
    for k in ("title", "body", "field", "skill_level"):
        if k in sent and sent[k] is not None:
            setattr(post, k, sent[k])
    if sent.get("tags") is not None:
        post.tags = get_or_create_tags(db, sent["tags"])
    post.updated_at = utcnow()
    if post.post_type == "question" and any(k in sent for k in ("title", "body", "tags", "field")):
        routing.engine.invalidate()
        routing.engine.route_question(db, post, [t.name for t in post.tags])
    db.commit()
    search.index.invalidate()
    return serialize_posts(db, [post], user)[0]


@router.delete("/posts/{post_id}", status_code=204)
def delete_post(post_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = get_post_or_404(db, post_id, user)
    m = membership(db, post.community_id, user.id)
    if post.author_id != user.id and not is_moderator(m):
        raise HTTPException(403, "Not allowed")
    post.is_removed = True
    if post.author_id != user.id:
        notify(db, post.author_id, "moderation", f"A moderator removed your post “{post.title[:80]}”", actor_id=user.id)
    db.commit()
    search.index.invalidate()


@router.post("/posts/{post_id}/pin")
def pin_post(post_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = get_post_or_404(db, post_id, user)
    if not is_moderator(membership(db, post.community_id, user.id)):
        raise HTTPException(403, "Moderators only")
    post.is_pinned = not post.is_pinned
    db.commit()
    return {"is_pinned": post.is_pinned}


@router.post("/posts/{post_id}/save", status_code=204)
def save_post(post_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = get_post_or_404(db, post_id, user)
    if not db.get(SavedPost, (user.id, post.id)):
        db.add(SavedPost(user_id=user.id, post_id=post.id)); db.commit()


@router.delete("/posts/{post_id}/save", status_code=204)
def unsave_post(post_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    s = db.get(SavedPost, (user.id, post_id)) if _valid_uuid(post_id) else None
    if s:
        db.delete(s); db.commit()


# ── comments & answers ───────────────────────────────────────────────────────
def _find(nodes: list[dict], cid: str):
    for n in nodes:
        if n["id"] == cid:
            return n
        hit = _find(n["children"], cid)
        if hit:
            return hit


def get_comment_or_404(db: Session, comment_id: str, user: User | None) -> Comment:
    c = db.get(Comment, comment_id) if _valid_uuid(comment_id) else None
    if not c:
        raise HTTPException(404, "Comment not found")
    get_post_or_404(db, c.post_id, user)
    return c


@router.get("/posts/{post_id}/comments")
def list_comments(post_id: str, sort: str = "best", user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    post = get_post_or_404(db, post_id, user)
    if sort not in ("best", "newest", "active"):
        raise HTTPException(422, "sort must be best, newest or active")
    return build_thread(db, post, user, sort)


def _depth(db: Session, c: Comment) -> int:
    d = 0
    while c.parent_id and d < 50:
        c = db.get(Comment, c.parent_id); d += 1
    return d


@router.post("/posts/{post_id}/comments", status_code=201, dependencies=[Depends(rate_limit("comment", 60, 3600))])
def add_comment(post_id: str, data: CommentCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = get_post_or_404(db, post_id, user)
    assert_can_interact(db, post.community, user)
    parent = None
    if data.parent_id:
        parent = db.get(Comment, data.parent_id) if _valid_uuid(data.parent_id) else None
        if not parent or parent.post_id != post.id or parent.is_removed:
            raise HTTPException(404, "The comment you are replying to no longer exists")
        if _depth(db, parent) >= MAX_DEPTH:           # flatten extremely deep chains
            parent = db.get(Comment, parent.parent_id)
    verdict = _screen(db, user, data.body)
    is_answer = (post.post_type == "question" and parent is None and user.user_type == "expert" and user.id != post.author_id)
    c = Comment(post_id=post.id, parent_id=parent.id if parent else None, author_id=user.id, body=data.body, is_answer=is_answer)
    db.add(c); db.flush()
    if verdict.action == "flag":
        _auto_flag(db, post.community_id, "comment", c.id, verdict.reason)
    post.last_activity_at = utcnow()

    notified = {user.id}
    def once(uid, *args, **kw):
        if uid not in notified:
            notified.add(uid); notify(db, uid, *args, **kw)
    if is_answer:
        if post.status == "open":
            post.status = "answered"
        rel = db.get(QuestionRelevance, (post.id, user.id))
        if rel:
            rel.status = "answered"
        once(post.author_id, "answer", f"{user.name} answered your question: {post.title[:100]}",
             actor_id=user.id, post_id=post.id, comment_id=c.id)
    elif parent is not None:
        once(parent.author_id, "reply", f"{user.name} replied to your {'answer' if parent.is_answer else 'comment'}",
             actor_id=user.id, post_id=post.id, comment_id=c.id)
        once(post.author_id, "post_activity", f"New activity on your post: {post.title[:100]}",
             actor_id=user.id, post_id=post.id, comment_id=c.id)
    else:
        once(post.author_id, "post_activity", f"{user.name} commented on: {post.title[:100]}",
             actor_id=user.id, post_id=post.id, comment_id=c.id)
    for u in mentioned_users(db, data.body):
        once(u.id, "mention", f"{user.name} mentioned you in a comment", actor_id=user.id, post_id=post.id, comment_id=c.id)
    if is_answer:
        routing.engine.invalidate()       # the expert's "answered topics" now feed their expertise vector
    evaluate_badges(db, user)
    db.commit()
    return _find(build_thread(db, post, user, "newest"), c.id)


@router.put("/comments/{comment_id}")
def edit_comment(comment_id: str, data: CommentUpdate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_comment_or_404(db, comment_id, user)
    if c.author_id != user.id or c.is_deleted or c.is_removed:
        raise HTTPException(403, "You can't edit this comment")
    _screen(db, user, data.body)
    c.body, c.edited_at = data.body, utcnow()
    db.commit()
    return _find(build_thread(db, c.post, user, "newest"), c.id)


@router.delete("/comments/{comment_id}", status_code=204)
def delete_comment(comment_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_comment_or_404(db, comment_id, user)
    own = c.author_id == user.id
    if not own and not is_moderator(membership(db, c.post.community_id, user.id)):
        raise HTTPException(403, "Not allowed")
    if own:
        c.is_deleted = True
    else:
        c.is_removed = True
        notify(db, c.author_id, "moderation", "A moderator removed your comment", actor_id=user.id, post_id=c.post_id)
    if c.is_accepted:
        c.is_accepted = False
        c.post.status = "answered"
        set_event(db, c.author_id, f"accepted:{c.id}", "answer_accepted", 0)
    db.commit()


@router.post("/comments/{comment_id}/accept")
def accept_answer(comment_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_comment_or_404(db, comment_id, user)
    post = c.post
    if post.author_id != user.id:
        raise HTTPException(403, "Only the person who asked can accept an answer")
    if not c.is_answer or c.is_deleted or c.is_removed:
        raise HTTPException(400, "Only expert answers can be accepted")
    if c.is_accepted:
        c.is_accepted = False
        post.status = "answered"
        set_event(db, c.author_id, f"accepted:{c.id}", "answer_accepted", 0)
    else:
        for other in db.scalars(select(Comment).where(Comment.post_id == post.id, Comment.is_accepted.is_(True))):
            other.is_accepted = False
            set_event(db, other.author_id, f"accepted:{other.id}", "answer_accepted", 0)
        c.is_accepted = True
        post.status = "resolved"
        set_event(db, c.author_id, f"accepted:{c.id}", "answer_accepted", POINTS["answer_accepted"])
        notify(db, c.author_id, "accepted", f"Your answer was accepted: {post.title[:100]}", actor_id=user.id, post_id=post.id, comment_id=c.id)
    evaluate_badges(db, c.author)
    db.commit()
    return {"is_accepted": c.is_accepted, "post_status": post.status}


def answer_summary(db: Session, c: Comment, viewer: User) -> dict:
    rs = [r for (r,) in db.execute(select(AnswerRating.rating).where(AnswerRating.comment_id == c.id))]
    mine = db.scalar(select(AnswerRating.rating).where(AnswerRating.comment_id == c.id, AnswerRating.rater_id == viewer.id))
    pos, tot = feedback_counts(db, [c.id])[c.id]
    hc = db.scalar(select(func.count()).select_from(HelpfulVote).where(HelpfulVote.comment_id == c.id)) or 0
    return {"rating": {"average": round(sum(rs) / len(rs), 2) if rs else None, "count": len(rs), "mine": mine},
            "helpful": {"count": hc, "percent": round(100 * pos / tot) if tot else None,
                        "mine": bool(db.get(HelpfulVote, (c.id, viewer.id)))}}


def _rateable(db: Session, comment_id: str, user: User) -> Comment:
    c = get_comment_or_404(db, comment_id, user)
    assert_can_interact(db, c.post.community, user)
    if not c.is_answer or c.is_deleted or c.is_removed:
        raise HTTPException(400, "Only expert answers can be rated")
    if c.author_id == user.id:
        raise HTTPException(403, "You can't rate your own answer")
    return c


@router.put("/comments/{comment_id}/rating", dependencies=[Depends(rate_limit("rate", 120, 3600))])
def rate_answer(comment_id: str, data: RatingIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """One rating per person per answer; calling again changes it."""
    c = _rateable(db, comment_id, user)
    r = db.scalar(select(AnswerRating).where(AnswerRating.comment_id == c.id, AnswerRating.rater_id == user.id))
    if r:
        r.rating, r.updated_at = data.rating, utcnow()
    else:
        db.add(AnswerRating(comment_id=c.id, rater_id=user.id, rating=data.rating))
        notify(db, c.author_id, "rated", f"{user.name} rated your answer {data.rating}/5", actor_id=user.id,
               post_id=c.post_id, comment_id=c.id)
    db.flush()
    pts = POINTS["answer_rating_high"] if data.rating >= 4 else POINTS["answer_rating_low"] if data.rating <= 2 else 0
    set_event(db, c.author_id, f"rating:{c.id}:{user.id}", "answer_rating", pts)
    evaluate_badges(db, c.author)
    db.commit()
    return answer_summary(db, c, user)


@router.delete("/comments/{comment_id}/rating")
def remove_rating(comment_id: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = _rateable(db, comment_id, user)
    r = db.scalar(select(AnswerRating).where(AnswerRating.comment_id == c.id, AnswerRating.rater_id == user.id))
    if r:
        db.delete(r); db.flush()
        set_event(db, c.author_id, f"rating:{c.id}:{user.id}", "answer_rating", 0)
        evaluate_badges(db, c.author)
        db.commit()
    return answer_summary(db, c, user)


@router.post("/comments/{comment_id}/helpful")
def helpful(comment_id: str, data: HelpfulIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = _rateable(db, comment_id, user)
    h = db.get(HelpfulVote, (c.id, user.id))
    if data.value and not h:
        db.add(HelpfulVote(comment_id=c.id, user_id=user.id))
    elif not data.value and h:
        db.delete(h)
    db.flush()
    set_event(db, c.author_id, f"helpful:{c.id}:{user.id}", "answer_helpful", POINTS["answer_helpful"] if data.value else 0)
    evaluate_badges(db, c.author)
    db.commit()
    return answer_summary(db, c, user)


# ── votes & reactions ────────────────────────────────────────────────────────
def _target(db: Session, ttype: str, tid: str, user: User):
    if not _valid_uuid(tid):
        raise HTTPException(404, "Not found")
    if ttype == "post":
        obj = get_post_or_404(db, tid, user)
        community = obj.community
    else:
        obj = get_comment_or_404(db, tid, user)
        if obj.is_deleted or obj.is_removed:
            raise HTTPException(404, "Not found")
        community = obj.post.community
    assert_can_interact(db, community, user)
    return obj


@router.post("/votes", dependencies=[Depends(rate_limit("vote", 300, 3600))])
def vote(data: VoteIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    obj = _target(db, data.target_type, data.target_id, user)
    if obj.author_id == user.id:
        raise HTTPException(400, "You can't vote on your own content")
    v = db.get(Vote, (user.id, data.target_type, data.target_id))
    if data.value == 0:
        if v:
            db.delete(v)
    elif v:
        v.value = data.value
    else:
        db.add(Vote(user_id=user.id, target_type=data.target_type, target_id=data.target_id, value=data.value))
    db.flush()
    kind = f"{data.target_type}_{'upvote' if data.value > 0 else 'downvote'}"
    pts = POINTS.get(kind, 0) if data.value else 0
    set_event(db, obj.author_id, f"vote:{data.target_type}:{data.target_id}:{user.id}", kind if data.value else "vote", pts)
    evaluate_badges(db, obj.author)
    db.commit()
    score, mine = vote_info(db, data.target_type, [data.target_id], user.id)[data.target_id]
    return {"score": score, "my_vote": mine}


@router.post("/reactions", dependencies=[Depends(rate_limit("react", 300, 3600))])
def react(data: ReactionIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if data.emoji not in REACTIONS:
        raise HTTPException(422, f"emoji must be one of {' '.join(REACTIONS)}")
    _target(db, data.target_type, data.target_id, user)
    r = db.get(Reaction, (user.id, data.target_type, data.target_id, data.emoji))
    if r:
        db.delete(r)
    else:
        db.add(Reaction(user_id=user.id, target_type=data.target_type, target_id=data.target_id, emoji=data.emoji))
    db.commit()
    counts, mine = reaction_info(db, data.target_type, [data.target_id], user.id)[data.target_id]
    return {"reactions": counts, "my_reactions": mine}
