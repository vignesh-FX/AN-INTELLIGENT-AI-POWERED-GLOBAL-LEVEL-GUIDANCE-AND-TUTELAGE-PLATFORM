"""Central configuration. Everything tunable lives here and can be overridden by env vars."""
import os
import json
import logging
from dotenv import load_dotenv

load_dotenv()
log = logging.getLogger("globalguru.config")

_DEV_SECRET = "dev-only-secret-change-me"


def _bool(name: str, default: bool) -> bool:
    return os.getenv(name, str(default)).strip().lower() in ("1", "true", "yes", "on")


def _json(name: str, default: dict) -> dict:
    raw = os.getenv(name)
    if not raw:
        return default
    try:
        return {**default, **json.loads(raw)}
    except json.JSONDecodeError:
        log.warning("%s is not valid JSON; using defaults", name)
        return default


def normalize_database_url(url: str) -> str:
    """Supabase hands out `postgresql://` / `postgres://` URLs; SQLAlchemy needs a driver name.
    Supabase also requires TLS, so default to sslmode=require for non-local hosts."""
    if not url:
        return "sqlite:///./globalguru.db"
    if url.startswith("postgres://"):
        url = "postgresql://" + url[len("postgres://"):]
    if url.startswith("postgresql://"):
        url = "postgresql+psycopg2://" + url[len("postgresql://"):]
    if url.startswith("postgresql+psycopg2://") and "sslmode=" not in url:
        host_part = url.split("@")[-1]
        if not host_part.startswith(("localhost", "127.0.0.1")):
            url += ("&" if "?" in url else "?") + "sslmode=require"
    return url


class Settings:
    app_env = os.getenv("APP_ENV", "development")
    frontend_url = os.getenv("FRONTEND_URL", "http://localhost:5173")

    # --- auth
    secret_key = os.getenv("SECRET_KEY", _DEV_SECRET)
    jwt_algorithm = os.getenv("ALGORITHM", "HS256")
    token_minutes = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "720"))

    # --- database (Supabase Postgres connection string, or SQLite for quick local dev)
    database_url = normalize_database_url(os.getenv("DATABASE_URL", ""))

    # --- uploads
    upload_dir = os.getenv("UPLOAD_DIR", "./uploads")
    max_upload_mb = int(os.getenv("MAX_UPLOAD_MB", "10"))

    # --- rate limiting (in-memory, per process)
    rate_limit_enabled = _bool("RATE_LIMIT_ENABLED", True)

    # --- question routing (TF-IDF + cosine) --------------------------------------------
    routing_top_k = int(os.getenv("ROUTING_TOP_K", "10"))
    routing_min_similarity = float(os.getenv("ROUTING_MIN_SIMILARITY", "0.05"))
    routing_notify_min_score = float(os.getenv("ROUTING_NOTIFY_MIN_SCORE", "0.30"))
    routing_notify_max = int(os.getenv("ROUTING_NOTIFY_MAX", "5"))
    routing_model_ttl_seconds = int(os.getenv("ROUTING_MODEL_TTL", "300"))
    recency_half_life_hours = float(os.getenv("RECENCY_HALF_LIFE_HOURS", "72"))
    # Final Question Feed Score = weighted sum of components (each in 0..1), then normalised.
    feed_weights = _json("FEED_WEIGHTS", {
        "similarity": 0.50, "field": 0.12, "tag": 0.14,
        "community": 0.08, "recency": 0.10, "activity": 0.06,
    })

    # --- expert quality score ------------------------------------------------------------
    quality_weights = _json("QUALITY_WEIGHTS", {
        "rating": 0.40, "helpful": 0.20, "accepted": 0.20, "votes": 0.10, "volume": 0.10,
    })
    quality_prior_count = float(os.getenv("QUALITY_PRIOR_COUNT", "10"))   # Bayesian "virtual ratings"
    quality_default_mean = float(os.getenv("QUALITY_DEFAULT_MEAN", "3.5"))

    # --- translation ---------------------------------------------------------------------
    translation_model = os.getenv("TRANSLATION_MODEL", "facebook/nllb-200-distilled-600M")
    translation_device = os.getenv("TRANSLATION_DEVICE", "auto")        # auto | cpu | cuda
    translation_max_chars = int(os.getenv("TRANSLATION_MAX_CHARS", "6000"))
    translation_protect_terms = _bool("TRANSLATION_PROTECT_TERMS", True)

    @property
    def is_production(self) -> bool:
        return self.app_env.lower() == "production"

    def validate(self) -> None:
        if self.secret_key == _DEV_SECRET:
            if self.is_production:
                raise RuntimeError("SECRET_KEY must be set in production")
            log.warning("Using the development SECRET_KEY. Set SECRET_KEY before deploying.")


settings = Settings()
