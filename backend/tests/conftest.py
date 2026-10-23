import os
import sys
import tempfile

_tmp = tempfile.mkdtemp()
os.environ.setdefault("DATABASE_URL", os.environ.get("TEST_DATABASE_URL", f"sqlite:///{_tmp}/test.db"))
os.environ["UPLOAD_DIR"] = os.path.join(_tmp, "uploads")
os.environ["RATE_LIMIT_ENABLED"] = "false"
os.environ["SECRET_KEY"] = "test-secret"
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import pytest
from fastapi.testclient import TestClient

from config import settings
import main
from db import Base, engine
from services import routing, search
from services.translation import backend as tbackend


class FakeBackend:
    """Test double standing in for NLLB (the real model needs a ~2.4 GB download). Marks output so tests can
    see the pipeline passed text through the backend; it is only ever used in tests."""
    name = "fake-nllb-for-tests"

    def __init__(self):
        self.calls = 0

    def translate_batch(self, texts, src, tgt):
        self.calls += 1
        return [f"<{tgt}>{t}" for t in texts]


@pytest.fixture()
def client():
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    routing.engine.invalidate()
    search.index.invalidate()
    tbackend.set_backend(None)
    with TestClient(main.app) as c:
        yield c


@pytest.fixture()
def fake_translator():
    b = FakeBackend()
    tbackend.set_backend(b)
    yield b
    tbackend.set_backend(None)


# ── helpers ──────────────────────────────────────────────────────────────────
def auth(token):
    return {"Authorization": f"Bearer {token}"}


def learner(client, name="lena", **kw):
    r = client.post("/api/auth/learner/register", json={
        "name": name.title(), "username": name, "email": f"{name}@x.com", "password": "password123",
        "skills": ["python"], "interests": ["machine learning"], **kw})
    assert r.status_code == 201, r.text
    return auth(r.json()["access_token"]), r.json()["user"]


def expert(client, name="arun", title="NLP Engineer", expertise=("NLP", "RAG", "LLM"), skills=("Transformers", "Python"), **kw):
    r = client.post("/api/auth/expert/register", json={
        "name": name.title(), "username": name, "email": f"{name}@x.com", "password": "password123", "title": title,
        "expertise_areas": list(expertise), "skills": list(skills), "years_experience": 6, **kw})
    assert r.status_code == 201, r.text
    return auth(r.json()["access_token"]), r.json()["user"]


def community(client, h, name="AI & Machine Learning", **kw):
    r = client.post("/api/communities", headers=h, json={"name": name, "description": "NLP, RAG and deep learning", **kw})
    assert r.status_code == 201, r.text
    return r.json()


def ask(client, h, cid, title="How can I improve retrieval quality in my RAG application?",
        body="My chunks are noisy and embeddings return irrelevant passages.", tags=("RAG", "NLP", "LLM", "Python"),
        field="Natural Language Processing"):
    r = client.post("/api/posts", headers=h, json={
        "community_id": cid, "post_type": "question", "title": title, "body": body, "tags": list(tags), "field": field,
        "skill_level": "Beginner"})
    assert r.status_code == 201, r.text
    return r.json()
