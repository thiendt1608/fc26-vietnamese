"""Shared helpers: TSV reading, KEEP rules, token protection, Lua string escaping."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FILES = ["LanguageStrings1.txt", "LanguageStrings2.txt"]

# ---------- parse ----------
def read_rows():
    rows = []
    for fn in FILES:
        text = (ROOT / "input" / fn).read_bytes().decode("utf-8-sig")  # file 1 has a BOM, file 2 not
        lines = text.split("\r\n")
        if lines[-1] == "":
            lines.pop()
        assert lines[0] == "stringid\tsourcetext\thashid", fn
        for ln in lines[1:]:
            parts = ln.split("\t")
            assert len(parts) == 3, (fn, ln[:80])
            rows.append({"file": fn, "id": parts[0], "src": parts[1], "hash": parts[2]})
    return rows

# ---------- KEEP ----------
KEEP_PREFIX_RE = re.compile(
    r"^(CREDITS_|FrostbiteOpenSourceCredits|FC_OpenSource|FIFA\w*song|FCSong|LICENSEDMUSICFC"
    r"|TeamName|StadiumName|CityName|ColourCommentator|nationname"
    r"|Team_\d+_Neighbourhood|TeamNickname|MainCommentator|FC_TIFONAME|LanguageSelect|FRRB_SERVER"
    r"|FC_AUDIO_(?:NICKNAME|GOAL)|AUDIO_VANITY_NICKNAME)")
POSITIONS = {"GK", "CB", "LB", "RB", "LWB", "RWB", "CDM", "CM", "CAM", "LM", "RM", "LW", "RW",
             "CF", "ST", "LF", "RF", "SW", "WB", "DM", "AM", "FWD", "MID", "DEF", "PC", "XBOX",
             "PAC", "SHO", "PAS", "DRI", "PHY", "OVR", "SUB", "RES"}

def keep_reason(sid, src, protected):
    """Return reason string if the row must be copied unchanged, else None."""
    if KEEP_PREFIX_RE.match(sid):
        return "prefix"
    if src.strip() == "":
        return "empty"
    # letters left once tokens are stripped?
    rest = re.sub(r"⟦\d+⟧", "", protected)
    if not re.search(r"[^\W\d_]", rest):
        return "no-letters"
    if re.fullmatch(r"https?://\S+|www\.\S+", src.strip()):
        return "url"
    if src.strip() in POSITIONS:
        return "abbr"
    return None

# ---------- token protection ----------
TOKEN_RE = re.compile(r"""
    \\\^                                 # escaped literal caret
  | \^COLOR_[A-Z_]+:
  | \^[A-Za-z0-9_]+(?::[^^\s]+)?\^
  | \^
  | \{C:[^}]*\}
  | \{\d+(?:\.\d+)?-\d+(?:\.\d+)?\}
  | \{[cp][0-9a-fx]+\}
  | \{\d+\}
  | <\d+>
  | \[(?:BR|HOLD|PRESS|TIMED|MORE|data\d|scope|domain)\]
  | \#C0[01]F\d\d
  | %\d*[sd]
  | \\r\\n | \\[nrt"]
  | \|(?:\d+\|)?
""", re.VERBOSE)
PH_RE = re.compile(r"⟦(\d+)⟧")

def protect(s):
    toks = []
    def rep(m):
        toks.append(m.group(0))
        return f"⟦{len(toks)}⟧"
    return TOKEN_RE.sub(rep, s), toks

def restore(p, toks):
    return PH_RE.sub(lambda m: toks[int(m.group(1)) - 1], p)

# ---------- dedup key ----------
GENDER_RE = re.compile(r"_(Mgr[MF]{1,2})$")

def prefix_of(sid):
    m = re.match(r"[A-Za-z]+", sid)
    return m.group(0) if m else sid[:4]

def dedup_key(sid, src):
    g = GENDER_RE.search(sid)
    return (g.group(1) if g else "", prefix_of(sid) if len(src.split()) <= 3 else "", src)

# ---------- Lua ----------
def lua_str(text):
    # export escapes -> real control characters (game prints literal "\n" as text)
    text = (text.replace("\\r\\n", "\r\n").replace("\\n", "\n")
                .replace("\\r", "\r").replace("\\t", "\t"))
    text = (text.replace("\\", "\\\\").replace('"', '\\"')
                .replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t"))
    return f'"{text}"'
