"""Notifications, search, translation, reports, uploads."""
import hashlib
import mimetypes
import os
import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy import func, select, update
from sqlalchemy.orm import Session

from config import settings
from db import get_db
from models import Comment, Community, Notification, Post, Report, User
from schemas import ReportIn, ResolveReportIn, TranslateIn
from security import get_current_user, get_optional_user, rate_limit
from services import search as search_svc
from services.content import (
    _valid_uuid, assert_can_view, get_post_or_404, is_moderator, iso, membership, serialize_posts, user_brief,
)
from services.notifications import notify
from services.translation import detect, languages
from services.translation.backend import TranslationUnavailable
from services.translation.service import translate_text

router = APIRouter(tags=["misc"])


# ── notifications ────────────────────────────────────────────────────────────
@router.get("/notifications")
def notifications(unread_only: bool = False, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    stmt = select(Notification).where(Notification.user_id == user.id)
    if unread_only:
        stmt = stmt.where(Notification.is_read.is_(False))
    rows = db.scalars(stmt.order_by(Notification.created_at.desc()).limit(60)).all()
    return [{"id": n.id, "type": n.type, "message": n.message, "is_read": n.is_read, "created_at": iso(n.created_at),
             "post_id": n.post_id, "comment_id": n.comment_id, "actor": user_brief(n.actor) if n.actor else None} for n in rows]


@router.get("/notifications/unread-count")
def unread_count(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return {"count": db.scalar(select(func.count()).select_from(Notification).where(
        Notification.user_id == user.id, Notification.is_read.is_(False))) or 0}


@router.post("/notifications/read-all", status_code=204)
def read_all(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    db.execute(update(Notification).where(Notification.user_id == user.id, Notification.is_read.is_(False)).values(is_read=True))
    db.commit()


@router.post("/notifications/{nid}/read", status_code=204)
def read_one(nid: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    n = db.get(Notification, nid) if _valid_uuid(nid) else None
    if n and n.user_id == user.id:
        n.is_read = True; db.commit()


# ── search ───────────────────────────────────────────────────────────────────
KIND_GROUPS = {"questions": {"question"}, "discussions": {"discussion"}, "resources": {"resource"},
               "communities": {"community"}, "users": {"learner", "expert"}, "experts": {"expert"}}


@router.get("/search")
def search(q: str = Query(min_length=2, max_length=200), type: str = Query("all", pattern="^(all|questions|discussions|resources|communities|users|experts)$"),
           user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    kinds = KIND_GROUPS.get(type)
    hits = search_svc.index.query(db, q, kinds, search_svc.viewer_community_ids(db, user.id if user else None))
    by_kind: dict[str, list] = {}
    for d, score in hits:
        by_kind.setdefault(d.kind, []).append((d.id, score))
    out = {"query": q, "method": "keyword + TF-IDF cosine similarity", "questions": [], "discussions": [], "resources": [],
           "communities": [], "users": []}
    for kind in ("question", "discussion", "resource"):
        ids = [i for i, _ in by_kind.get(kind, [])]
        if ids:
            posts = {p.id: p for p in db.scalars(select(Post).where(Post.id.in_(ids), Post.is_removed.is_(False)))}
            ordered = [posts[i] for i in ids if i in posts]
            out[{"question": "questions", "discussion": "discussions", "resource": "resources"}[kind]] = serialize_posts(db, ordered, user)
    cids = [i for i, _ in by_kind.get("community", [])]
    if cids:
        from routes.communities import serialize_community
        cs = {c.id: c for c in db.scalars(select(Community).where(Community.id.in_(cids)))}
        out["communities"] = serialize_community(db, [cs[i] for i in cids if i in cs], user)
    uids = [i for k in ("learner", "expert") for i, _ in by_kind.get(k, [])]
    if uids:
        us = {u.id: u for u in db.scalars(select(User).where(User.id.in_(uids)))}
        scores = {i: s for k in ("learner", "expert") for i, s in by_kind.get(k, [])}
        out["users"] = [user_brief(us[i]) for i in sorted(uids, key=lambda i: -scores[i]) if i in us]
    return out


# ── translation ──────────────────────────────────────────────────────────────
@router.get("/translate/languages")
def langs():
    return languages.language_list()


@router.post("/translate", dependencies=[Depends(rate_limit("translate", 120, 3600))])
def translate(data: TranslateIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Translate a post or comment into `target_lang`. The stored original is never changed; results are cached."""
    if not _valid_uuid(data.target_id):
        raise HTTPException(404, "Not found")
    if data.target_type == "post":
        post = get_post_or_404(db, data.target_id, user)
        parts = {"title": post.title, "body": post.body or ""}
    else:
        c = db.get(Comment, data.target_id)
        if not c or c.is_deleted or c.is_removed:
            raise HTTPException(404, "Not found")
        get_post_or_404(db, c.post_id, user)
        parts = {"body": c.body}
    parts = {k: v for k, v in parts.items() if v.strip()}
    if data.target_lang not in languages.LANGUAGES:
        raise HTTPException(422, "Unsupported target language")
    if data.source_lang and data.source_lang not in languages.LANGUAGES:
        raise HTTPException(422, "Unsupported source language")
    detected = detect.detect_language("\n".join(parts.values()))
    src = data.source_lang or detected["code"]
    if not src:
        return {"status": "needs_source", "detected": detected,
                "message": "Couldn't detect the language. Choose the original language and try again."}
    if src == data.target_lang:
        return {"status": "same_language", "detected": detected, "source_lang": src, "target_lang": data.target_lang,
                "original": parts, "translated": parts}
    try:
        translated, cached, model = {}, True, None
        for k, text in parts.items():
            r = translate_text(db, text, src, data.target_lang)
            translated[k], cached, model = r["translated"], cached and r["cached"], r["model"]
        db.commit()
    except TranslationUnavailable as e:
        raise HTTPException(503, str(e))
    except ValueError as e:
        raise HTTPException(422, str(e))
    return {"status": "ok", "detected": detected, "source_lang": src, "target_lang": data.target_lang,
            "original": parts, "translated": translated, "cached": cached, "model": model}


# ── reports ──────────────────────────────────────────────────────────────────
def _report_context(db: Session, data: ReportIn, user: User):
    if not _valid_uuid(data.target_id):
        raise HTTPException(404, "Not found")
    if data.target_type == "post":
        p = get_post_or_404(db, data.target_id, user); return p.community_id, p.author_id
    if data.target_type == "comment":
        c = db.get(Comment, data.target_id)
        if not c:
            raise HTTPException(404, "Not found")
        p = get_post_or_404(db, c.post_id, user); return p.community_id, c.author_id
    t = db.get(User, data.target_id)
    if not t:
        raise HTTPException(404, "Not found")
    return None, t.id


@router.post("/reports", status_code=201, dependencies=[Depends(rate_limit("report", 30, 3600))])
def report(data: ReportIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    community_id, author_id = _report_context(db, data, user)
    if author_id == user.id:
        raise HTTPException(400, "You can't report your own content")
    dup = db.scalar(select(Report.id).where(Report.reporter_id == user.id, Report.target_type == data.target_type,
                                            Report.target_id == data.target_id, Report.status == "open"))
    if dup:
        return {"id": dup, "duplicate": True}
    r = Report(reporter_id=user.id, target_type=data.target_type, target_id=data.target_id, community_id=community_id,
               reason=data.reason, details=data.details)
    db.add(r); db.commit()
    return {"id": r.id, "duplicate": False}


@router.get("/communities/{slug}/reports")
def community_reports(slug: str, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    c = db.scalar(select(Community).where(Community.slug == slug))
    if not c or not is_moderator(membership(db, c.id, user.id)):
        raise HTTPException(403, "Moderators only")
    rows = db.scalars(select(Report).where(Report.community_id == c.id, Report.status == "open").order_by(Report.created_at.desc()).limit(100)).all()
    out = []
    for r in rows:
        item = {"id": r.id, "target_type": r.target_type, "target_id": r.target_id, "reason": r.reason,
                "details": r.details, "created_at": iso(r.created_at), "auto": r.reporter_id is None}
        if r.target_type == "post":
            p = db.get(Post, r.target_id)
            item["preview"] = {"title": p.title, "body": (p.body or "")[:300], "author": p.author.username, "post_id": p.id} if p else None
        else:
            cm = db.get(Comment, r.target_id)
            item["preview"] = {"body": cm.body[:300], "author": cm.author.username, "post_id": cm.post_id} if cm else None
        out.append(item)
    return out


@router.post("/reports/{report_id}/resolve", status_code=204)
def resolve_report(report_id: str, data: ResolveReportIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    r = db.get(Report, report_id) if _valid_uuid(report_id) else None
    if not r or not r.community_id or not is_moderator(membership(db, r.community_id, user.id)):
        raise HTTPException(404, "Report not found")
    community = db.get(Community, r.community_id)
    if data.action in ("remove_content", "ban_user"):
        if r.target_type == "post":
            p = db.get(Post, r.target_id); author = p.author_id if p else None
            if p and data.action == "remove_content":
                p.is_removed = True
        else:
            cm = db.get(Comment, r.target_id); author = cm.author_id if cm else None
            if cm and data.action == "remove_content":
                cm.is_removed = True
        if data.action == "ban_user" and author:
            from routes.communities import ban_user
            ban_user(db, community, db.get(User, author), user, f"Report: {r.reason}")
        if data.action == "remove_content" and author:
            notify(db, author, "moderation", "A moderator removed your content after a report", actor_id=user.id)
    r.status = "dismissed" if data.action == "dismiss" else "resolved"
    r.resolved_by = user.id
    # close every open report on the same target
    for other in db.scalars(select(Report).where(Report.target_type == r.target_type, Report.target_id == r.target_id, Report.status == "open")):
        other.status, other.resolved_by = r.status, user.id
    search_svc.index.invalidate()
    db.commit()


# ── uploads ──────────────────────────────────────────────────────────────────
_IMAGE_SIGS = {b"\x89PNG\r\n\x1a\n": "image/png", b"\xff\xd8\xff": "image/jpeg", b"GIF87a": "image/gif",
               b"GIF89a": "image/gif"}
_ALLOWED = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".gif": "image/gif", ".webp": "image/webp",
            ".pdf": "application/pdf", ".txt": "text/plain", ".md": "text/markdown", ".csv": "text/csv",
            ".json": "application/json", ".ipynb": "application/x-ipynb+json", ".zip": "application/zip"}


def _sniff(head: bytes, ext: str) -> bool:
    """Content must match the claimed extension (a renamed .exe is not a .png)."""
    if ext in (".png", ".jpg", ".jpeg", ".gif"):
        return any(head.startswith(sig) for sig in _IMAGE_SIGS)
    if ext == ".webp":
        return head[:4] == b"RIFF" and head[8:12] == b"WEBP"
    if ext == ".pdf":
        return head.startswith(b"%PDF-")
    if ext == ".zip":
        return head.startswith(b"PK")
    return b"\x00" not in head            # text-like formats must not contain NUL bytes


@router.post("/uploads", status_code=201, dependencies=[Depends(rate_limit("upload", 30, 3600))])
async def upload(file: UploadFile = File(...), user: User = Depends(get_current_user)):
    ext = Path(file.filename or "").suffix.lower()
    if ext not in _ALLOWED:
        raise HTTPException(415, f"File type not allowed. Allowed: {', '.join(sorted(_ALLOWED))}")
    data = await file.read(settings.max_upload_mb * 1024 * 1024 + 1)
    if len(data) > settings.max_upload_mb * 1024 * 1024:
        raise HTTPException(413, f"File too large (max {settings.max_upload_mb} MB)")
    if not data or not _sniff(data[:16], ext):
        raise HTTPException(415, "File content doesn't match its extension")
    os.makedirs(settings.upload_dir, exist_ok=True)
    name = f"{uuid.uuid4().hex}{ext}"
    (Path(settings.upload_dir) / name).write_bytes(data)
    mime = _ALLOWED[ext]
    return {"url": f"/uploads/{name}", "name": (file.filename or name)[:255], "mime": mime, "size": len(data),
            "kind": "image" if mime.startswith("image/") else "file"}
