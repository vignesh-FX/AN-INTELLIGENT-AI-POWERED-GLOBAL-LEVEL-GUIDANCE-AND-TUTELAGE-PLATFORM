"""Notification helpers + @mention parsing. `publish` is the hook for real-time delivery later
(WebSocket / Supabase Realtime): today notifications are polled, but every creation already flows through here."""
import re
from typing import Callable, Optional

from sqlalchemy import select
from sqlalchemy.orm import Session

from models import Notification, User

MENTION_RE = re.compile(r"(?<![\w@])@([a-zA-Z0-9_]{3,30})")
_subscribers: list[Callable[[Notification], None]] = []


def subscribe(fn: Callable[[Notification], None]) -> None:
    _subscribers.append(fn)


def notify(db: Session, user_id: str, type_: str, message: str, actor_id: Optional[str] = None,
           post_id: Optional[str] = None, comment_id: Optional[str] = None) -> Optional[Notification]:
    if actor_id and actor_id == user_id:      # never notify people about their own actions
        return None
    n = Notification(user_id=user_id, type=type_, message=message[:300], actor_id=actor_id,
                     post_id=post_id, comment_id=comment_id)
    db.add(n)
    db.flush()
    for fn in _subscribers:
        try:
            fn(n)
        except Exception:   # a bad subscriber must never break the request
            pass
    return n


def mentioned_users(db: Session, text: str) -> list[User]:
    names = {m.lower() for m in MENTION_RE.findall(text or "")}
    if not names:
        return []
    return list(db.scalars(select(User).where(User.username.in_(names))))
