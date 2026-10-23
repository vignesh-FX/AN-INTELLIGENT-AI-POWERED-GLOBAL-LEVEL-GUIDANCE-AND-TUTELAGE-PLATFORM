# GlobalGuru — Global Mentorship & Knowledge-Sharing Platform

**Learners ask questions → TF-IDF + cosine similarity finds relevant expertise → the question lands in those experts' feeds → experts answer → Reddit-style threaded discussion → learners rate answers → expert quality improves.**

Stack (unchanged from the original repo): **FastAPI** · **React + Vite** · **Supabase (Postgres)**.

## Run it

```bash
# 1. Backend
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt            # add requirements-ml.txt for real NLLB-200 translation
cp .env.example .env                       # set DATABASE_URL (Supabase) + SECRET_KEY; leave DATABASE_URL empty for local SQLite
python scripts/seed_demo.py                # OPTIONAL demo data (maya@demo.dev / arun@demo.dev ... password demo12345)
uvicorn main:app --reload --port 8000      # API docs: http://localhost:8000/docs

# 2. Frontend
cd frontend && npm install && npm run dev  # http://localhost:5173 (proxies /api and /uploads to :8000)
```

### Supabase setup
1. Supabase -> **Project Settings -> Database -> Connection string -> URI**. Put it in `DATABASE_URL`. Use the **database password**, not the anon/service keys: the backend talks to Postgres directly. The pooler (port 6543) works and TLS is added automatically.
2. Tables are created automatically on startup, or paste `supabase/schema.sql` into the Supabase SQL editor. That file is generated from the models (`python backend/scripts/generate_schema.py`) so the two cannot drift. RLS is enabled with no policies, so the public Supabase REST API cannot read these tables.

**What was wrong with the original Supabase setup (all fixed):** routes imported an in-memory `mock_db` and never touched Supabase; the client used the anon key; the SQL schema did not match the code; `passlib 1.7.4` crashes with `bcrypt >= 4.1` (now using `bcrypt` directly); `email-validator` was missing; the frontend referenced a non-existent Google font; tokens/AI were mocked.

## How it works
| Concern | Where |
|---|---|
| Two logins/registrations, one auth backend (`user_type`) | `routes/auth.py`, `pages/AuthPages.jsx` |
| Preprocessing -> TF-IDF -> cosine (from scratch, no hardcoded scores) | `services/text.py`, `services/tfidf.py` |
| Question -> expert routing + explainable, configurable feed score | `services/routing.py` (`FEED_WEIGHTS`) |
| Separate concepts: relevance (cosine) / answer rating (1-5) / expert quality (Bayesian) | `services/quality.py` (`QUALITY_WEIGHTS`) |
| Threads, voting, reactions, accepted/best answer, sorting | `routes/posts.py`, `services/content.py`, `components/Thread.jsx` |
| Optimistic UI with rollback + serialized requests | `lib/hooks.jsx` (`useOptimistic`) |
| Translation: langdetect -> NLLB-200 -> cache; code/URLs/technical terms protected | `services/translation/*` |
| Reputation (idempotent events) and behaviour-based badges | `services/reputation.py` |
| Search: keyword + TF-IDF cosine (lexical, not semantic) | `services/search.py` |
| Community moderation, reports, bans, spam/toxicity filters | `routes/communities.py`, `routes/misc.py`, `services/moderation.py` |

Each AI component sits behind a small interface (`TfidfModel`, `SearchIndex`, `TranslationBackend`), so embeddings, a vector DB, or larger/fine-tuned NLLB can replace them without touching routes or UI.

## Tests
```bash
cd backend && pytest -q                                         # 37 tests (SQLite)
TEST_DATABASE_URL=postgresql://user:pw@localhost/db pytest -q   # same suite on Postgres
```

## Honest notes / not included
- **NLLB-200 needs a ~2.4 GB model download** (`pip install -r requirements-ml.txt`; first request downloads `facebook/nllb-200-distilled-600M`). The pipeline, caching and UI are tested with a stand-in backend; the real model could not be downloaded in the build sandbox, so run one real translation on your machine to confirm. Without the dependencies the API returns a clear 503 and never fakes a translation.
- **Google/social login is not implemented** (the original stack had none). Supabase Auth could be added behind `routes/auth.py`.
- Rate limiting is in-process (use Redis for multi-worker). Tokens are JWTs in `localStorage`. Notifications are polled every 30 s (`services/notifications.py` has the hook for WebSockets/Realtime). Uploads go to local disk (`UPLOAD_DIR`); use Supabase Storage in production.
- Match percentages are honest weighted scores, so they are typically lower than a mock "94%".
- Phase 8 items (embeddings, vector DB, messaging, analytics) are intentionally left for after the MVP, as the spec says.

## Deploy from GitHub

This repository includes a Render Blueprint (`render.yaml`) for the React site and FastAPI API. GitHub stores the source; Render builds and hosts the running services.

1. Create a **private** GitHub repository (for example, `globalguru`) and push this project folder to it. Do not upload the parent workspace or the ZIP's virtual environment.
2. In Render, choose **New → Blueprint**, connect that GitHub repository, and select `render.yaml`.
3. When Render asks for `DATABASE_URL`, enter your production PostgreSQL connection string (the Supabase Postgres URI is supported). Do not use a Supabase anon or service-role API key here. Set it in Render's secret environment variable field, not in a committed file.
4. Deploy the Blueprint. The generated `SECRET_KEY` and the frontend/API URLs are wired by the Blueprint. Open the `globalguru-web` URL after both services finish deploying.

The API uses PostgreSQL in production; the bundled SQLite database is local demo data and is ignored by Git. Uploaded files currently live on the API service's local filesystem, so they are not durable across service replacement. Configure persistent object storage before relying on user uploads in production. The optional translation model in `requirements-ml.txt` is not installed by this deployment because it downloads a large model.

For local work, copy `backend/.env.example` to `backend/.env` and follow the development steps above. `.env` files, local databases, virtual environments, and build output are excluded from Git.
