"""
Modular content screening. Each filter returns a Verdict; `screen()` combines them.
These are deliberately simple lexical/heuristic filters (clearly *not* ML) behind a stable interface so a
hosted classifier (e.g. Perspective API / a toxicity model) can replace `ToxicityFilter` later.
"""
import re
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from models import Comment, Post

URL_RE = re.compile(r"https?://\S+", re.I)


@dataclass
class Verdict:
    action: str = "allow"           # allow | flag | block
    reason: str = ""


_TOXIC_BLOCK = {"kill yourself", "kys", "i will kill you", "go die", "n1gger", "nigger", "faggot", "retard"}
_TOXIC_FLAG = {"idiot", "stupid", "moron", "dumbass", "shut up", "hate you", "scum", "trash human", "loser"}
_SPAM_PHRASES = {"buy now", "click here", "free money", "limited offer", "work from home", "earn $", "crypto giveaway",
                 "dm me for", "whatsapp me", "telegram @", "viagra", "casino", "100% guaranteed"}


class SpamFilter:
    def check(self, db: Session, user_id: str, text: str) -> Verdict:
        low = text.lower()
        links = URL_RE.findall(text)
        if len(links) > 4:
            return Verdict("block", "Too many links")
        if any(p in low for p in _SPAM_PHRASES):
            return Verdict("block", "Looks like spam")
        if re.search(r"(.)\1{14,}", text):
            return Verdict("block", "Repeated characters")
        letters = [c for c in text if c.isalpha()]
        if len(letters) > 40 and sum(c.isupper() for c in letters) / len(letters) > 0.8:
            return Verdict("flag", "Excessive capitals")
        since = datetime.now(timezone.utc) - timedelta(minutes=10)
        dup = db.scalar(select(func.count()).select_from(Comment).where(
            Comment.author_id == user_id, Comment.body == text, Comment.created_at > since))
        dup += db.scalar(select(func.count()).select_from(Post).where(
            Post.author_id == user_id, Post.body == text, Post.created_at > since))
        if dup:
            return Verdict("block", "Duplicate content")
        return Verdict()


class ToxicityFilter:
    def check(self, text: str) -> Verdict:
        low = text.lower()
        if any(re.search(rf"\b{re.escape(w)}\b", low) for w in _TOXIC_BLOCK):
            return Verdict("block", "Abusive language")
        if any(re.search(rf"\b{re.escape(w)}\b", low) for w in _TOXIC_FLAG):
            return Verdict("flag", "Possibly hostile language")
        return Verdict()


_spam, _tox = SpamFilter(), ToxicityFilter()


def screen(db: Session, user_id: str, *texts: str) -> Verdict:
    """Block > flag > allow across all filters."""
    text = "\n".join(t for t in texts if t)
    worst = Verdict()
    for v in (_spam.check(db, user_id, text), _tox.check(text)):
        if v.action == "block":
            return v
        if v.action == "flag" and worst.action == "allow":
            worst = v
    return worst
