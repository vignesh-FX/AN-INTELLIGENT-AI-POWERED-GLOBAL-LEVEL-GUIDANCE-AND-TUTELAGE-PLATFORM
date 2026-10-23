"""One authentication backend, two experiences. `user_type` (learner | expert) decides the dashboard."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from db import get_db
from models import ExpertProfile, LearnerProfile, User
from schemas import ExpertRegister, LearnerRegister, LoginIn
from security import create_access_token, get_current_user, hash_password, rate_limit, verify_password
from services import routing, search
from services.content import user_brief
from services.reputation import badge_list, evaluate_badges

router = APIRouter(prefix="/auth", tags=["auth"])


def full_user(db: Session, u: User) -> dict:
    d = {**user_brief(u), "email": u.email, "languages": u.languages or [], "created_at": u.created_at.isoformat()}
    if u.user_type == "learner" and u.learner_profile:
        p = u.learner_profile
        d["profile"] = {k: getattr(p, k) for k in ("education", "institution", "work_status", "skills", "interests",
                                                    "skill_level", "learning_goals", "help_topics")}
    elif u.expert_profile:
        p = u.expert_profile
        d["profile"] = {k: getattr(p, k) for k in ("title", "organization", "years_experience", "education", "skills",
                                                    "expertise_areas", "projects", "certifications", "biography",
                                                    "mentoring_areas", "professional_interests")}
    return d


def _check_unique(db: Session, email: str, username: str) -> None:
    if db.scalar(select(User.id).where(func.lower(User.email) == email.lower())):
        raise HTTPException(409, "An account with this email already exists")
    if db.scalar(select(User.id).where(func.lower(User.username) == username.lower())):
        raise HTTPException(409, "That username is taken")


def _session(db: Session, u: User) -> dict:
    return {"access_token": create_access_token(u), "token_type": "bearer", "user": full_user(db, u)}


@router.post("/learner/register", status_code=201, dependencies=[Depends(rate_limit("register", 10, 3600))])
def register_learner(data: LearnerRegister, db: Session = Depends(get_db)):
    _check_unique(db, data.email, data.username)
    u = User(email=data.email.lower(), username=data.username, name=data.name, user_type="learner",
             password_hash=hash_password(data.password), avatar_url=data.avatar_url, languages=data.languages)
    u.learner_profile = LearnerProfile(
        education=data.education, institution=data.institution, work_status=data.work_status, skills=data.skills,
        interests=data.interests, skill_level=data.skill_level, learning_goals=data.learning_goals,
        help_topics=data.help_topics)
    db.add(u); db.commit()
    search.index.invalidate()
    return _session(db, u)


@router.post("/expert/register", status_code=201, dependencies=[Depends(rate_limit("register", 10, 3600))])
def register_expert(data: ExpertRegister, db: Session = Depends(get_db)):
    _check_unique(db, data.email, data.username)
    u = User(email=data.email.lower(), username=data.username, name=data.name, user_type="expert",
             password_hash=hash_password(data.password), avatar_url=data.avatar_url, languages=data.languages)
    u.expert_profile = ExpertProfile(**data.model_dump(include={
        "title", "organization", "years_experience", "education", "skills", "expertise_areas", "projects",
        "certifications", "biography", "mentoring_areas", "professional_interests"}))
    db.add(u); db.flush()
    routing.engine.invalidate()
    routing.route_open_questions_for_expert(db, u.id)      # questions already waiting may suit the new expert
    db.commit()
    search.index.invalidate()
    return _session(db, u)


def _login(db: Session, data: LoginIn, expected: str) -> dict:
    u = db.scalar(select(User).where(func.lower(User.email) == data.email.lower()))
    if not u or not u.is_active or not verify_password(data.password, u.password_hash):
        raise HTTPException(401, "Invalid email or password")
    if u.user_type != expected:
        other = "Expert" if u.user_type == "expert" else "Learner"
        raise HTTPException(403, f"This is a {other} account. Please use the {other} login.")
    return _session(db, u)


@router.post("/learner/login", dependencies=[Depends(rate_limit("login", 10, 60))])
def login_learner(data: LoginIn, db: Session = Depends(get_db)):
    return _login(db, data, "learner")


@router.post("/expert/login", dependencies=[Depends(rate_limit("login", 10, 60))])
def login_expert(data: LoginIn, db: Session = Depends(get_db)):
    return _login(db, data, "expert")


@router.get("/me")
def me(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return full_user(db, user)
