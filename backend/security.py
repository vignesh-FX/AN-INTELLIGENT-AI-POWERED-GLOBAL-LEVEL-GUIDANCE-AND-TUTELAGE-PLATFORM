"""Password hashing, JWT, auth dependencies and a small in-memory rate limiter."""
import base64
import hashlib
import time
from collections import defaultdict, deque
from datetime import datetime, timedelta, timezone
from typing import Optional

import bcrypt
import jwt
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from config import settings
from db import get_db
from models import User

bearer = HTTPBearer(auto_error=False)


# ── passwords ─────────────────────────────────────────────────────────────────
# bcrypt only reads 72 bytes, so pre-hash with SHA-256 (standard practice). We use the `bcrypt`
# package directly: the old passlib==1.7.4 crashes against bcrypt>=4.1.
def _prehash(password: str) -> bytes:
    return base64.b64encode(hashlib.sha256(password.encode("utf-8")).digest())


def hash_password(password: str) -> str:
    return bcrypt.hashpw(_prehash(password), bcrypt.gensalt()).decode()


def verify_password(password: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(_prehash(password), hashed.encode())
    except ValueError:
        return False


# ── tokens ────────────────────────────────────────────────────────────────────
def create_access_token(user: User) -> str:
    exp = datetime.now(timezone.utc) + timedelta(minutes=settings.token_minutes)
    payload = {"sub": user.id, "user_type": user.user_type, "exp": exp}
    return jwt.encode(payload, settings.secret_key, algorithm=settings.jwt_algorithm)


def _decode(token: str) -> dict:
    try:
        return jwt.decode(token, settings.secret_key, algorithms=[settings.jwt_algorithm])
    except jwt.PyJWTError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid or expired token")


def get_optional_user(
    creds: Optional[HTTPAuthorizationCredentials] = Depends(bearer),
    db: Session = Depends(get_db),
) -> Optional[User]:
    if not creds:
        return None
    payload = _decode(creds.credentials)
    user = db.get(User, payload.get("sub"))
    if not user or not user.is_active:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Account not found")
    return user


def get_current_user(user: Optional[User] = Depends(get_optional_user)) -> User:
    if not user:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Not authenticated")
    return user


def require_learner(user: User = Depends(get_current_user)) -> User:
    if user.user_type != "learner":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Learner account required")
    return user


def require_expert(user: User = Depends(get_current_user)) -> User:
    if user.user_type != "expert":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Expert account required")
    return user


# ── rate limiting (per-process sliding window; swap for Redis when running >1 worker) ──
_hits: dict[str, deque] = defaultdict(deque)


def reset_rate_limits() -> None:
    _hits.clear()


def rate_limit(name: str, limit: int, window: int = 60):
    def dep(request: Request):
        if not settings.rate_limit_enabled:
            return
        ident = request.client.host if request.client else "anon"
        auth = request.headers.get("authorization")
        if auth:
            ident = hashlib.sha1(auth.encode()).hexdigest()[:16]
        key = f"{name}:{ident}"
        now = time.monotonic()
        q = _hits[key]
        while q and now - q[0] > window:
            q.popleft()
        if len(q) >= limit:
            raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, "Too many requests, slow down")
        q.append(now)
    return dep
