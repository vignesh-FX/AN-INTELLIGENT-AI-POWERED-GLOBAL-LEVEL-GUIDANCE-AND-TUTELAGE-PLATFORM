"""
Expert Quality Score (0–100) — "how consistently helpful is this expert?"
Kept separate from question relevance (TF-IDF) and from a single answer's 1–5 rating.

Small samples are shrunk toward the platform mean (Bayesian average) so that
5.0 from 2 ratings can NOT outrank 4.8 from 500 ratings:

    bayes_rating = (C·m + Σratings) / (C + n)          C = prior count, m = global mean
    helpful      = (helpful + a) / (votes + a + b)     Beta prior (a=7,b=3 → 70%)
    accepted     = (accepted + 1) / (answers + 5)      shrunk toward ~20%
    votes        = squash(net answer upvotes per answer)
    volume       = 1 − exp(−ratings / 25)              more evidence → more weight
"""
import math
from dataclasses import dataclass

from sqlalchemy import case, func, select
from sqlalchemy.orm import Session

from config import settings
from models import AnswerRating, Comment, HelpfulVote, Vote


@dataclass
class ExpertStats:
    answers: int = 0
    rating_sum: int = 0
    rating_count: int = 0
    helpful: int = 0
    helpful_voters: int = 0     # distinct (answer, person) who gave feedback → denominator
    accepted: int = 0
    net_votes: int = 0


def bayesian_rating(rating_sum: float, n: int, prior_mean: float, prior_count: float) -> float:
    return (prior_count * prior_mean + rating_sum) / (prior_count + n)


def quality_score(s: ExpertStats, global_mean: float | None = None) -> dict:
    m = global_mean if global_mean else settings.quality_default_mean
    C = settings.quality_prior_count
    w = settings.quality_weights
    bayes = bayesian_rating(s.rating_sum, s.rating_count, m, C)                  # 1..5
    rating_c = (bayes - 1) / 4
    helpful_c = (s.helpful + 7) / (s.helpful_voters + 10)
    accepted_c = (s.accepted + 1) / (s.answers + 5)
    per_answer = (s.net_votes / s.answers) if s.answers else 0
    votes_c = 1 / (1 + math.exp(-per_answer / 3))                                 # 0.5 at zero votes
    volume_c = 1 - math.exp(-s.rating_count / 25)
    comp = {"rating": rating_c, "helpful": helpful_c, "accepted": accepted_c, "votes": votes_c, "volume": volume_c}
    score = 100 * sum(w[k] * comp[k] for k in comp) / sum(w.values())
    return {
        "score": round(score, 1),
        "bayesian_rating": round(bayes, 2),
        "components": {k: round(v, 3) for k, v in comp.items()},
    }


def global_rating_mean(db: Session) -> float:
    v = db.scalar(select(func.avg(AnswerRating.rating)))
    return float(v) if v else settings.quality_default_mean


def feedback_counts(db: Session, comment_ids: list[str]) -> dict[str, tuple[int, int]]:
    """Per answer → (positive, total) distinct people who gave feedback.
    A person is positive if they clicked "Helpful" or rated it 3★ or more (3★ = "Helpful")."""
    if not comment_ids:
        return {}
    pos: dict[str, set] = {i: set() for i in comment_ids}
    allv: dict[str, set] = {i: set() for i in comment_ids}
    for cid, uid, r in db.execute(select(AnswerRating.comment_id, AnswerRating.rater_id, AnswerRating.rating)
                                  .where(AnswerRating.comment_id.in_(comment_ids))):
        allv[cid].add(uid)
        if r >= 3:
            pos[cid].add(uid)
    for cid, uid in db.execute(select(HelpfulVote.comment_id, HelpfulVote.user_id)
                               .where(HelpfulVote.comment_id.in_(comment_ids))):
        allv[cid].add(uid)
        pos[cid].add(uid)
    return {i: (len(pos[i]), len(allv[i])) for i in comment_ids}


def expert_stats(db: Session, expert_id: str) -> ExpertStats:
    ans = db.execute(select(Comment.id, Comment.is_accepted).where(
        Comment.author_id == expert_id, Comment.is_answer.is_(True),
        Comment.is_deleted.is_(False), Comment.is_removed.is_(False))).all()
    ids = [a[0] for a in ans]
    s = ExpertStats(answers=len(ids), accepted=sum(1 for a in ans if a[1]))
    if not ids:
        return s
    r = db.execute(select(func.coalesce(func.sum(AnswerRating.rating), 0), func.count(AnswerRating.id))
                   .where(AnswerRating.comment_id.in_(ids))).one()
    s.rating_sum, s.rating_count = int(r[0]), int(r[1])
    fb = feedback_counts(db, ids)
    s.helpful = sum(p for p, _ in fb.values())
    s.helpful_voters = sum(t for _, t in fb.values())
    s.net_votes = int(db.scalar(select(func.coalesce(func.sum(Vote.value), 0)).where(
        Vote.target_type == "comment", Vote.target_id.in_(ids))) or 0)
    return s


def expert_quality(db: Session, expert_id: str) -> dict:
    s = expert_stats(db, expert_id)
    q = quality_score(s, global_rating_mean(db))
    avg = (s.rating_sum / s.rating_count) if s.rating_count else None
    return {
        **q, "answers": s.answers, "accepted_answers": s.accepted, "rating_count": s.rating_count,
        "average_rating": round(avg, 2) if avg else None,
        "helpful_percent": round(100 * s.helpful / s.helpful_voters) if s.helpful_voters else None,
    }
