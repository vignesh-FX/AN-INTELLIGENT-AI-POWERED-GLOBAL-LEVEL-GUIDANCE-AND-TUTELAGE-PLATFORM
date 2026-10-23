import io

import pytest

from conftest import ask, auth, community, expert, learner
from services.translation.backend import TranslationUnavailable


# ── authentication & role routing ────────────────────────────────────────────
def test_learner_and_expert_auth_flow(client):
    _, lu = learner(client)
    _, eu = expert(client)
    assert lu["user_type"] == "learner" and eu["user_type"] == "expert"
    r = client.post("/api/auth/learner/login", json={"email": "lena@x.com", "password": "password123"})
    assert r.status_code == 200 and r.json()["user"]["user_type"] == "learner"
    r = client.post("/api/auth/expert/login", json={"email": "arun@x.com", "password": "password123"})
    assert r.status_code == 200 and r.json()["user"]["user_type"] == "expert"


def test_wrong_credentials_and_wrong_portal(client):
    learner(client); expert(client)
    assert client.post("/api/auth/learner/login", json={"email": "lena@x.com", "password": "nope-nope"}).status_code == 401
    assert client.post("/api/auth/learner/login", json={"email": "ghost@x.com", "password": "password123"}).status_code == 401
    r = client.post("/api/auth/expert/login", json={"email": "lena@x.com", "password": "password123"})
    assert r.status_code == 403 and "Learner" in r.json()["detail"]
    r = client.post("/api/auth/learner/login", json={"email": "arun@x.com", "password": "password123"})
    assert r.status_code == 403 and "Expert" in r.json()["detail"]


def test_registration_validation_and_uniqueness(client):
    learner(client)
    base = {"name": "X", "username": "other", "email": "other@x.com", "password": "password123"}
    assert client.post("/api/auth/learner/register", json={**base, "email": "lena@x.com"}).status_code == 409
    assert client.post("/api/auth/learner/register", json={**base, "username": "LENA"}).status_code == 409
    assert client.post("/api/auth/learner/register", json={**base, "password": "short"}).status_code == 422
    assert client.post("/api/auth/learner/register", json={**base, "username": "a b"}).status_code == 422
    # expert must declare expertise: it is how questions find them
    assert client.post("/api/auth/expert/register", json={**base, "title": "Eng"}).status_code == 422


def test_auth_required_and_role_enforced(client):
    assert client.get("/api/auth/me").status_code == 401
    assert client.get("/api/feed/expert").status_code == 401
    hl, _ = learner(client)
    assert client.get("/api/feed/expert", headers=hl).status_code == 403          # learners have no expert feed
    assert client.get("/api/auth/me", headers={"Authorization": "Bearer junk"}).status_code == 401


# ── communities ───────────────────────────────────────────────────────────────
def test_community_create_join_leave_and_permissions(client):
    hl, _ = learner(client); he, _ = expert(client)
    c = community(client, he)
    assert c["membership"]["role"] == "owner" and c["member_count"] == 1
    assert client.post("/api/communities", headers=he, json={"name": "AI & Machine Learning"}).status_code == 409
    # learner must join before posting
    r = client.post("/api/posts", headers=hl, json={"community_id": c["id"], "post_type": "discussion", "title": "Hello world"})
    assert r.status_code == 403
    assert client.post(f"/api/communities/{c['slug']}/join", headers=hl).json()["status"] == "active"
    assert client.get(f"/api/communities/{c['slug']}").json()["member_count"] == 2
    assert client.post(f"/api/communities/{c['slug']}/leave", headers=hl).status_code == 204
    assert client.get(f"/api/communities/{c['slug']}").json()["member_count"] == 1
    assert client.post(f"/api/communities/{c['slug']}/leave", headers=he).status_code == 400    # owner can't leave
    assert client.put(f"/api/communities/{c['slug']}", headers=hl, json={"description": "x"}).status_code == 403


def test_private_community_requires_approval_and_hides_content(client):
    he, _ = expert(client); hl, _ = learner(client)
    c = community(client, he, name="Secret Lab", is_private=True)
    assert client.get(f"/api/communities/{c['slug']}", headers=hl).status_code == 404
    assert c["slug"] not in [x["slug"] for x in client.get("/api/communities", headers=hl).json()]
    assert client.post(f"/api/communities/{c['slug']}/join", headers=hl).json()["status"] == "pending"
    assert client.post("/api/posts", headers=hl, json={"community_id": c["id"], "title": "Let me in!"}).status_code == 403
    assert client.post(f"/api/communities/{c['slug']}/requests/lena/approve", headers=he).status_code == 204
    assert client.get(f"/api/communities/{c['slug']}", headers=hl).status_code == 200


def test_moderator_bans_and_removals(client):
    he, _ = expert(client); hl, _ = learner(client)
    c = community(client, he); slug = c["slug"]
    client.post(f"/api/communities/{slug}/join", headers=hl)
    p = client.post("/api/posts", headers=hl, json={"community_id": c["id"], "title": "A discussion post"}).json()
    cm = client.post(f"/api/posts/{p['id']}/comments", headers=hl, json={"body": "my comment"}).json()
    assert client.delete(f"/api/comments/{cm['id']}", headers=he).status_code == 204          # moderator removal
    thread = client.get(f"/api/posts/{p['id']}/comments").json()
    assert thread[0]["is_removed"] and "moderator" in thread[0]["body"]
    assert client.post(f"/api/communities/{slug}/bans", headers=hl, json={"username": "arun"}).status_code == 403
    assert client.post(f"/api/communities/{slug}/bans", headers=he, json={"username": "lena", "reason": "spam"}).status_code == 201
    assert client.post(f"/api/posts/{p['id']}/comments", headers=hl, json={"body": "still here?"}).status_code == 403
    assert client.post(f"/api/communities/{slug}/join", headers=hl).status_code == 403
    assert client.delete(f"/api/communities/{slug}/bans/lena", headers=he).status_code == 204
    assert client.delete(f"/api/posts/{p['id']}", headers=he).status_code == 204
    assert client.get(f"/api/posts/{p['id']}").status_code == 404


# ── questions ────────────────────────────────────────────────────────────────
def test_question_lifecycle_and_who_may_ask(client):
    hl, _ = learner(client); he, _ = expert(client)
    c = community(client, he); client.post(f"/api/communities/{c['slug']}/join", headers=hl)
    r = client.post("/api/posts", headers=he, json={"community_id": c["id"], "post_type": "question", "title": "Experts don't ask"})
    assert r.status_code == 403
    q = ask(client, hl, c["id"])
    assert q["post_type"] == "question" and sorted(q["tags"]) == ["llm", "nlp", "python", "rag"] and q["status"] == "open"
    assert "routed_expert_count" in q
    assert client.get(f"/api/posts/{q['id']}").json()["title"] == q["title"]
    other, _ = learner(client, "mia")
    assert client.put(f"/api/posts/{q['id']}", headers=other, json={"title": "Hijacked title!"}).status_code == 403
    r = client.put(f"/api/posts/{q['id']}", headers=hl, json={"title": "How do I improve RAG retrieval?", "tags": ["rag"]})
    assert r.status_code == 200 and r.json()["tags"] == ["rag"] and r.json()["updated_at"]
    assert client.delete(f"/api/posts/{q['id']}", headers=other).status_code == 403
    assert client.delete(f"/api/posts/{q['id']}", headers=hl).status_code == 204
    assert client.get(f"/api/posts/{q['id']}").status_code == 404


def test_spam_is_blocked_and_toxicity_flagged(client):
    hl, _ = learner(client); he, _ = expert(client)
    c = community(client, he); client.post(f"/api/communities/{c['slug']}/join", headers=hl)
    r = client.post("/api/posts", headers=hl, json={"community_id": c["id"], "title": "Buy now!!! free money here", "post_type": "discussion"})
    assert r.status_code == 422 and "spam" in r.json()["detail"].lower()
    r = client.post("/api/posts", headers=hl, json={"community_id": c["id"], "title": "Only idiot people use tabs", "post_type": "discussion"})
    assert r.status_code == 201                                                             # allowed but flagged to moderators
    reports = client.get(f"/api/communities/{c['slug']}/reports", headers=he).json()
    assert len(reports) == 1 and reports[0]["auto"] is True


# ── routing: question → expert feed ──────────────────────────────────────────
def test_question_routes_to_relevant_expert_only(client):
    hl, _ = learner(client)
    h_nlp, _ = expert(client, "arun")
    h_web, _ = expert(client, "wanda", "Frontend Dev", expertise=("React", "CSS", "UI Design"), skills=("Node.js", "TypeScript"))
    h_sec, _ = expert(client, "sam", "Pentester", expertise=("Cybersecurity",), skills=("Penetration testing",))
    c = community(client, h_nlp); client.post(f"/api/communities/{c['slug']}/join", headers=hl)
    q = ask(client, hl, c["id"])
    assert q["routed_expert_count"] == 1

    feed = client.get("/api/feed/expert", headers=h_nlp).json()
    assert [i["id"] for i in feed["items"]] == [q["id"]]
    m = feed["items"][0]["match"]
    assert m["similarity_percent"] > 20 and m["percent"] > 25 and m["components"]["similarity"] > 0.2
    assert "rag" in m["matched_terms"]
    assert client.get("/api/feed/expert", headers=h_web).json()["items"] == []
    assert client.get("/api/feed/expert", headers=h_sec).json()["items"] == []

    # a web question reaches the web expert, not the NLP expert
    q2 = ask(client, hl, c["id"], "How do I center a div with CSS in React?", "Flexbox is confusing me.", ("react", "css"), "Web Development")
    assert [i["id"] for i in client.get("/api/feed/expert", headers=h_web).json()["items"]] == [q2["id"]]
    assert q2["id"] not in [i["id"] for i in client.get("/api/feed/expert", headers=h_nlp).json()["items"]]


def test_expert_feed_save_ignore_answer_and_late_joining_expert(client):
    hl, _ = learner(client); h1, _ = expert(client, "arun")
    c = community(client, h1); client.post(f"/api/communities/{c['slug']}/join", headers=hl)
    q = ask(client, hl, c["id"])
    assert client.post(f"/api/feed/expert/{q['id']}/status", headers=h1, json={"status": "saved"}).status_code == 204
    f = client.get("/api/feed/expert?status=saved", headers=h1).json()
    assert len(f["items"]) == 1 and f["counts"] == {"new": 0, "saved": 1, "ignored": 0, "answered": 0}
    assert client.post(f"/api/feed/expert/{q['id']}/status", headers=h1, json={"status": "ignored"}).status_code == 204
    assert client.get("/api/feed/expert", headers=h1).json()["items"] == []
    # answering moves it to "answered"
    assert client.post(f"/api/posts/{q['id']}/comments", headers=h1, json={"body": "Try hybrid search."}).status_code == 201
    assert len(client.get("/api/feed/expert?status=answered", headers=h1).json()["items"]) == 1
    # an expert who registers *after* the question was asked still gets it
    h2, _ = expert(client, "bela", "ML Researcher", expertise=("RAG", "Retrieval", "NLP"), skills=("Embeddings",))
    assert [i["id"] for i in client.get("/api/feed/expert", headers=h2).json()["items"]] == [q["id"]]
    # expert profile edit re-computes feeds
    r = client.put("/api/me/profile", headers=h2, json={"expertise_areas": ["Gardening"], "skills": ["Soil"], "mentoring_areas": []})
    assert r.status_code == 200
    assert client.get("/api/feed/expert", headers=h2).json()["items"] == []


# ── threading, voting, reactions ─────────────────────────────────────────────
def _setup_question(client):
    hl, lu = learner(client); he, eu = expert(client)
    c = community(client, he); client.post(f"/api/communities/{c['slug']}/join", headers=hl)
    return hl, lu, he, eu, c, ask(client, hl, c["id"])


def test_nested_threads_sorting_collapse_data_and_answer_flag(client):
    hl, lu, he, eu, c, q = _setup_question(client)
    pid = q["id"]
    a1 = client.post(f"/api/posts/{pid}/comments", headers=he, json={"body": "Answer one"}).json()
    assert a1["is_answer"] is True
    r1 = client.post(f"/api/posts/{pid}/comments", headers=hl, json={"body": "Thanks, but why?", "parent_id": a1["id"]}).json()
    r2 = client.post(f"/api/posts/{pid}/comments", headers=he, json={"body": "Because X", "parent_id": r1["id"]}).json()
    r3 = client.post(f"/api/posts/{pid}/comments", headers=hl, json={"body": "Got it", "parent_id": r2["id"]}).json()
    a2 = client.post(f"/api/posts/{pid}/comments", headers=he, json={"body": "Another angle"}).json()
    assert not r1["is_answer"] and not r2["is_answer"]                  # replies are never "answers"
    tree = client.get(f"/api/posts/{pid}/comments").json()
    top = {n["id"]: n for n in tree}
    assert set(top) == {a1["id"], a2["id"]} and top[a1["id"]]["reply_count"] == 3
    assert top[a1["id"]]["children"][0]["children"][0]["children"][0]["id"] == r3["id"]       # 3 levels deep
    assert [n["id"] for n in client.get(f"/api/posts/{pid}/comments?sort=active").json()][0] == a1["id"]
    assert [n["id"] for n in client.get(f"/api/posts/{pid}/comments?sort=newest").json()][0] == a2["id"]
    assert client.get(f"/api/posts/{pid}/comments?sort=bogus").status_code == 422
    assert client.get(f"/api/posts/{pid}").json()["comment_count"] == 5 and client.get(f"/api/posts/{pid}").json()["answer_count"] == 2
    # edit / delete keep the thread intact
    assert client.put(f"/api/comments/{r1['id']}", headers=he, json={"body": "hack"}).status_code == 403
    assert client.put(f"/api/comments/{r1['id']}", headers=hl, json={"body": "Thanks! Why exactly?"}).json()["edited_at"]
    assert client.delete(f"/api/comments/{r1['id']}", headers=hl).status_code == 204
    tree = client.get(f"/api/posts/{pid}/comments").json()
    gone = tree[0]["children"][0] if tree[0]["id"] == a1["id"] else tree[1]["children"][0]
    assert gone["body"] == "[deleted]" and gone["author"] is None and len(gone["children"]) == 1


def test_learner_top_level_comment_is_not_an_answer_and_replies_notify(client):
    hl, lu, he, eu, c, q = _setup_question(client)
    other, _ = learner(client, "mia"); client.post(f"/api/communities/{c['slug']}/join", headers=other)
    cm = client.post(f"/api/posts/{q['id']}/comments", headers=other, json={"body": "Same problem here"}).json()
    assert cm["is_answer"] is False
    assert client.post(f"/api/posts/{q['id']}/comments", headers=hl, json={"body": "bad", "parent_id": "not-a-uuid"}).status_code == 404
    ans = client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": "Use reranking"}).json()
    types = [n["type"] for n in client.get("/api/notifications", headers=hl).json()]
    assert "answer" in types
    client.post(f"/api/posts/{q['id']}/comments", headers=hl, json={"body": "@arun can you elaborate?", "parent_id": ans["id"]})
    types = [n["type"] for n in client.get("/api/notifications", headers=he).json()]
    assert "reply" in types or "mention" in types
    assert client.get("/api/notifications/unread-count", headers=he).json()["count"] >= 1
    assert client.post("/api/notifications/read-all", headers=he).status_code == 204
    assert client.get("/api/notifications/unread-count", headers=he).json()["count"] == 0


def test_votes_reputation_and_self_vote(client):
    hl, lu, he, eu, c, q = _setup_question(client)
    ans = client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": "Answer"}).json()
    assert client.post("/api/votes", headers=he, json={"target_type": "comment", "target_id": ans["id"], "value": 1}).status_code == 400
    r = client.post("/api/votes", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "value": 1}).json()
    assert r == {"score": 1, "my_vote": 1}
    assert client.post("/api/votes", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "value": 1}).json()["score"] == 1   # idempotent
    assert client.get(f"/api/users/arun").json()["reputation"] == 2
    assert client.post("/api/votes", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "value": -1}).json()["score"] == -1
    assert client.get(f"/api/users/arun").json()["reputation"] == 0                     # floor at 0, event replaced not stacked
    assert client.post("/api/votes", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "value": 0}).json()["score"] == 0
    # post voting
    other, _ = learner(client, "mia"); client.post(f"/api/communities/{c['slug']}/join", headers=other)
    assert client.post("/api/votes", headers=other, json={"target_type": "post", "target_id": q["id"], "value": 1}).json()["score"] == 1
    assert client.get(f"/api/posts/{q['id']}", headers=other).json()["my_vote"] == 1
    assert client.get(f"/api/posts/{q['id']}").json()["my_vote"] == 0


def test_reactions_toggle(client):
    hl, lu, he, eu, c, q = _setup_question(client)
    r = client.post("/api/reactions", headers=he, json={"target_type": "post", "target_id": q["id"], "emoji": "💡"}).json()
    assert r == {"reactions": {"💡": 1}, "my_reactions": ["💡"]}
    assert client.post("/api/reactions", headers=hl, json={"target_type": "post", "target_id": q["id"], "emoji": "💡"}).json()["reactions"] == {"💡": 2}
    assert client.post("/api/reactions", headers=he, json={"target_type": "post", "target_id": q["id"], "emoji": "💡"}).json()["reactions"] == {"💡": 1}
    assert client.post("/api/reactions", headers=he, json={"target_type": "post", "target_id": q["id"], "emoji": "💀"}).status_code == 422


def test_save_and_unsave(client):
    hl, lu, he, eu, c, q = _setup_question(client)
    assert client.post(f"/api/posts/{q['id']}/save", headers=he).status_code == 204
    assert client.post(f"/api/posts/{q['id']}/save", headers=he).status_code == 204          # idempotent
    assert [p["id"] for p in client.get("/api/me/saved", headers=he).json()] == [q["id"]]
    assert client.get(f"/api/posts/{q['id']}", headers=he).json()["saved"] is True
    assert client.delete(f"/api/posts/{q['id']}/save", headers=he).status_code == 204
    assert client.get("/api/me/saved", headers=he).json() == []


# ── answer quality ───────────────────────────────────────────────────────────
def test_rating_rules_and_aggregates(client):
    hl, lu, he, eu, c, q = _setup_question(client)
    ans = client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": "Use hybrid search"}).json()
    aid = ans["id"]
    assert client.put(f"/api/comments/{aid}/rating", headers=he, json={"rating": 5}).status_code == 403       # not own answer
    assert client.put(f"/api/comments/{aid}/rating", headers=hl, json={"rating": 6}).status_code == 422
    assert client.put(f"/api/comments/{aid}/rating", headers=hl, json={"rating": 3}).json()["rating"] == {"average": 3.0, "count": 1, "mine": 3}
    r = client.put(f"/api/comments/{aid}/rating", headers=hl, json={"rating": 5}).json()               # change, don't duplicate
    assert r["rating"] == {"average": 5.0, "count": 1, "mine": 5}
    m1, _ = learner(client, "mia"); m2, _ = learner(client, "noah")
    client.put(f"/api/comments/{aid}/rating", headers=m1, json={"rating": 4})
    r = client.put(f"/api/comments/{aid}/rating", headers=m2, json={"rating": 3}).json()
    assert r["rating"]["count"] == 3 and r["rating"]["average"] == 4.0
    thread = client.get(f"/api/posts/{q['id']}/comments", headers=hl).json()
    assert thread[0]["rating"] == {"average": 4.0, "count": 3, "mine": 5}
    assert thread[0]["helpful"]["percent"] == 100
    # helpful toggle + aggregates
    assert client.post(f"/api/comments/{aid}/helpful", headers=m1, json={"value": True}).json()["helpful"]["count"] == 1
    assert client.post(f"/api/comments/{aid}/helpful", headers=m1, json={"value": True}).json()["helpful"]["count"] == 1   # idempotent
    assert client.post(f"/api/comments/{aid}/helpful", headers=m1, json={"value": False}).json()["helpful"]["count"] == 0
    # removing a rating
    assert client.delete(f"/api/comments/{aid}/rating", headers=m2).json()["rating"]["count"] == 2
    # replies / learner comments can't be rated
    reply = client.post(f"/api/posts/{q['id']}/comments", headers=hl, json={"body": "thx", "parent_id": aid}).json()
    assert client.put(f"/api/comments/{reply['id']}/rating", headers=m1, json={"rating": 5}).status_code == 400
    # expert quality score surfaces on the profile, separate from relevance
    prof = client.get("/api/users/arun").json()
    assert prof["quality"]["rating_count"] == 2 and prof["quality"]["average_rating"] == 4.5
    assert 0 < prof["quality"]["score"] < 100


def test_accept_answer_reputation_and_best_answer(client):
    hl, lu, he, eu, c, q = _setup_question(client)
    h2, _ = expert(client, "bela", "RAG researcher", expertise=("RAG",))
    a1 = client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": "Answer one"}).json()
    a2 = client.post(f"/api/posts/{q['id']}/comments", headers=h2, json={"body": "Answer two"}).json()
    assert client.post(f"/api/comments/{a1['id']}/accept", headers=he).status_code == 403          # only the asker accepts
    assert client.post(f"/api/comments/{a1['id']}/accept", headers=hl).json() == {"is_accepted": True, "post_status": "resolved"}
    assert client.get("/api/users/arun").json()["reputation"] == 15
    r = client.post(f"/api/comments/{a2['id']}/accept", headers=hl).json()                          # switching moves the check mark
    assert r["is_accepted"] and client.get("/api/users/arun").json()["reputation"] == 0
    assert client.get("/api/users/bela").json()["reputation"] == 15
    tree = {n["id"]: n for n in client.get(f"/api/posts/{q['id']}/comments").json()}
    assert tree[a2["id"]]["is_accepted"] and not tree[a1["id"]]["is_accepted"]
    assert client.get(f"/api/posts/{q['id']}/comments").json()[0]["id"] == a2["id"]                 # accepted first under "best"
    assert client.post(f"/api/comments/{a2['id']}/accept", headers=hl).json()["post_status"] == "answered"   # un-accept
    # rating an answer cannot be gamed by hammering the same endpoint
    for _ in range(5):
        client.put(f"/api/comments/{a1['id']}/rating", headers=hl, json={"rating": 5})
    assert client.get("/api/users/arun").json()["reputation"] == 3


def test_badges_are_earned_from_behaviour(client):
    hl, lu, he, eu, c, _ = _setup_question(client)
    assert client.get("/api/users/arun").json()["badges"] == []
    for i in range(3):
        q = ask(client, hl, c["id"], f"Question number {i} about RAG pipelines?", "details here please", ("nlp", "rag"))
        client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": f"Answer {i} with details"})
    labels = [b["label"] for b in client.get("/api/users/arun").json()["badges"]]
    assert "NLP Expert" in labels and "Top Answerer" not in labels


# ── translation ──────────────────────────────────────────────────────────────
def test_translate_comment_with_detection_cache_and_original_preserved(client, fake_translator):
    hl, lu, he, eu, c, q = _setup_question(client)
    ans = client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": "You should use cosine similarity. It works well."}).json()
    r = client.post("/api/translate", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "target_lang": "ta"}).json()
    assert r["status"] == "ok" and r["source_lang"] == "en" and r["detected"]["code"] == "en"
    assert r["original"]["body"] == "You should use cosine similarity. It works well."
    assert r["translated"]["body"].startswith("<tam_Taml>") and r["cached"] is False
    calls = fake_translator.calls
    r2 = client.post("/api/translate", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "target_lang": "ta"}).json()
    assert r2["cached"] is True and r2["translated"] == r["translated"] and fake_translator.calls == calls     # served from DB cache
    assert client.get(f"/api/posts/{q['id']}/comments").json()[0]["body"] == "You should use cosine similarity. It works well."  # never replaced


def test_translate_post_title_and_body_protects_technical_terms(client, fake_translator):
    hl, lu, he, eu, c, q = _setup_question(client)
    r = client.post("/api/translate", headers=hl, json={"target_type": "post", "target_id": q["id"], "target_lang": "hi"}).json()
    assert set(r["translated"]) == {"title", "body"}
    assert "RAG" in r["translated"]["title"]                                          # glossary term survives masking round-trip
    assert "[[T" not in r["translated"]["title"]


def test_translate_code_blocks_are_left_alone(client, fake_translator):
    hl, lu, he, eu, c, q = _setup_question(client)
    ans = client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": "Run this command:\n```python\nprint('hi')\n```\nThen check the output."}).json()
    r = client.post("/api/translate", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "target_lang": "es"}).json()
    assert "```python\nprint('hi')\n```" in r["translated"]["body"]


def test_translate_manual_source_same_language_and_errors(client, fake_translator):
    hl, lu, he, eu, c, q = _setup_question(client)
    ans = client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": "ok"}).json()
    r = client.post("/api/translate", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "target_lang": "fr"}).json()
    assert r["status"] == "needs_source"                                             # too short to detect → ask the user
    r = client.post("/api/translate", headers=hl, json={"target_type": "comment", "target_id": ans["id"], "target_lang": "fr", "source_lang": "en"}).json()
    assert r["status"] == "ok" and r["source_lang"] == "en"
    r = client.post("/api/translate", headers=hl, json={"target_type": "post", "target_id": q["id"], "target_lang": "en"}).json()
    assert r["status"] == "same_language"
    assert client.post("/api/translate", headers=hl, json={"target_type": "post", "target_id": q["id"], "target_lang": "xx"}).status_code == 422
    assert client.post("/api/translate", json={"target_type": "post", "target_id": q["id"], "target_lang": "fr"}).status_code == 401
    assert len(client.get("/api/translate/languages").json()) > 30


def test_translation_unavailable_is_reported_not_faked(client):
    from services.translation import backend as tb

    class Broken:
        name = "broken"
        def translate_batch(self, *a):
            raise TranslationUnavailable("model not installed")
    tb.set_backend(Broken())
    try:
        hl, lu, he, eu, c, q = _setup_question(client)
        r = client.post("/api/translate", headers=hl, json={"target_type": "post", "target_id": q["id"], "target_lang": "ta"})
        assert r.status_code == 503 and "model not installed" in r.json()["detail"]
    finally:
        tb.set_backend(None)


def test_nllb_backend_without_ml_deps_raises_clear_error(client):
    from services.translation.backend import NLLBBackend
    try:
        import transformers  # noqa
        pytest.skip("transformers installed")
    except ImportError:
        with pytest.raises(TranslationUnavailable) as e:
            NLLBBackend().translate_batch(["hi"], "eng_Latn", "tam_Taml")
        assert "requirements-ml" in str(e.value)


# ── search, feed, reports, uploads ───────────────────────────────────────────
def test_search_ranks_by_tfidf_and_respects_private_communities(client):
    hl, _ = learner(client); he, _ = expert(client)
    c = community(client, he); client.post(f"/api/communities/{c['slug']}/join", headers=hl)
    ask(client, hl, c["id"])
    ask(client, hl, c["id"], "Best way to style a React navbar with CSS?", "Looking for tips.", ("react", "css"), "Web Development")
    r = client.get("/api/search?q=RAG retrieval embeddings", headers=hl).json()
    assert r["questions"] and "RAG" in r["questions"][0]["title"]
    assert r["method"].startswith("keyword + TF-IDF")
    assert [u["username"] for u in client.get("/api/search?q=NLP RAG&type=experts").json()["users"]] == ["arun"]
    assert client.get("/api/search?q=AI Machine Learning&type=communities").json()["communities"]
    priv = community(client, he, name="Hidden Research", is_private=True)
    hp = client.post("/api/posts", headers=he, json={"community_id": priv["id"], "title": "Unpublished transformer results", "post_type": "discussion"})
    assert hp.status_code == 201
    assert client.get("/api/search?q=transformer results", headers=hl).json()["discussions"] == []
    assert len(client.get("/api/search?q=transformer results", headers=he).json()["discussions"]) == 1
    assert client.get("/api/search?q=a").status_code == 422


def test_home_feed_trending_and_recommended_communities(client):
    hl, _ = learner(client); he, _ = expert(client)
    c1 = community(client, he); community(client, he, name="Gardening Club")
    feed = client.get("/api/feed/home", headers=hl).json()
    assert feed["joined_any"] is False
    client.post(f"/api/communities/{c1['slug']}/join", headers=hl)
    q = ask(client, hl, c1["id"])
    feed = client.get("/api/feed/home", headers=hl).json()
    assert feed["joined_any"] and [p["id"] for p in feed["items"]] == [q["id"]]
    assert [p["id"] for p in client.get("/api/feed/trending").json()] == [q["id"]]
    assert client.get("/api/communities/recommended", headers=he).json() == []        # owns both: nothing left to offer
    rec = [r["slug"] for r in client.get("/api/communities/recommended", headers=hl).json()]
    assert rec == ["gardening-club"]                                                  # joined communities are never re-offered


def test_reports_and_moderator_resolution(client):
    hl, _ = learner(client); he, _ = expert(client); h3, _ = learner(client, "mia")
    c = community(client, he)
    for h in (hl, h3):
        client.post(f"/api/communities/{c['slug']}/join", headers=h)
    p = client.post("/api/posts", headers=hl, json={"community_id": c["id"], "title": "Some questionable post"}).json()
    assert client.post("/api/reports", headers=hl, json={"target_type": "post", "target_id": p["id"], "reason": "spam"}).status_code == 400
    r = client.post("/api/reports", headers=h3, json={"target_type": "post", "target_id": p["id"], "reason": "spam"})
    assert r.status_code == 201
    assert client.post("/api/reports", headers=h3, json={"target_type": "post", "target_id": p["id"], "reason": "spam"}).json()["duplicate"]
    assert client.get(f"/api/communities/{c['slug']}/reports", headers=h3).status_code == 403
    queue = client.get(f"/api/communities/{c['slug']}/reports", headers=he).json()
    assert len(queue) == 1 and queue[0]["preview"]["title"] == "Some questionable post"
    assert client.post(f"/api/reports/{queue[0]['id']}/resolve", headers=he, json={"action": "remove_content"}).status_code == 204
    assert client.get(f"/api/posts/{p['id']}").status_code == 404
    assert client.get(f"/api/communities/{c['slug']}/reports", headers=he).json() == []


def test_block_user_hides_in_thread_flag(client):
    hl, lu, he, eu, c, q = _setup_question(client)
    client.post(f"/api/posts/{q['id']}/comments", headers=he, json={"body": "answer"})
    assert client.post(f"/api/users/{eu['id']}/block", headers=hl).status_code == 204
    assert client.get(f"/api/posts/{q['id']}/comments", headers=hl).json()[0]["blocked"] is True
    assert client.get(f"/api/posts/{q['id']}/comments").json()[0]["blocked"] is False
    assert client.post(f"/api/users/{lu['id']}/block", headers=hl).status_code == 400
    assert client.delete(f"/api/users/{eu['id']}/block", headers=hl).status_code == 204
    assert client.get(f"/api/posts/{q['id']}/comments", headers=hl).json()[0]["blocked"] is False


PNG = b"\x89PNG\r\n\x1a\n" + b"\x00" * 64


def test_upload_validation(client):
    hl, _ = learner(client)
    ok = client.post("/api/uploads", headers=hl, files={"file": ("pic.png", PNG, "image/png")})
    assert ok.status_code == 201 and ok.json()["url"].startswith("/uploads/") and ok.json()["kind"] == "image"
    assert client.get(ok.json()["url"]).content == PNG
    assert client.post("/api/uploads", headers=hl, files={"file": ("evil.exe", b"MZ..", "application/octet-stream")}).status_code == 415
    assert client.post("/api/uploads", headers=hl, files={"file": ("fake.png", b"not an image", "image/png")}).status_code == 415
    assert client.post("/api/uploads", files={"file": ("pic.png", PNG, "image/png")}).status_code == 401


def test_resource_posts_and_attachments(client):
    hl, _ = learner(client); he, _ = expert(client)
    c = community(client, he); client.post(f"/api/communities/{c['slug']}/join", headers=hl)
    assert client.post("/api/posts", headers=he, json={"community_id": c["id"], "post_type": "resource", "title": "Great NLP course"}).status_code == 422
    r = client.post("/api/posts", headers=he, json={"community_id": c["id"], "post_type": "resource", "title": "Great NLP course",
                                                     "resource_kind": "github", "attachments": [{"kind": "link", "url": "https://github.com/x/y", "name": "repo"}]})
    assert r.status_code == 201 and r.json()["resource_kind"] == "github" and r.json()["attachments"][0]["url"] == "https://github.com/x/y"
    assert client.post("/api/posts", headers=he, json={"community_id": c["id"], "post_type": "resource", "title": "Bad link here",
                                                        "attachments": [{"kind": "link", "url": "javascript:alert(1)"}]}).status_code == 422
    # resources use the same threaded discussion
    assert client.post(f"/api/posts/{r.json()['id']}/comments", headers=hl, json={"body": "Thanks for sharing"}).status_code == 201
    assert client.post("/api/posts", headers=hl, json={"community_id": c["id"], "post_type": "announcement", "title": "Not allowed"}).status_code == 403
    a = client.post("/api/posts", headers=he, json={"community_id": c["id"], "post_type": "announcement", "title": "Welcome everyone!"})
    assert a.status_code == 201 and a.json()["is_pinned"]
    assert "announcement" in [n["type"] for n in client.get("/api/notifications", headers=hl).json()]


def test_rate_limit_triggers(client):
    from config import settings
    from security import reset_rate_limits
    settings.rate_limit_enabled = True; reset_rate_limits()
    try:
        codes = [client.post("/api/auth/learner/login", json={"email": "a@b.co", "password": "whatever1"}).status_code for _ in range(12)]
        assert 429 in codes and codes[0] == 401
    finally:
        settings.rate_limit_enabled = False; reset_rate_limits()


def test_password_hashing_handles_long_passwords():
    from security import hash_password, verify_password
    pw = "x" * 200
    assert verify_password(pw, hash_password(pw)) and not verify_password(pw[:-1], hash_password(pw))
