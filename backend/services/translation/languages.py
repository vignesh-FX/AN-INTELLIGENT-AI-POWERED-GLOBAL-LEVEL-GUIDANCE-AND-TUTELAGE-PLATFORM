"""ISO-639-1 ↔ NLLB-200 (FLORES-200) language codes for the languages the UI offers."""
LANGUAGES: dict[str, tuple[str, str]] = {   # code: (display name, NLLB code)
    "en": ("English", "eng_Latn"), "hi": ("Hindi", "hin_Deva"), "ta": ("Tamil", "tam_Taml"),
    "te": ("Telugu", "tel_Telu"), "kn": ("Kannada", "kan_Knda"), "ml": ("Malayalam", "mal_Mlym"),
    "mr": ("Marathi", "mar_Deva"), "bn": ("Bengali", "ben_Beng"), "gu": ("Gujarati", "guj_Gujr"),
    "pa": ("Punjabi", "pan_Guru"), "ur": ("Urdu", "urd_Arab"), "ne": ("Nepali", "npi_Deva"),
    "si": ("Sinhala", "sin_Sinh"), "ar": ("Arabic", "arb_Arab"), "fa": ("Persian", "pes_Arab"),
    "he": ("Hebrew", "heb_Hebr"), "tr": ("Turkish", "tur_Latn"), "zh": ("Chinese (Simplified)", "zho_Hans"),
    "zh-tw": ("Chinese (Traditional)", "zho_Hant"), "ja": ("Japanese", "jpn_Jpan"), "ko": ("Korean", "kor_Hang"),
    "vi": ("Vietnamese", "vie_Latn"), "th": ("Thai", "tha_Thai"), "id": ("Indonesian", "ind_Latn"),
    "ms": ("Malay", "zsm_Latn"), "tl": ("Filipino", "tgl_Latn"), "es": ("Spanish", "spa_Latn"),
    "fr": ("French", "fra_Latn"), "de": ("German", "deu_Latn"), "pt": ("Portuguese", "por_Latn"),
    "it": ("Italian", "ita_Latn"), "nl": ("Dutch", "nld_Latn"), "pl": ("Polish", "pol_Latn"),
    "ru": ("Russian", "rus_Cyrl"), "uk": ("Ukrainian", "ukr_Cyrl"), "ro": ("Romanian", "ron_Latn"),
    "el": ("Greek", "ell_Grek"), "cs": ("Czech", "ces_Latn"), "sv": ("Swedish", "swe_Latn"),
    "sw": ("Swahili", "swh_Latn"), "am": ("Amharic", "amh_Ethi"), "ha": ("Hausa", "hau_Latn"),
    "yo": ("Yoruba", "yor_Latn"), "zu": ("Zulu", "zul_Latn"),
}

# langdetect output → our codes
DETECT_ALIASES = {"zh-cn": "zh", "zh-tw": "zh-tw", "no": "sv"}


def nllb_code(code: str) -> str:
    try:
        return LANGUAGES[code][1]
    except KeyError:
        raise UnsupportedLanguage(code)


class UnsupportedLanguage(ValueError):
    pass


def language_list() -> list[dict]:
    return [{"code": c, "name": n} for c, (n, _) in LANGUAGES.items()]
