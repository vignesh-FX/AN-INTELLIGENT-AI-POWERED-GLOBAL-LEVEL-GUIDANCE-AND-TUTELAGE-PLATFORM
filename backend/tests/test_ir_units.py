"""Pure unit tests for the information-retrieval pieces (no DB)."""
from services.quality import ExpertStats, bayesian_rating, quality_score
from services.text import tokenize
from services.tfidf import TfidfModel, cosine


def test_preprocessing_aliases_stopwords_and_stemming():
    t = tokenize("How can I improve Natural Language Processing for my models?")
    assert "nlp" in t and "how" not in t and "improve" in t
    assert "model" in t                      # light stemming: models → model


def test_tfidf_cosine_ranks_relevant_expert_higher_and_is_not_hardcoded():
    docs = {"A": "NLP RAG LLM Transformers embeddings retrieval python",
            "B": "React Node.js UI Design css frontend",
            "C": "cybersecurity penetration testing"}
    m = TfidfModel().fit([tokenize(d) for d in docs.values()])
    q = m.transform(tokenize("How can I improve retrieval quality in my RAG application?"))
    s = {k: cosine(q, m.transform(tokenize(d))) for k, d in docs.items()}
    assert s["A"] > 0.3 and s["B"] == 0 and s["C"] == 0
    other = m.transform(tokenize("How do I center a div in CSS with React?"))
    assert cosine(other, m.transform(tokenize(docs["B"]))) > cosine(other, m.transform(tokenize(docs["A"])))


def test_vectors_are_unit_length_and_cosine_is_symmetric():
    m = TfidfModel().fit([tokenize("python machine learning"), tokenize("react frontend css")])
    a, b = m.transform(tokenize("python machine learning")), m.transform(tokenize("python css"))
    assert abs(sum(v * v for v in a.values()) - 1) < 1e-9
    assert abs(cosine(a, b) - cosine(b, a)) < 1e-12
    assert abs(cosine(a, a) - 1) < 1e-9


def test_bayesian_quality_prevents_small_sample_dominance():
    few = ExpertStats(answers=2, rating_sum=10, rating_count=2, helpful=2, helpful_voters=2, accepted=1, net_votes=2)
    many = ExpertStats(answers=300, rating_sum=2400, rating_count=500, helpful=470, helpful_voters=500, accepted=120, net_votes=900)
    a, b = quality_score(few, 3.8), quality_score(many, 3.8)
    assert a["bayesian_rating"] < b["bayesian_rating"] and a["score"] < b["score"]      # 5.0×2  <  4.8×500
    assert bayesian_rating(10, 2, 3.8, 10) < 4.5      # a perfect 5.0 from 2 ratings is pulled to 4.0
