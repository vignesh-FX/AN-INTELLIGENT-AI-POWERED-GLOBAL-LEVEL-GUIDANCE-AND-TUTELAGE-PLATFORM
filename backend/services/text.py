"""Text preprocessing for the TF-IDF engine (tokenise → normalise aliases → stop-words → light stemming)."""
import re

# Multi-word phrases / abbreviations collapsed to one canonical token so that
# "natural language processing" and "NLP" are the same term. Extend freely.
ALIASES = {
    "natural language processing": "nlp", "machine learning": "ml", "deep learning": "dl",
    "artificial intelligence": "ai", "large language models": "llm", "large language model": "llm",
    "retrieval augmented generation": "rag", "retrieval-augmented generation": "rag",
    "convolutional neural network": "cnn", "convolutional neural networks": "cnn",
    "neural networks": "neural_network", "neural network": "neural_network",
    "computer vision": "cv", "data science": "datascience", "web development": "webdev",
    "vector database": "vector_db", "vector databases": "vector_db", "vectordb": "vector_db",
    "fine-tuning": "finetune", "fine tuning": "finetune", "finetuning": "finetune", "fine-tune": "finetune",
    "reinforcement learning": "rl", "node.js": "nodejs", "node js": "nodejs", "react.js": "react",
    "reactjs": "react", "c++": "cpp", "c#": "csharp", "tf-idf": "tfidf", "tf idf": "tfidf",
    "cyber security": "cybersecurity", "information security": "cybersecurity",
    "transformers": "transformer", "embeddings": "embedding", "javascript": "js",
    "typescript": "ts", "postgresql": "postgres", "k-means": "kmeans", "pytorch": "torch",
}
_ALIAS_RE = re.compile("|".join(re.escape(k) for k in sorted(ALIASES, key=len, reverse=True)))

STOPWORDS = frozenset("""
a about above after again all also am an and any are as at be because been before being below between both but by
can could did do does doing down during each few for from further had has have having he her here hers him his how
i if in into is it its itself just me more most my myself no nor not of off on once only or other our ours out over
own same she should so some such than that the their theirs them then there these they this those through to too
under until up very was we were what when where which while who whom why will with would you your yours yourself
im ive id dont doesnt cant wont isnt arent please help need want get using use used like make makes made way ways
new best good better one two know thing things work works working want trying try tried really much many anyone
someone something anything hello hi thanks thank question questions answer answers
""".split())

_TOKEN_RE = re.compile(r"[a-z0-9]+(?:[._\-][a-z0-9]+)*")


def _stem(tok: str) -> str:
    """Very light suffix stripper (keeps technical tokens intact)."""
    if len(tok) <= 4 or not tok.isalpha():
        return tok
    for suf, repl in (("ies", "y"), ("sses", "ss"), ("ing", ""), ("edly", ""), ("ed", ""), ("ly", ""), ("es", ""), ("s", "")):
        if tok.endswith(suf) and len(tok) - len(suf) >= 3:
            if suf == "s" and tok.endswith(("ss", "us", "is")):
                return tok
            return tok[: -len(suf)] + repl
    return tok


def tokenize(text: str, bigrams: bool = True) -> list[str]:
    """Return unigram (+ optional bigram) tokens. Bigrams are joined with '_'."""
    if not text:
        return []
    t = text.lower()
    t = _ALIAS_RE.sub(lambda m: " " + ALIASES[m.group(0)] + " ", t)
    raw = _TOKEN_RE.findall(t)
    unigrams: list[str] = []
    for tok in raw:
        parts = [tok] + (re.split(r"[._\-]", tok) if re.search(r"[._\-]", tok) and tok not in ALIASES.values() else [])
        for p in parts:
            if p in STOPWORDS or len(p) < 2 and not p.isdigit():
                continue
            unigrams.append(_stem(p))
    if not bigrams:
        return unigrams
    seq = [_stem(x) for x in raw if x not in STOPWORDS and len(x) > 1]
    return unigrams + [f"{a}_{b}" for a, b in zip(seq, seq[1:]) if a != b]


def normalize_term(text: str) -> str:
    """Normalise a single tag/field label to its stemmed, alias-resolved unigram form."""
    toks = tokenize(text, bigrams=False)
    return "_".join(toks)
