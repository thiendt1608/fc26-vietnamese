"""Prompt, Gemini calls (standard API), validation, finalize.
  python src/translate.py pilot-select
  python src/translate.py pilot-run <model> [<model> ...]
"""
import json, random, re, sys, time, collections
from concurrent.futures import ThreadPoolExecutor
from common import *

SYSTEM = """You are localizing EA SPORTS FC 26 from English into natural Vietnamese, at the quality of an official football video game localization.

Rules:
1. Use the string IDs as context to infer where the text appears (Career Mode dialogue, UI label, tutorial, Ultimate Team, social post, email...).
2. Use the glossary exactly. A glossary value equal to its key means: keep it in English.
3. Follow the style guide (keep-English terms, xưng hô, tone).
4. Keep club, player, league, competition, stadium, brand and licensed product names in their original form. Translate country names into standard Vietnamese names.
5. Placeholders look like ⟦1⟧. Keep every placeholder exactly once. You MAY move numbered placeholders to fit Vietnamese word order. Keep line-break and separator placeholders in their original order.
6. Never output real line breaks or tabs.
7. Never use emoji, emoticons or any pictograph characters (😀 ⚽ 🔥 etc.). Emoji in the source are already protected as placeholders; keep those placeholders and add nothing else.
8. Return exactly one translation per input item, using the same "id". No explanations.

STYLE GUIDE:
{style}

GLOSSARY (JSON):
{glossary}
"""
SCHEMA = {"type": "object", "properties": {"translations": {"type": "array", "items": {
    "type": "object", "properties": {"id": {"type": "string"}, "vi": {"type": "string"}},
    "required": ["id", "vi"]}}}, "required": ["translations"]}

def system_prompt():
    return SYSTEM.format(style=(ROOT / "data/style_guide.md").read_text(encoding="utf-8"),
                         glossary=(ROOT / "data/glossary.json").read_text(encoding="utf-8"))

def load_units():
    return [json.loads(l) for l in open(ROOT / "data/units.jsonl", encoding="utf-8")]

def chunks(units, budget=6000, max_n=100):
    units = sorted(units, key=lambda u: (prefix_of(u["ids"][0]), u["ids"][0]))
    cur, size = [], 0
    for u in units:
        n = len(u["protected"]) + 80
        if cur and (size + n > budget or len(cur) >= max_n):
            yield cur; cur, size = [], 0
        cur.append(u); size += n
    if cur:
        yield cur

def user_msg(chunk):
    return json.dumps({"items": [{"id": u["unit"], "ids": u["ids"][:3], "text": u["protected"]}
                                 for u in chunk]}, ensure_ascii=False)

# ---------- validation ----------
ORDERED = re.compile(r"%[sd]|\\r\\n|\\[nrt]|\||\|\d+\||\{C:.*\}|\{[\d.]+-[\d.]+\}|\[BR\]|\^COLOR_[A-Z_]+:|\^")
META = re.compile(r"(?i)here is|here's the|translation:|bản dịch")
EMOJI = re.compile("[\U0001F000-\U0001FAFF\u2600-\u27BF\u2B00-\u2BFF\u2300-\u23FF\uFE0F\u200D]")

def ordered_seq(p, toks):
    return [toks[int(n) - 1] for n in PH_RE.findall(p) if ORDERED.fullmatch(toks[int(n) - 1])]

def validate(u, vi):
    """-> (problems, flags)"""
    prob, flag = [], []
    if not vi.strip():
        return ["empty"], flag
    if collections.Counter(PH_RE.findall(vi)) != collections.Counter(PH_RE.findall(u["protected"])):
        prob.append("placeholders")
    elif ordered_seq(vi, u["tokens"]) != ordered_seq(u["protected"], u["tokens"]):
        prob.append("ordered-token-order")
    if re.search(r"[\r\n\t]", vi):
        prob.append("real-control-char")
    if META.search(vi) and not META.search(u["source"]):
        prob.append("meta-text")
    if EMOJI.search(vi) and not EMOJI.search(u["source"]):
        prob.append("emoji")
    if "⟦" in PH_RE.sub("", vi) or "⟧" in PH_RE.sub("", vi):
        prob.append("stray-bracket")
    if vi.strip() == u["protected"].strip() and re.search(r"[^\W\d_]", PH_RE.sub("", vi)):
        flag.append("unchanged")
    L = len(PH_RE.sub("", u["protected"]))
    if 0 < L <= 30:
        r = len(PH_RE.sub("", vi)) / L
        if r > 1.6 or r < 0.4:
            flag.append(f"len-ratio-{r:.1f}")
    return prob, flag

def finalize(u, vi):
    letters = [c for c in PH_RE.sub("", u["protected"]) if c.isalpha()]
    if letters and all(c.isupper() for c in letters):
        vi = vi.upper()
    import unicodedata
    return unicodedata.normalize("NFC", restore(vi, u["tokens"]))

# ---------- API ----------
def client():
    from google import genai
    key = next(l.split("=", 1)[1].strip() for l in open(ROOT / ".env") if l.startswith("GEMINI_API_KEY"))
    return genai.Client(api_key=key)

def call(cl, model, chunk, system, level="low"):
    last = None
    for attempt in range(4):
        try:
            r = cl.models.generate_content(model=model, contents=user_msg(chunk), config={
                "system_instruction": system, "response_mime_type": "application/json",
                "response_json_schema": SCHEMA, "thinking_config": {"thinking_level": level}})
            data = json.loads(r.text)
            um = r.usage_metadata
            return {t["id"]: t["vi"] for t in data["translations"]}, (um.prompt_token_count or 0), \
                   ((um.candidates_token_count or 0) + (um.thoughts_token_count or 0))
        except Exception as e:
            last = e; time.sleep(2 ** attempt)
    print("chunk failed:", repr(last)[:200])
    return {}, 0, 0

def run(model, units, out_path, workers=8):
    cl, system = client(), system_prompt()
    result = {}      # unit id -> record
    tin = tout = 0
    todo = units
    for rnd in range(2):                      # round 2 = retry of failed units, smaller chunks
        cs = list(chunks(todo, budget=6000 if rnd == 0 else 1500, max_n=100 if rnd == 0 else 15))
        with ThreadPoolExecutor(workers) as ex:
            outs = list(ex.map(lambda c: call(cl, model, c, system), cs))
        failed = []
        for c, (res, i, o) in zip(cs, outs):
            tin += i; tout += o
            for u in c:
                vi = res.get(u["unit"])
                if vi is None:
                    failed.append(u); continue
                prob, flag = validate(u, vi)
                if prob and rnd == 0:
                    failed.append(u); continue
                status = "failed" if prob else ("flagged" if flag else "ok")
                result[u["unit"]] = {"unit": u["unit"], "ids": u["ids"], "source": u["source"],
                    "vi": finalize(u, vi) if not prob else "", "status": status,
                    "problems": prob, "flags": flag, "model": model}
        todo = failed
        if not todo:
            break
    for u in todo:
        result.setdefault(u["unit"], {"unit": u["unit"], "ids": u["ids"], "source": u["source"],
            "vi": "", "status": "failed", "problems": ["no-response"], "flags": [], "model": model})
    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        for u in units:
            f.write(json.dumps(result[u["unit"]], ensure_ascii=False) + "\n")
    st = collections.Counter(r["status"] for r in result.values())
    print(f"{model}: {dict(st)} | tokens in {tin:,} out {tout:,}")
    return tin, tout

# ---------- pilot ----------
def pilot_select(target=700, seed=7):
    rnd = random.Random(seed)
    units = load_units()
    chosen = {}
    def add(u): chosen[u["unit"]] = u
    # forced: all _Mgr* variants for a few base ids
    bases = collections.defaultdict(list)
    for u in units:
        m = GENDER_RE.search(u["ids"][0])
        if m: bases[u["ids"][0][:m.start()]].append(u)
    for b in rnd.sample([b for b, v in bases.items() if len(v) >= 3], 6):
        for u in bases[b]: add(u)
    # forced: every token family
    fam = ["^A^", "#C0", "[BR]", "{C:", "|", "^COLOR_", "<0>", "{0}", "^cmEmoji", "%d", "%s", "\\r\\n"]
    for f in fam:
        pool = [u for u in units if f in u["source"]]
        for u in rnd.sample(pool, min(8, len(pool))): add(u)
    for sid in ("vb_json_reg_desc", "ControllerPortOne"):
        for u in units:
            if sid in u["ids"]: add(u)
    # forced: nation names, ALL CAPS, very short
    for pool in ([u for u in units if u["ids"][0].startswith("NationName")],
                 [u for u in units if u["source"].isupper() and len(u["source"]) > 3],
                 [u for u in units if len(u["source"].split()) == 1 and not u["source"].isupper()]):
        for u in rnd.sample(pool, min(15, len(pool))): add(u)
    # proportional fill by prefix
    byp = collections.defaultdict(list)
    for u in units: byp[prefix_of(u["ids"][0])].append(u)
    total = len(units)
    for p, v in byp.items():
        k = max(1, round((target - len(chosen)) * len(v) / total)) if len(v) > 30 else 0
        for u in rnd.sample(v, min(k, len(v))): add(u)
    sel = sorted(chosen.values(), key=lambda u: u["unit"])
    json.dump([u["unit"] for u in sel], open(ROOT / "data/pilot_units.json", "w"))
    print("pilot units", len(sel), "ids", sum(len(u["ids"]) for u in sel))

def pilot_units():
    ids = set(json.load(open(ROOT / "data/pilot_units.json")))
    return [u for u in load_units() if u["unit"] in ids]

if __name__ == "__main__":
    if sys.argv[1] == "pilot-select":
        pilot_select()
    elif sys.argv[1] == "pilot-run":
        us = pilot_units()
        for m in sys.argv[2:]:
            run(m, us, ROOT / f"data/pilot_{m}.jsonl")
