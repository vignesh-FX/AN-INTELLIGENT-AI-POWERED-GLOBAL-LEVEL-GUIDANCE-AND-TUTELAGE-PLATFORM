"""
GlobalGuru API — FastAPI.   Run:  uvicorn main:app --reload --port 8000
"""
import logging
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text

from config import settings
from db import engine, init_db

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")
log = logging.getLogger("globalguru")


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings.validate()
    init_db()                       # idempotent: creates any missing tables (Supabase: also see supabase/schema.sql)
    os.makedirs(settings.upload_dir, exist_ok=True)
    log.info("Database: %s", engine.url.render_as_string(hide_password=True))
    yield


app = FastAPI(title="GlobalGuru API", version="2.0.0",
              description="Learners ask · TF-IDF + cosine routes questions to relevant experts · threaded answers · NLLB-200 translation",
              lifespan=lifespan, docs_url="/docs", redoc_url="/redoc")

app.add_middleware(CORSMiddleware,
                   allow_origins=list({settings.frontend_url, "http://localhost:5173", "http://127.0.0.1:5173"}),
                   allow_credentials=True, allow_methods=["*"], allow_headers=["*"])


@app.middleware("http")
async def security_headers(request, call_next):
    resp: Response = await call_next(request)
    resp.headers.setdefault("X-Content-Type-Options", "nosniff")
    resp.headers.setdefault("Referrer-Policy", "same-origin")
    return resp


from routes import auth, communities, feed, misc, posts, users  # noqa: E402

for r in (auth.router, users.router, communities.router, posts.router, feed.router, misc.router):
    app.include_router(r, prefix="/api")

os.makedirs(settings.upload_dir, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.upload_dir), name="uploads")


@app.get("/api/health")
def health():
    with engine.connect() as c:
        c.execute(text("select 1"))
    return {"status": "healthy", "database": engine.dialect.name}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
