"""
DEMO DATA ONLY — never imported by the app. Fills an empty database with a few communities, experts, one learner
and sample questions so you can click around. Everything goes through the real API code paths (real hashing,
real TF-IDF routing), so the data is genuine, just invented.

    cd backend && python scripts/seed_demo.py
Demo logins (password for all: demo12345):  learner → maya@demo.dev   experts → arun@demo.dev, elena@demo.dev, lisa@demo.dev
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from fastapi.testclient import TestClient
import main

PW = "demo12345"
COMMUNITIES = [
    ("AI & Machine Learning", "Models, training, RAG, LLMs and everything AI."),
    ("Python", "Language questions, libraries and best practices."),
    ("Web Development", "Frontend, backend and everything in between."),
    ("Data Science", "Statistics, pandas, visualisation and analysis."),
    ("Career Development", "Interviews, portfolios and growing as an engineer."),
]
EXPERTS = [
    dict(name="Arun Kumar", username="arun", email="arun@demo.dev", title="NLP Research Engineer", organization="Lingua Labs",
         years_experience=8, expertise_areas=["NLP", "RAG", "LLM", "Transformers"], skills=["Python", "PyTorch", "Hugging Face", "Embeddings", "Vector Database"],
         mentoring_areas=["Retrieval systems", "Fine-tuning", "Deep Learning"], biography="I build retrieval and translation systems."),
    dict(name="Elena Vasquez", username="elena", email="elena@demo.dev", title="Data Scientist", organization="Helix Analytics",
         years_experience=12, expertise_areas=["Data Science", "Statistics", "Machine Learning"], skills=["pandas", "scikit-learn", "Python", "Visualization", "Regression"],
         mentoring_areas=["Career in data", "Statistics"], biography="Applied statistics and ML for health data."),
    dict(name="Lisa Chen", username="lisa", email="lisa@demo.dev", title="Senior Frontend Engineer", organization="Pixelworks",
         years_experience=9, expertise_areas=["Web Development", "React", "CSS", "UI Design"], skills=["JavaScript", "TypeScript", "Node.js", "Accessibility"],
         mentoring_areas=["Frontend architecture"], biography="Design systems and accessible UIs."),
]
QUESTIONS = [
    ("AI & Machine Learning", "How can I improve retrieval quality in my RAG application?", "My chunks are noisy and the embeddings return irrelevant passages.", ["RAG", "NLP", "LLM", "Python"], "Natural Language Processing"),
    ("AI & Machine Learning", "Why is my Transformer model overfitting?", "Training loss keeps dropping while validation loss rises after epoch 3.", ["Transformers", "Deep Learning"], "Deep Learning"),
    ("Web Development", "How do I make a React navbar accessible?", "Keyboard users can't reach the dropdown items.", ["react", "css", "accessibility"], "Web Development"),
    ("Data Science", "When should I use regression instead of classification?", "I keep mixing them up in my project.", ["statistics", "regression", "pandas"], "Data Science"),
]

with TestClient(main.app) as c:
    if c.get("/api/communities").json():
        sys.exit("Database already has communities — refusing to seed a non-empty database.")
    hs = {}
    for e in EXPERTS:
        r = c.post("/api/auth/expert/register", json={**e, "password": PW}); r.raise_for_status()
        hs[e["username"]] = {"Authorization": "Bearer " + r.json()["access_token"]}
    r = c.post("/api/auth/learner/register", json={
        "name": "Maya Rao", "username": "maya", "email": "maya@demo.dev", "password": PW, "education": "B.Tech AI & DS",
        "institution": "Demo University", "skills": ["Python"], "interests": ["NLP", "Machine Learning"], "skill_level": "Beginner",
        "learning_goals": "Build a RAG chatbot", "help_topics": ["RAG", "Transformers"], "languages": ["English", "Tamil"]}); r.raise_for_status()
    maya = {"Authorization": "Bearer " + r.json()["access_token"]}
    ids = {}
    for name, desc in COMMUNITIES:
        r = c.post("/api/communities", headers=hs["arun"], json={"name": name, "description": desc}); r.raise_for_status()
        ids[name] = r.json()
        for u in ("elena", "lisa"):
            c.post(f"/api/communities/{r.json()['slug']}/join", headers=hs[u])
        c.post(f"/api/communities/{r.json()['slug']}/join", headers=maya)
    for comm, title, body, tags, field in QUESTIONS:
        r = c.post("/api/posts", headers=maya, json={"community_id": ids[comm]["id"], "post_type": "question", "title": title,
                                                      "body": body, "tags": tags, "field": field, "skill_level": "Beginner"}); r.raise_for_status()
        print(f"  routed to {r.json()['routed_expert_count']} expert(s): {title}")
print("Seeded. Log in as maya@demo.dev / arun@demo.dev etc. — password:", PW)
