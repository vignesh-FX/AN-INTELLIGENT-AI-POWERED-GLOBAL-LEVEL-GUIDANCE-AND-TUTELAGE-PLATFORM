"""
Translation backends. `NLLBBackend` runs a real pretrained facebook/nllb-200 model through Hugging Face
Transformers (default: facebook/nllb-200-distilled-600M). The interface is tiny so a larger NLLB checkpoint,
a fine-tuned model or a hosted API can be dropped in later by implementing `translate_batch`.
No dictionaries, no string replacement, no fake output: if the model can't load, we raise.
"""
import logging
import threading
from typing import Protocol

from config import settings

log = logging.getLogger("globalguru.translation")


class TranslationUnavailable(RuntimeError):
    pass


class TranslationBackend(Protocol):
    name: str
    def translate_batch(self, texts: list[str], src_nllb: str, tgt_nllb: str) -> list[str]: ...


class NLLBBackend:
    def __init__(self, model_name: str | None = None) -> None:
        self.name = model_name or settings.translation_model
        self._lock = threading.Lock()
        self._tok = None
        self._model = None
        self._device = "cpu"

    def _load(self) -> None:
        if self._model is not None:
            return
        with self._lock:
            if self._model is not None:
                return
            try:
                import torch
                from transformers import AutoModelForSeq2SeqLM, AutoTokenizer
            except ImportError as e:
                raise TranslationUnavailable(
                    "Translation needs the ML dependencies: pip install -r requirements-ml.txt") from e
            try:
                log.info("Loading translation model %s …", self.name)
                tok = AutoTokenizer.from_pretrained(self.name)
                model = AutoModelForSeq2SeqLM.from_pretrained(self.name)
            except Exception as e:  # network / disk / bad name
                raise TranslationUnavailable(f"Could not load translation model '{self.name}': {e}") from e
            dev = settings.translation_device
            if dev == "auto":
                dev = "cuda" if torch.cuda.is_available() else "cpu"
            model.to(dev).eval()
            self._tok, self._model, self._device = tok, model, dev
            log.info("Translation model ready on %s", dev)

    def translate_batch(self, texts: list[str], src_nllb: str, tgt_nllb: str) -> list[str]:
        self._load()
        import torch
        tok, model = self._tok, self._model
        tok.src_lang = src_nllb
        out: list[str] = []
        for i in range(0, len(texts), 8):
            chunk = texts[i:i + 8]
            enc = tok(chunk, return_tensors="pt", padding=True, truncation=True, max_length=256).to(self._device)
            with torch.no_grad():
                gen = model.generate(**enc, forced_bos_token_id=tok.convert_tokens_to_ids(tgt_nllb),
                                     num_beams=4, max_new_tokens=300)
            out.extend(tok.batch_decode(gen, skip_special_tokens=True))
        return out


_backend: TranslationBackend | None = None


def get_backend() -> TranslationBackend:
    global _backend
    if _backend is None:
        _backend = NLLBBackend()
    return _backend


def set_backend(b: TranslationBackend | None) -> None:     # used by tests / alternative deployments
    global _backend
    _backend = b
