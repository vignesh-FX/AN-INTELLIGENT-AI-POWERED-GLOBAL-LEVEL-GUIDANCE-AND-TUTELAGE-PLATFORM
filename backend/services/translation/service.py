"""
Translation pipeline:  text → split out code → protect technical terms → sentence chunks → backend (NLLB-200)
→ restore terms/code → cache.  The original text is never modified; callers always get both.
"""
import hashlib
import re

from sqlalchemy import select
from sqlalchemy.orm import Session

from models import Translation
from config import settings
from .backend import TranslationUnavailable, get_backend
from .languages import LANGUAGES, UnsupportedLanguage, nllb_code

# Terms that are normally kept in English inside technical text. Masked before translation, restored after.
GLOSSARY = [
    "TF-IDF", "RAG", "NLP", "LLM", "LLMs", "GPU", "CPU", "API", "REST", "SQL", "BERT", "GPT", "NLLB", "PyTorch",
    "TensorFlow", "Hugging Face", "Transformers", "Transformer", "Python", "JavaScript", "React", "Node.js", "Docker",
    "GitHub", "Jupyter", "NumPy", "pandas", "scikit-learn", "cosine similarity", "backpropagation", "Backpropagation",
    "fine-tuning", "Fine-tuning", "embeddings", "Embeddings", "vector database", "Vector Database",
]
_GLOSS_RE = re.compile(r"(?<![\w-])(" + "|".join(re.escape(t) for t in sorted(GLOSSARY, key=len, reverse=True)) + r")(?![\w-])")
_CODE_RE = re.compile(r"(```.*?```|`[^`\n]*`|https?://\S+)", re.S)
_SENT_RE = re.compile(r"(?<=[.!?。！？؟।])\s+")


def _chunks(text: str, limit: int = 350) -> list[str]:
    """Split a paragraph into sentence-sized chunks (NLLB is a sentence-level model)."""
    out, cur = [], ""
    for sent in _SENT_RE.split(text.strip()):
        if len(cur) + len(sent) + 1 <= limit:
            cur = f"{cur} {sent}".strip()
        else:
            if cur:
                out.append(cur)
            while len(sent) > limit:                    # very long sentence: hard split on whitespace
                cut = sent.rfind(" ", 0, limit)
                if cut <= 0:
                    cut = limit
                out.append(sent[:cut]); sent = sent[cut:].strip()
            cur = sent
    if cur:
        out.append(cur)
    return out


def _translate_plain(text: str, src: str, tgt: str, backend) -> str:
    """Translate prose (no code). Glossary terms are masked; if the model mangles a placeholder we redo it unmasked."""
    lines = text.split("\n")
    segments: list[tuple[int, str]] = []                # (line index, chunk)
    for i, line in enumerate(lines):
        if line.strip():
            segments += [(i, c) for c in _chunks(line)]
    if not segments:
        return text
    src_n, tgt_n = nllb_code(src), nllb_code(tgt)
    protected: list[list[str]] = []
    masked: list[str] = []
    for _, seg in segments:
        found: list[str] = []
        def sub(m):
            found.append(m.group(1)); return f"[[T{len(found) - 1}]]"
        masked.append(_GLOSS_RE.sub(sub, seg) if settings.translation_protect_terms else seg)
        protected.append(found)
    out = backend.translate_batch(masked, src_n, tgt_n)
    for k, (res, found) in enumerate(zip(out, protected)):
        if not found:
            continue
        if all(f"[[T{j}]]" in res for j in range(len(found))):
            for j, term in enumerate(found):
                res = res.replace(f"[[T{j}]]", term)
            out[k] = res
        else:                                           # placeholder lost → translate this chunk without masking
            out[k] = backend.translate_batch([segments[k][1]], src_n, tgt_n)[0]
    rebuilt = list(lines)
    per_line: dict[int, list[str]] = {}
    for (i, _), res in zip(segments, out):
        per_line.setdefault(i, []).append(res)
    for i, parts in per_line.items():
        lead = re.match(r"\s*", lines[i]).group(0)
        rebuilt[i] = lead + " ".join(parts)
    return "\n".join(rebuilt)


def translate_text(db: Session, text: str, src: str, tgt: str) -> dict:
    if src not in LANGUAGES:
        raise UnsupportedLanguage(src)
    if tgt not in LANGUAGES:
        raise UnsupportedLanguage(tgt)
    if src == tgt:
        return {"translated": text, "cached": False, "model": None}
    text = text.strip()
    if len(text) > settings.translation_max_chars:
        raise ValueError(f"Text is too long to translate (max {settings.translation_max_chars} characters)")
    backend = get_backend()
    h = hashlib.sha256(text.encode("utf-8")).hexdigest()
    hit = db.scalar(select(Translation).where(Translation.text_hash == h, Translation.source_lang == src,
                                              Translation.target_lang == tgt, Translation.model == backend.name))
    if hit:
        return {"translated": hit.translated_text, "cached": True, "model": backend.name}

    pieces = _CODE_RE.split(text)                       # odd indexes are code / URLs → kept verbatim
    result = []
    for idx, piece in enumerate(pieces):
        if idx % 2 == 1 or not piece.strip():
            result.append(piece)
        else:
            lead = piece[: len(piece) - len(piece.lstrip())]
            trail = piece[len(piece.rstrip()):]
            result.append(lead + _translate_plain(piece.strip(), src, tgt, backend) + trail)
    translated = "".join(result)
    db.add(Translation(text_hash=h, source_lang=src, target_lang=tgt, model=backend.name, translated_text=translated))
    db.flush()
    return {"translated": translated, "cached": False, "model": backend.name}
