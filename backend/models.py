"""
Data model. One table per real concept (no duplicated tables):

  users ─┬─ learner_profiles / expert_profiles          (user_type = learner | expert)
         ├─ community_members ── communities ── community_bans
         ├─ posts (question | discussion | project | resource | help_request | announcement)
         │     ├─ post_tags ── tags,   attachments
         │     └─ comments  (parent_id → nested replies; an expert's top-level comment on a question = an *answer*)
         ├─ votes, reactions (polymorphic: post | comment), saved_posts
         ├─ answer_ratings (1–5), helpful_votes
         ├─ question_relevance   ← output of the TF-IDF/cosine routing engine (question → expert feed)
         ├─ notifications, reputation_events, user_badges
         ├─ reports, user_blocks
         └─ translations (cache)
"""
import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import (
    JSON, Boolean, CheckConstraint, DateTime, Float, ForeignKey, Index, Integer, String, Text,
    UniqueConstraint, Uuid,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from db import Base

JSONType = JSON().with_variant(JSONB(), "postgresql")


def uid() -> str:
    return str(uuid.uuid4())


def now() -> datetime:
    return datetime.now(timezone.utc)


def pk():
    return mapped_column(Uuid(as_uuid=False), primary_key=True, default=uid)


def fk(target: str, **kw):
    return mapped_column(Uuid(as_uuid=False), ForeignKey(target, ondelete=kw.pop("ondelete", "CASCADE")), **kw)


def ts(**kw):
    return mapped_column(DateTime(timezone=True), default=now, **kw)


# ── users & profiles ─────────────────────────────────────────────────────────────
class User(Base):
    __tablename__ = "users"
    __table_args__ = (CheckConstraint("user_type in ('learner','expert')", name="ck_users_type"),)

    id: Mapped[str] = pk()
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    username: Mapped[str] = mapped_column(String(40), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(120))
    password_hash: Mapped[str] = mapped_column(String(255))
    user_type: Mapped[str] = mapped_column(String(10), index=True)
    avatar_url: Mapped[Optional[str]] = mapped_column(String(500))
    languages: Mapped[list] = mapped_column(JSONType, default=list)
    reputation: Mapped[int] = mapped_column(Integer, default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = ts()

    learner_profile: Mapped[Optional["LearnerProfile"]] = relationship(
        back_populates="user", uselist=False, cascade="all, delete-orphan")
    expert_profile: Mapped[Optional["ExpertProfile"]] = relationship(
        back_populates="user", uselist=False, cascade="all, delete-orphan")


class LearnerProfile(Base):
    __tablename__ = "learner_profiles"
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    education: Mapped[Optional[str]] = mapped_column(String(160))
    institution: Mapped[Optional[str]] = mapped_column(String(200))
    work_status: Mapped[Optional[str]] = mapped_column(String(80))
    skills: Mapped[list] = mapped_column(JSONType, default=list)             # what do I know?
    interests: Mapped[list] = mapped_column(JSONType, default=list)
    skill_level: Mapped[Optional[str]] = mapped_column(String(20))
    learning_goals: Mapped[Optional[str]] = mapped_column(Text)              # what do I want to learn?
    help_topics: Mapped[list] = mapped_column(JSONType, default=list)
    user: Mapped[User] = relationship(back_populates="learner_profile")


class ExpertProfile(Base):
    __tablename__ = "expert_profiles"
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    title: Mapped[Optional[str]] = mapped_column(String(160))
    organization: Mapped[Optional[str]] = mapped_column(String(200))
    years_experience: Mapped[int] = mapped_column(Integer, default=0)
    education: Mapped[Optional[str]] = mapped_column(String(200))
    skills: Mapped[list] = mapped_column(JSONType, default=list)              # what do I know?
    expertise_areas: Mapped[list] = mapped_column(JSONType, default=list)     # what can I answer?
    projects: Mapped[list] = mapped_column(JSONType, default=list)
    certifications: Mapped[list] = mapped_column(JSONType, default=list)
    biography: Mapped[Optional[str]] = mapped_column(Text)
    mentoring_areas: Mapped[list] = mapped_column(JSONType, default=list)
    professional_interests: Mapped[list] = mapped_column(JSONType, default=list)
    user: Mapped[User] = relationship(back_populates="expert_profile")


# ── communities ──────────────────────────────────────────────────────────────────
class Community(Base):
    __tablename__ = "communities"
    id: Mapped[str] = pk()
    slug: Mapped[str] = mapped_column(String(60), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(80), unique=True)
    description: Mapped[str] = mapped_column(Text, default="")
    avatar_url: Mapped[Optional[str]] = mapped_column(String(500))
    banner_url: Mapped[Optional[str]] = mapped_column(String(500))
    rules: Mapped[list] = mapped_column(JSONType, default=list)               # [{title, description}]
    is_private: Mapped[bool] = mapped_column(Boolean, default=False)
    created_by: Mapped[Optional[str]] = fk("users.id", ondelete="SET NULL", nullable=True)
    created_at: Mapped[datetime] = ts()


class CommunityMember(Base):
    __tablename__ = "community_members"
    community_id: Mapped[str] = fk("communities.id", primary_key=True)
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    role: Mapped[str] = mapped_column(String(12), default="member")          # member | moderator | owner
    status: Mapped[str] = mapped_column(String(10), default="active")        # active | pending (private join request)
    joined_at: Mapped[datetime] = ts()
    __table_args__ = (Index("ix_cm_user", "user_id"),)


class CommunityBan(Base):
    __tablename__ = "community_bans"
    community_id: Mapped[str] = fk("communities.id", primary_key=True)
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    reason: Mapped[Optional[str]] = mapped_column(String(300))
    banned_by: Mapped[Optional[str]] = fk("users.id", ondelete="SET NULL", nullable=True)
    created_at: Mapped[datetime] = ts()


# ── posts, tags, attachments ─────────────────────────────────────────────────────
class Post(Base):
    __tablename__ = "posts"
    __table_args__ = (
        CheckConstraint("post_type in ('question','discussion','project','resource','help_request','announcement')",
                        name="ck_posts_type"),
        Index("ix_posts_community_created", "community_id", "created_at"),
        Index("ix_posts_author", "author_id"),
    )
    id: Mapped[str] = pk()
    author_id: Mapped[str] = fk("users.id")
    community_id: Mapped[str] = fk("communities.id")
    post_type: Mapped[str] = mapped_column(String(16), default="discussion")
    title: Mapped[str] = mapped_column(String(300))
    body: Mapped[str] = mapped_column(Text, default="")
    field: Mapped[Optional[str]] = mapped_column(String(100))
    skill_level: Mapped[Optional[str]] = mapped_column(String(20))
    resource_kind: Mapped[Optional[str]] = mapped_column(String(24))          # pdf | paper | github | article | video | dataset | notebook | project | link
    status: Mapped[str] = mapped_column(String(12), default="open")          # open | answered | resolved
    is_pinned: Mapped[bool] = mapped_column(Boolean, default=False)
    is_removed: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = ts()
    updated_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    last_activity_at: Mapped[datetime] = ts()

    author: Mapped[User] = relationship(foreign_keys=[author_id])
    community: Mapped[Community] = relationship()
    tags: Mapped[list["Tag"]] = relationship(secondary="post_tags", lazy="selectin")
    attachments: Mapped[list["Attachment"]] = relationship(cascade="all, delete-orphan", lazy="selectin")


class Tag(Base):
    __tablename__ = "tags"
    id: Mapped[str] = pk()
    name: Mapped[str] = mapped_column(String(40), unique=True, index=True)


class PostTag(Base):
    __tablename__ = "post_tags"
    post_id: Mapped[str] = fk("posts.id", primary_key=True)
    tag_id: Mapped[str] = fk("tags.id", primary_key=True)


class Attachment(Base):
    __tablename__ = "attachments"
    id: Mapped[str] = pk()
    post_id: Mapped[str] = fk("posts.id", index=True)
    kind: Mapped[str] = mapped_column(String(10))                            # image | file | link
    url: Mapped[str] = mapped_column(String(1000))
    name: Mapped[Optional[str]] = mapped_column(String(255))
    mime: Mapped[Optional[str]] = mapped_column(String(100))
    size: Mapped[Optional[int]] = mapped_column(Integer)


# ── comments / answers ───────────────────────────────────────────────────────────
class Comment(Base):
    __tablename__ = "comments"
    __table_args__ = (Index("ix_comments_post", "post_id", "created_at"),)
    id: Mapped[str] = pk()
    post_id: Mapped[str] = fk("posts.id")
    parent_id: Mapped[Optional[str]] = fk("comments.id", nullable=True, index=True)
    author_id: Mapped[str] = fk("users.id")
    body: Mapped[str] = mapped_column(Text)
    is_answer: Mapped[bool] = mapped_column(Boolean, default=False)          # expert, top-level, on a question
    is_accepted: Mapped[bool] = mapped_column(Boolean, default=False)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False)         # deleted by author
    is_removed: Mapped[bool] = mapped_column(Boolean, default=False)         # removed by a moderator
    created_at: Mapped[datetime] = ts()
    edited_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True))
    author: Mapped[User] = relationship(foreign_keys=[author_id])
    post: Mapped["Post"] = relationship(foreign_keys=[post_id], viewonly=True)


class Vote(Base):
    __tablename__ = "votes"
    __table_args__ = (CheckConstraint("value in (-1, 1)", name="ck_votes_value"),
                      Index("ix_votes_target", "target_type", "target_id"))
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    target_type: Mapped[str] = mapped_column(String(8), primary_key=True)    # post | comment
    target_id: Mapped[str] = mapped_column(Uuid(as_uuid=False), primary_key=True)
    value: Mapped[int] = mapped_column(Integer)


class Reaction(Base):
    __tablename__ = "reactions"
    __table_args__ = (Index("ix_reactions_target", "target_type", "target_id"),)
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    target_type: Mapped[str] = mapped_column(String(8), primary_key=True)
    target_id: Mapped[str] = mapped_column(Uuid(as_uuid=False), primary_key=True)
    emoji: Mapped[str] = mapped_column(String(8), primary_key=True)


class SavedPost(Base):
    __tablename__ = "saved_posts"
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    post_id: Mapped[str] = fk("posts.id", primary_key=True)
    created_at: Mapped[datetime] = ts()


# ── answer quality (separate from question relevance) ────────────────────────────
class AnswerRating(Base):
    __tablename__ = "answer_ratings"
    __table_args__ = (UniqueConstraint("comment_id", "rater_id", name="uq_rating_once"),
                      CheckConstraint("rating between 1 and 5", name="ck_rating_range"))
    id: Mapped[str] = pk()
    comment_id: Mapped[str] = fk("comments.id", index=True)
    rater_id: Mapped[str] = fk("users.id")
    rating: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = ts()
    updated_at: Mapped[datetime] = ts()


class HelpfulVote(Base):
    __tablename__ = "helpful_votes"
    comment_id: Mapped[str] = fk("comments.id", primary_key=True)
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    created_at: Mapped[datetime] = ts()


# ── routing output: question → expert feed ───────────────────────────────────────
class QuestionRelevance(Base):
    __tablename__ = "question_relevance"
    __table_args__ = (Index("ix_qr_expert_status", "expert_id", "status"),)
    post_id: Mapped[str] = fk("posts.id", primary_key=True)
    expert_id: Mapped[str] = fk("users.id", primary_key=True)
    similarity: Mapped[float] = mapped_column(Float)          # raw TF-IDF cosine similarity
    field_score: Mapped[float] = mapped_column(Float, default=0)
    tag_score: Mapped[float] = mapped_column(Float, default=0)
    community_score: Mapped[float] = mapped_column(Float, default=0)
    matched_terms: Mapped[list] = mapped_column(JSONType, default=list)
    status: Mapped[str] = mapped_column(String(10), default="new")   # new | saved | ignored | answered
    routed_at: Mapped[datetime] = ts()


# ── reputation, badges, notifications ────────────────────────────────────────────
class ReputationEvent(Base):
    __tablename__ = "reputation_events"
    id: Mapped[str] = pk()
    user_id: Mapped[str] = fk("users.id", index=True)
    ref_key: Mapped[str] = mapped_column(String(160), unique=True)   # idempotency: one event per source action
    kind: Mapped[str] = mapped_column(String(30))
    points: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = ts()


class UserBadge(Base):
    __tablename__ = "user_badges"
    user_id: Mapped[str] = fk("users.id", primary_key=True)
    badge_key: Mapped[str] = mapped_column(String(40), primary_key=True)
    awarded_at: Mapped[datetime] = ts()


class Notification(Base):
    __tablename__ = "notifications"
    __table_args__ = (Index("ix_notif_user", "user_id", "is_read", "created_at"),)
    id: Mapped[str] = pk()
    user_id: Mapped[str] = fk("users.id")
    type: Mapped[str] = mapped_column(String(30))
    actor_id: Mapped[Optional[str]] = fk("users.id", ondelete="SET NULL", nullable=True)
    post_id: Mapped[Optional[str]] = fk("posts.id", nullable=True)
    comment_id: Mapped[Optional[str]] = fk("comments.id", nullable=True)
    message: Mapped[str] = mapped_column(String(300))
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = ts()
    actor: Mapped[Optional[User]] = relationship(foreign_keys=[actor_id])


# ── moderation ───────────────────────────────────────────────────────────────────
class Report(Base):
    __tablename__ = "reports"
    __table_args__ = (Index("ix_reports_community_status", "community_id", "status"),)
    id: Mapped[str] = pk()
    reporter_id: Mapped[Optional[str]] = fk("users.id", ondelete="SET NULL", nullable=True)  # null = auto-flagged
    target_type: Mapped[str] = mapped_column(String(8))                      # post | comment | user
    target_id: Mapped[str] = mapped_column(Uuid(as_uuid=False))
    community_id: Mapped[Optional[str]] = fk("communities.id", nullable=True)
    reason: Mapped[str] = mapped_column(String(40))
    details: Mapped[Optional[str]] = mapped_column(String(1000))
    status: Mapped[str] = mapped_column(String(12), default="open")          # open | resolved | dismissed
    resolved_by: Mapped[Optional[str]] = fk("users.id", ondelete="SET NULL", nullable=True)
    created_at: Mapped[datetime] = ts()


class UserBlock(Base):
    __tablename__ = "user_blocks"
    blocker_id: Mapped[str] = fk("users.id", primary_key=True)
    blocked_id: Mapped[str] = fk("users.id", primary_key=True)
    created_at: Mapped[datetime] = ts()


# ── translation cache ────────────────────────────────────────────────────────────
class Translation(Base):
    __tablename__ = "translations"
    __table_args__ = (UniqueConstraint("text_hash", "source_lang", "target_lang", "model", name="uq_translation"),)
    id: Mapped[str] = pk()
    text_hash: Mapped[str] = mapped_column(String(64), index=True)
    source_lang: Mapped[str] = mapped_column(String(12))
    target_lang: Mapped[str] = mapped_column(String(12))
    model: Mapped[str] = mapped_column(String(80))
    translated_text: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = ts()
