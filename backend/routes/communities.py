import re

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from db import get_db
from models import Comment, Community, CommunityBan, CommunityMember, Post, Report, User, Vote
from schemas import CommunityCreate, CommunityUpdate, UsernameIn
from security import get_current_user, get_optional_user, rate_limit
from services import search
from services.content import (
    assert_can_view, community_brief, is_active_member, is_banned, is_moderator, iso, membership,
    serialize_posts, user_brief,
)
from services.notifications import notify
from services.text import tokenize
from services.tfidf import TfidfModel, cosine

router = APIRouter(prefix="/communities", tags=["communities"])


def slugify(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")[:60] or "community"


def get_community(db: Session, slug: str, user: User | None, must_view: bool = True) -> Community:
    c = db.scalar(select(Community).where(Community.slug == slug.lower()))
    if not c:
        raise HTTPException(404, "Community not found")
    if must_view:
        assert_can_view(db, c, user)
    return c


def member_count(db: Session, ids: list[str]) -> dict[str, int]:
    if not ids:
        return {}
    return dict(db.execute(select(CommunityMember.community_id, func.count()).where(
        CommunityMember.community_id.in_(ids), CommunityMember.status == "active").group_by(CommunityMember.community_id)).all())


def serialize_community(db: Session, cs: list[Community], user: User | None, counts: dict | None = None) -> list[dict]:
    counts = counts if counts is not None else member_count(db, [c.id for c in cs])
    mine = {}
    if user and cs:
        mine = {m.community_id: m for m in db.scalars(select(CommunityMember).where(
            CommunityMember.user_id == user.id, CommunityMember.community_id.in_([c.id for c in cs])))}
    out = []
    for c in cs:
        m = mine.get(c.id)
        out.append({**community_brief(c), "description": c.description, "banner_url": c.banner_url,
                    "member_count": counts.get(c.id, 0), "created_at": iso(c.created_at),
                    "membership": {"role": m.role, "status": m.status} if m else None})
    return out


@router.get("")
def list_communities(q: str = "", mine: bool = False, sort: str = Query("popular", pattern="^(popular|new)$"),
                     user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    stmt = select(Community)
    my_ids = set()
    if user:
        my_ids = {r[0] for r in db.execute(select(CommunityMember.community_id).where(CommunityMember.user_id == user.id))}
    if mine:
        if not user:
            raise HTTPException(401, "Not authenticated")
        stmt = stmt.where(Community.id.in_(my_ids))
    else:
        stmt = stmt.where((Community.is_private.is_(False)) | (Community.id.in_(my_ids)))
    if q:
        like = f"%{q.lower()}%"
        stmt = stmt.where(func.lower(Community.name).like(like) | func.lower(Community.description).like(like))
    cs = db.scalars(stmt).all()
    counts = member_count(db, [c.id for c in cs])
    cs.sort(key=(lambda c: counts.get(c.id, 0)) if sort == "popular" else (lambda c: c.created_at), reverse=True)
    return serialize_community(db, cs[:100], user, counts)


@router.get("/recommended")
def recommended(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Communities the user hasn't joined, ranked by TF-IDF cosine between their interests/goals and the community text."""
    joined = {r[0] for r in db.execute(select(CommunityMember.community_id).where(CommunityMember.user_id == user.id))}
    cs = [c for c in db.scalars(select(Community).where(Community.is_private.is_(False))) if c.id not in joined]
    if not cs:
        return []
    p = user.learner_profile or user.expert_profile
    prof_text = " ".join([" ".join(getattr(p, f, None) or []) if isinstance(getattr(p, f, None), list) else (getattr(p, f, None) or "")
                          for f in ("interests", "skills", "help_topics", "learning_goals", "expertise_areas", "mentoring_areas", "title")]) if p else ""
    docs = [tokenize(f"{c.name} {c.name} {c.description}") for c in cs]
    model = TfidfModel().fit(docs)
    qv = model.transform(tokenize(prof_text))
    counts = member_count(db, [c.id for c in cs])
    ranked = sorted(cs, key=lambda c: (cosine(qv, model.transform(docs[cs.index(c)])), counts.get(c.id, 0)), reverse=True)
    return serialize_community(db, ranked[:8], user, counts)


@router.post("", status_code=201, dependencies=[Depends(rate_limit("community", 10, 3600))])
def create_community(data: CommunityCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    slug = slugify(data.name)
    if db.scalar(select(Community.id).where((Community.slug == slug) | (func.lower(Community.name) == data.name.lower()))):
        raise HTTPException(409, "A community with this name already exists")
    c = Community(slug=slug, name=data.name, description=data.description, is_private=data.is_private,
                  avatar_url=data.avatar_url, banner_url=data.banner_url, created_by=user.id,
                  rules=[r.model_dump() for r in data.rules])
    db.add(c); db.flush()
    db.add(CommunityMember(community_id=c.id, user_id=user.id, role="owner", status="active"))
    db.commit()
    search.index.invalidate()
    return serialize_community(db, [c], user)[0]


@router.get("/{slug}")
def community_detail(slug: str, user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user)
    out = serialize_community(db, [c], user)[0]
    mods = db.execute(select(User, CommunityMember.role).join(CommunityMember, CommunityMember.user_id == User.id).where(
        CommunityMember.community_id == c.id, CommunityMember.status == "active",
        CommunityMember.role.in_(("owner", "moderator")))).all()
    out.update({"rules": c.rules or [], "moderators": [{**user_brief(u), "role": r} for u, r in mods],
                "is_banned": bool(user and is_banned(db, c.id, user.id))})
    return out


@router.put("/{slug}")
def update_community(slug: str, data: CommunityUpdate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user)
    m = membership(db, c.id, user.id)
    if not is_moderator(m):
        raise HTTPException(403, "Moderators only")
    sent = data.model_dump(exclude_unset=True)
    if "is_private" in sent and m.role != "owner":
        raise HTTPException(403, "Only the owner can change privacy")
    for k, v in sent.items():
        if k == "rules":
            v = [r if isinstance(r, dict) else r.model_dump() for r in (data.rules or [])]
        setattr(c, k, v)
    db.commit()
    search.index.invalidate()
    return community_detail(slug, user, db)


@router.post("/{slug}/join")
def join(slug: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user, must_view=False)
    if is_banned(db, c.id, user.id):
        raise HTTPException(403, "You are banned from this community")
    m = membership(db, c.id, user.id)
    if m:
        return {"role": m.role, "status": m.status}
    status = "pending" if c.is_private else "active"
    db.add(CommunityMember(community_id=c.id, user_id=user.id, role="member", status=status))
    if status == "pending":
        for mod in db.scalars(select(CommunityMember).where(CommunityMember.community_id == c.id,
                                                             CommunityMember.role.in_(("owner", "moderator")))):
            notify(db, mod.user_id, "join_request", f"{user.name} asked to join {c.name}", actor_id=user.id)
    db.commit()
    return {"role": "member", "status": status}


@router.post("/{slug}/leave", status_code=204)
def leave(slug: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user, must_view=False)
    m = membership(db, c.id, user.id)
    if not m:
        return
    if m.role == "owner":
        raise HTTPException(400, "The owner can't leave. Promote another moderator first or contact support.")
    db.delete(m); db.commit()


@router.get("/{slug}/posts")
def community_posts(slug: str, type: str | None = None, sort: str = Query("hot", pattern="^(hot|new|top)$"),
                    page: int = Query(1, ge=1), user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    from services.feed_rank import rank_posts
    c = get_community(db, slug, user)
    stmt = select(Post).where(Post.community_id == c.id, Post.is_removed.is_(False))
    if type:
        stmt = stmt.where(Post.post_type == type)
    posts = db.scalars(stmt.order_by(Post.created_at.desc()).limit(300)).all()
    ranked = rank_posts(db, posts, sort, pin_first=True)
    start = (page - 1) * 20
    return {"items": serialize_posts(db, ranked[start:start + 20], user), "has_more": len(ranked) > start + 20}


@router.get("/{slug}/members")
def members(slug: str, user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user)
    rows = db.execute(select(User, CommunityMember).join(CommunityMember, CommunityMember.user_id == User.id).where(
        CommunityMember.community_id == c.id, CommunityMember.status == "active").order_by(CommunityMember.joined_at).limit(200)).all()
    return [{**user_brief(u), "role": m.role} for u, m in rows]


def _need_mod(db: Session, c: Community, user: User, owner_only: bool = False) -> CommunityMember:
    m = membership(db, c.id, user.id)
    if not is_moderator(m) or (owner_only and m.role != "owner"):
        raise HTTPException(403, "Owner only" if owner_only else "Moderators only")
    return m


def _target(db: Session, username: str) -> User:
    t = db.scalar(select(User).where(func.lower(User.username) == username.lower()))
    if not t:
        raise HTTPException(404, "User not found")
    return t


@router.post("/{slug}/moderators")
def set_moderator(slug: str, data: UsernameIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user)
    _need_mod(db, c, user, owner_only=True)
    t = _target(db, data.username)
    m = membership(db, c.id, t.id)
    if not is_active_member(m):
        raise HTTPException(400, "They must be a member first")
    if m.role == "owner":
        raise HTTPException(400, "Can't change the owner's role")
    m.role = "moderator" if data.grant else "member"
    if data.grant:
        notify(db, t.id, "moderator", f"You're now a moderator of {c.name}", actor_id=user.id)
    db.commit()
    return {"username": t.username, "role": m.role}


@router.get("/{slug}/bans")
def list_bans(slug: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user); _need_mod(db, c, user)
    rows = db.execute(select(User, CommunityBan).join(CommunityBan, CommunityBan.user_id == User.id).where(CommunityBan.community_id == c.id)).all()
    return [{**user_brief(u), "reason": b.reason, "created_at": iso(b.created_at)} for u, b in rows]


def ban_user(db: Session, c: Community, target: User, by: User, reason: str | None) -> None:
    m = membership(db, c.id, target.id)
    if m and m.role in ("owner", "moderator"):
        raise HTTPException(400, "Moderators can't be banned. Remove their moderator role first.")
    if m:
        db.delete(m)
    if not db.get(CommunityBan, (c.id, target.id)):
        db.add(CommunityBan(community_id=c.id, user_id=target.id, reason=reason, banned_by=by.id))
        notify(db, target.id, "banned", f"You were banned from {c.name}", actor_id=by.id)


@router.post("/{slug}/bans", status_code=201)
def add_ban(slug: str, data: UsernameIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user); _need_mod(db, c, user)
    t = _target(db, data.username)
    if t.id == user.id:
        raise HTTPException(400, "You can't ban yourself")
    ban_user(db, c, t, user, data.reason)
    db.commit()
    return {"banned": t.username}


@router.delete("/{slug}/bans/{username}", status_code=204)
def remove_ban(slug: str, username: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user); _need_mod(db, c, user)
    t = _target(db, username)
    b = db.get(CommunityBan, (c.id, t.id))
    if b:
        db.delete(b); db.commit()


@router.get("/{slug}/requests")
def join_requests(slug: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = get_community(db, slug, user); _need_mod(db, c, user)
    rows = db.scalars(select(User).join(CommunityMember, CommunityMember.user_id == User.id).where(
        CommunityMember.community_id == c.id, CommunityMember.status == "pending")).all()
    return [user_brief(u) for u in rows]


@router.post("/{slug}/requests/{username}/{decision}", status_code=204)
def decide_request(slug: str, username: str, decision: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if decision not in ("approve", "reject"):
        raise HTTPException(404, "Unknown decision")
    c = get_community(db, slug, user); _need_mod(db, c, user)
    t = _target(db, username)
    m = membership(db, c.id, t.id)
    if not m or m.status != "pending":
        raise HTTPException(404, "No pending request")
    if decision == "approve":
        m.status = "active"
        notify(db, t.id, "community", f"Your request to join {c.name} was approved", actor_id=user.id)
    else:
        db.delete(m)
    db.commit()
