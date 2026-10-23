"""Request validation models."""
import re
from typing import Literal, Optional

from pydantic import BaseModel, EmailStr, Field, field_validator

USERNAME_RE = re.compile(r"^[A-Za-z0-9_]{3,30}$")
POST_TYPES = ("question", "discussion", "project", "resource", "help_request", "announcement")
SKILL_LEVELS = ("Beginner", "Intermediate", "Advanced")
RESOURCE_KINDS = ("pdf", "paper", "github", "article", "video", "dataset", "notebook", "project", "link")


def clean_list(v, max_items: int = 30, max_len: int = 80) -> list[str]:
    if v is None:
        return []
    if isinstance(v, str):
        v = [x for x in re.split(r"[,\n]", v)]
    out, seen = [], set()
    for x in v:
        x = str(x).strip()[:max_len]
        if x and x.lower() not in seen:
            seen.add(x.lower()); out.append(x)
    return out[:max_items]


def check_media_url(v: Optional[str]) -> Optional[str]:
    if not v:
        return None
    if v.startswith("/uploads/") or re.match(r"^https?://", v):
        return v[:500]
    raise ValueError("must be an uploaded file or an http(s) URL")


class _Base(BaseModel):
    @field_validator("*", mode="before")
    @classmethod
    def _strip(cls, v):
        return v.strip() if isinstance(v, str) else v


class RegisterBase(_Base):
    name: str = Field(min_length=1, max_length=120)
    username: str
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    avatar_url: Optional[str] = None
    languages: list[str] = []

    @field_validator("username")
    @classmethod
    def _u(cls, v):
        if not USERNAME_RE.match(v):
            raise ValueError("Username must be 3–30 letters, numbers or underscores")
        return v

    @field_validator("avatar_url")
    @classmethod
    def _a(cls, v):
        return check_media_url(v)

    @field_validator("languages", mode="before")
    @classmethod
    def _l(cls, v):
        return clean_list(v, 10, 30)


class LearnerRegister(RegisterBase):
    education: Optional[str] = Field(default=None, max_length=160)
    institution: Optional[str] = Field(default=None, max_length=200)
    work_status: Optional[str] = Field(default=None, max_length=80)
    skills: list[str] = []
    interests: list[str] = []
    skill_level: Optional[Literal["Beginner", "Intermediate", "Advanced"]] = None
    learning_goals: Optional[str] = Field(default=None, max_length=2000)
    help_topics: list[str] = []

    @field_validator("skills", "interests", "help_topics", mode="before")
    @classmethod
    def _lists(cls, v):
        return clean_list(v)


class ExpertRegister(RegisterBase):
    title: str = Field(min_length=2, max_length=160)
    organization: Optional[str] = Field(default=None, max_length=200)
    years_experience: int = Field(default=0, ge=0, le=70)
    education: Optional[str] = Field(default=None, max_length=200)
    skills: list[str] = []
    expertise_areas: list[str] = Field(default=[], validate_default=True)
    projects: list[str] = []
    certifications: list[str] = []
    biography: Optional[str] = Field(default=None, max_length=3000)
    mentoring_areas: list[str] = []
    professional_interests: list[str] = []

    @field_validator("skills", "expertise_areas", "projects", "certifications", "mentoring_areas",
                     "professional_interests", mode="before")
    @classmethod
    def _lists(cls, v):
        return clean_list(v, 40, 200)

    @field_validator("expertise_areas")
    @classmethod
    def _need(cls, v):
        if not v:
            raise ValueError("Add at least one area of expertise — it is how questions find you")
        return v


class LoginIn(_Base):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class ProfileUpdate(_Base):
    """Fields from both profile types are accepted; the route applies the ones relevant to the user's type."""
    name: Optional[str] = Field(default=None, min_length=1, max_length=120)
    avatar_url: Optional[str] = None
    languages: Optional[list[str]] = None
    education: Optional[str] = Field(default=None, max_length=200)
    institution: Optional[str] = Field(default=None, max_length=200)
    work_status: Optional[str] = Field(default=None, max_length=80)
    skills: Optional[list[str]] = None
    interests: Optional[list[str]] = None
    skill_level: Optional[Literal["Beginner", "Intermediate", "Advanced"]] = None
    learning_goals: Optional[str] = Field(default=None, max_length=2000)
    help_topics: Optional[list[str]] = None
    title: Optional[str] = Field(default=None, max_length=160)
    organization: Optional[str] = Field(default=None, max_length=200)
    years_experience: Optional[int] = Field(default=None, ge=0, le=70)
    expertise_areas: Optional[list[str]] = None
    projects: Optional[list[str]] = None
    certifications: Optional[list[str]] = None
    biography: Optional[str] = Field(default=None, max_length=3000)
    mentoring_areas: Optional[list[str]] = None
    professional_interests: Optional[list[str]] = None

    @field_validator("avatar_url")
    @classmethod
    def _a(cls, v):
        return check_media_url(v)

    @field_validator("languages", "skills", "interests", "help_topics", "expertise_areas", "projects",
                     "certifications", "mentoring_areas", "professional_interests", mode="before")
    @classmethod
    def _lists(cls, v):
        return None if v is None else clean_list(v, 40, 200)


class Rule(BaseModel):
    title: str = Field(max_length=100)
    description: str = Field(default="", max_length=500)


class CommunityCreate(_Base):
    name: str = Field(min_length=3, max_length=80)
    description: str = Field(default="", max_length=2000)
    is_private: bool = False
    avatar_url: Optional[str] = None
    banner_url: Optional[str] = None
    rules: list[Rule] = Field(default=[], max_length=15)

    @field_validator("avatar_url", "banner_url")
    @classmethod
    def _m(cls, v):
        return check_media_url(v)


class CommunityUpdate(_Base):
    description: Optional[str] = Field(default=None, max_length=2000)
    is_private: Optional[bool] = None
    avatar_url: Optional[str] = None
    banner_url: Optional[str] = None
    rules: Optional[list[Rule]] = Field(default=None, max_length=15)

    @field_validator("avatar_url", "banner_url")
    @classmethod
    def _m(cls, v):
        return check_media_url(v)


class AttachmentIn(_Base):
    kind: Literal["image", "file", "link"]
    url: str = Field(max_length=1000)
    name: Optional[str] = Field(default=None, max_length=255)
    mime: Optional[str] = Field(default=None, max_length=100)
    size: Optional[int] = Field(default=None, ge=0)

    @field_validator("url")
    @classmethod
    def _url(cls, v):
        if not (v.startswith("/uploads/") or re.match(r"^https?://", v)):
            raise ValueError("url must be an uploaded file or an http(s) URL")
        return v


class PostCreate(_Base):
    community_id: str
    post_type: Literal["question", "discussion", "project", "resource", "help_request", "announcement"] = "discussion"
    title: str = Field(min_length=5, max_length=300)
    body: str = Field(default="", max_length=20000)
    tags: list[str] = []
    field: Optional[str] = Field(default=None, max_length=100)
    skill_level: Optional[Literal["Beginner", "Intermediate", "Advanced"]] = None
    resource_kind: Optional[Literal["pdf", "paper", "github", "article", "video", "dataset", "notebook", "project", "link"]] = None
    attachments: list[AttachmentIn] = Field(default=[], max_length=10)

    @field_validator("tags", mode="before")
    @classmethod
    def _tags(cls, v):
        return [t.lower().lstrip("#")[:30] for t in clean_list(v, 8, 30)]


class PostUpdate(_Base):
    title: Optional[str] = Field(default=None, min_length=5, max_length=300)
    body: Optional[str] = Field(default=None, max_length=20000)
    tags: Optional[list[str]] = None
    field: Optional[str] = Field(default=None, max_length=100)
    skill_level: Optional[Literal["Beginner", "Intermediate", "Advanced"]] = None

    @field_validator("tags", mode="before")
    @classmethod
    def _tags(cls, v):
        return None if v is None else [t.lower().lstrip("#")[:30] for t in clean_list(v, 8, 30)]


class CommentCreate(_Base):
    body: str = Field(min_length=1, max_length=10000)
    parent_id: Optional[str] = None


class CommentUpdate(_Base):
    body: str = Field(min_length=1, max_length=10000)


class VoteIn(_Base):
    target_type: Literal["post", "comment"]
    target_id: str
    value: Literal[-1, 0, 1]


class ReactionIn(_Base):
    target_type: Literal["post", "comment"]
    target_id: str
    emoji: str


class RatingIn(_Base):
    rating: int = Field(ge=1, le=5)


class HelpfulIn(_Base):
    value: bool = True


class RelevanceStatusIn(_Base):
    status: Literal["new", "saved", "ignored"]


class ReportIn(_Base):
    target_type: Literal["post", "comment", "user"]
    target_id: str
    reason: Literal["spam", "abuse", "harassment", "off_topic", "misinformation", "other"]
    details: Optional[str] = Field(default=None, max_length=1000)


class ResolveReportIn(_Base):
    action: Literal["dismiss", "remove_content", "ban_user"]


class UsernameIn(_Base):
    username: str
    reason: Optional[str] = Field(default=None, max_length=300)
    grant: bool = True


class TranslateIn(_Base):
    target_type: Literal["post", "comment"]
    target_id: str
    target_lang: str
    source_lang: Optional[str] = None
