"""Language detection: `langdetect` (statistical, character n-gram based) with script heuristics for very short text."""
import re
from typing import Optional

from langdetect import DetectorFactory, detect_langs
from langdetect.lang_detect_exception import LangDetectException

from .languages import DETECT_ALIASES, LANGUAGES

DetectorFactory.seed = 0      # deterministic results

_CODE_BLOCK = re.compile(r"```.*?```|`[^`]*`", re.S)
_URL = re.compile(r"https?://\S+")
_SCRIPTS = [  # (regex, code) — unambiguous single-language scripts
    (r"[\u0B80-\u0BFF]", "ta"), (r"[\u0C00-\u0C7F]", "te"), (r"[\u0C80-\u0CFF]", "kn"), (r"[\u0D00-\u0D7F]", "ml"),
    (r"[\u0980-\u09FF]", "bn"), (r"[\u0A80-\u0AFF]", "gu"), (r"[\u0A00-\u0A7F]", "pa"), (r"[\u0D80-\u0DFF]", "si"),
    (r"[\u3040-\u30FF]", "ja"), (r"[\uAC00-\uD7AF]", "ko"), (r"[\u0E00-\u0E7F]", "th"), (r"[\u0590-\u05FF]", "he"),
    (r"[\u1200-\u137F]", "am"), (r"[\u0370-\u03FF]", "el"),
]


def clean_for_detection(text: str) -> str:
    return _URL.sub(" ", _CODE_BLOCK.sub(" ", text)).strip()


def detect_language(text: str) -> dict:
    """→ {"code": "ta"|None, "confidence": 0..1, "method": ...}. `code` is None when it can't be decided
    or the language isn't one we can translate; the UI then asks the user to pick the source manually."""
    clean = clean_for_detection(text)
    if len(re.findall(r"\w", clean)) < 3:
        return {"code": None, "confidence": 0.0, "method": "too_short"}
    for pattern, code in _SCRIPTS:
        if len(re.findall(pattern, clean)) >= 2:
            return {"code": code, "confidence": 0.98, "method": "script"}
    try:
        ranked = detect_langs(clean)
    except LangDetectException:
        return {"code": None, "confidence": 0.0, "method": "failed"}
    top = ranked[0]
    code = DETECT_ALIASES.get(top.lang, top.lang)
    if code not in LANGUAGES:
        return {"code": None, "confidence": float(top.prob), "method": "unsupported"}
    return {"code": code, "confidence": round(float(top.prob), 3), "method": "langdetect"}
