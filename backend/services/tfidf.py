"""
A from-scratch TF-IDF vectoriser + cosine similarity (classical information retrieval — NOT deep learning).

  tf    = 1 + ln(count)            (sublinear term frequency)
  idf   = ln((1 + N) / (1 + df)) + 1   (smoothed, same convention as scikit-learn)
  vec   = tf * idf, L2-normalised
  cos   = dot(a, b)                (vectors are unit length, so dot == cosine)

Terms that were never seen when fitting are ignored when vectorising (they can't match anything).
The module is deliberately tiny and dependency-free so it can be swapped for sentence-embeddings later:
anything exposing  fit(docs) / transform(tokens) / cosine(a, b)  can replace it.
"""
import math
from collections import Counter
from typing import Iterable

Vector = dict[str, float]


class TfidfModel:
    def __init__(self) -> None:
        self.idf: dict[str, float] = {}
        self.n_docs = 0

    def fit(self, docs: Iterable[list[str]]) -> "TfidfModel":
        df: Counter = Counter()
        n = 0
        for tokens in docs:
            n += 1
            df.update(set(tokens))
        self.n_docs = n
        self.idf = {t: math.log((1 + n) / (1 + d)) + 1.0 for t, d in df.items()}
        return self

    def transform(self, tokens: list[str]) -> Vector:
        counts = Counter(t for t in tokens if t in self.idf)
        vec = {t: (1.0 + math.log(c)) * self.idf[t] for t, c in counts.items()}
        norm = math.sqrt(sum(v * v for v in vec.values()))
        if norm == 0:
            return {}
        return {t: v / norm for t, v in vec.items()}


def cosine(a: Vector, b: Vector) -> float:
    if not a or not b:
        return 0.0
    if len(a) > len(b):
        a, b = b, a
    return float(sum(v * b.get(t, 0.0) for t, v in a.items()))


def top_shared_terms(a: Vector, b: Vector, k: int = 5) -> list[str]:
    """Explainability: which terms contributed most to the similarity (unigrams first)."""
    contrib = {t: v * b[t] for t, v in a.items() if t in b}
    ranked = sorted(contrib, key=contrib.get, reverse=True)
    uni = [t for t in ranked if "_" not in t]
    return (uni + [t for t in ranked if "_" in t])[:k]
