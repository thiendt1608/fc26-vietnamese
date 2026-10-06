"""Gemini Batch API driver (model gemini-3.1-flash-lite, thinking low).
  python src/batch.py build [--limit N] [--retry] [--jobs K]   # write batches/req_*.jsonl for units without a good translation
  python src/batch.py submit                                    # upload + create jobs -> batches/jobs.json
  python src/batch.py status                                    # print job states
  python src/batch.py fetch                                     # download finished jobs, validate, merge into data/translations.jsonl
  python src/batch.py stats
translations.jsonl is the source of truth; status manual is never overwritten."""
import json, sys, glob, os, collections
from common import *
import translate as T

MODEL = "gemini-3.1-flash-lite"
BDIR = ROOT / "batches"
TR = ROOT / "data" / "translations.jsonl"
GOOD = ("ok", "flagged", "manual")

def arg(name, default=None):
    return sys.argv[sys.argv.index(name) + 1] if name in sys.argv else default

def load_tr():
    return {r["unit"]: r for r in map(json.loads, open(TR, encoding="utf-8"))} if TR.exists() else {}

def save_tr(tr):
    with open(TR, "w", encoding="utf-8", newline="\n") as f:
        for r in sorted(tr.values(), key=lambda r: r["unit"]):
            f.write(json.dumps(r, ensure_ascii=False) + "\n")

def request(chunk, system):
    return {"contents": [{"role": "user", "parts": [{"text": T.user_msg(chunk)}]}],
            "system_instruction": {"parts": [{"text": system}]},
            "generation_config": {"response_mime_type": "application/json",
                                  "response_json_schema": T.SCHEMA,
                                  "thinking_config": {"thinking_level": "low"}}}

def build():
    tr = load_tr()
    retry = "--retry" in sys.argv
    todo = [u for u in T.load_units() if tr.get(u["unit"], {}).get("status") not in GOOD]
    if not retry:   # never re-send what already came back as a (failed) attempt unless --retry
        todo = [u for u in todo if u["unit"] not in tr]
    limit = arg("--limit")
    if limit:
        todo = todo[:int(limit)]
    cs = list(T.chunks(todo, budget=1500 if retry else 6000, max_n=15 if retry else 100))
    jobs = int(arg("--jobs", 1))
    for f in glob.glob(str(BDIR / "req_*.jsonl")) + glob.glob(str(BDIR / "chunks_*.json")):
        os.remove(f)
    system = T.system_prompt()
    per = -(-len(cs) // jobs)
    for j in range(jobs):
        part = cs[j * per:(j + 1) * per]
        if not part:
            break
        keys = {}
        with open(BDIR / f"req_{j + 1:02d}.jsonl", "w", encoding="utf-8", newline="\n") as f:
            for n, c in enumerate(part, 1):
                key = f"j{j + 1}c{n:04d}"
                keys[key] = [u["unit"] for u in c]
                f.write(json.dumps({"key": key, "request": request(c, system)}, ensure_ascii=False) + "\n")
        json.dump(keys, open(BDIR / f"chunks_{j + 1:02d}.json", "w"))
    print(f"{len(todo)} units -> {len(cs)} requests in {min(jobs, len(cs))} job file(s)")

def submit():
    from google.genai import types
    cl = T.client()
    jobs = json.load(open(BDIR / "jobs.json")) if (BDIR / "jobs.json").exists() else {}
    for p in sorted(glob.glob(str(BDIR / "req_*.jsonl"))):
        n = os.path.basename(p)[4:6]
        f = cl.files.upload(file=p, config=types.UploadFileConfig(display_name=f"fc26-{n}", mime_type="jsonl"))
        job = cl.batches.create(model=MODEL, src=f.name, config={"display_name": f"fc26-vi-{n}"})
        jobs[job.name] = {"req": os.path.basename(p), "chunks": f"chunks_{n}.json", "done": False}
        print("submitted", job.name, p)
    json.dump(jobs, open(BDIR / "jobs.json", "w"), indent=1)

def status():
    cl = T.client()
    jobs = json.load(open(BDIR / "jobs.json"))
    for name, j in jobs.items():
        b = cl.batches.get(name=name)
        print(name, b.state.name, "(ingested)" if j["done"] else "")

def text_of(resp):
    parts = resp["candidates"][0]["content"]["parts"]
    return "".join(p.get("text", "") for p in parts if not p.get("thought"))

def fetch():
    cl = T.client()
    jobs = json.load(open(BDIR / "jobs.json"))
    units = {u["unit"]: u for u in T.load_units()}
    tr = load_tr()
    for name, j in jobs.items():
        if j["done"]:
            continue
        b = cl.batches.get(name=name)
        print(name, b.state.name)
        if b.state.name != "JOB_STATE_SUCCEEDED":
            if b.state.name in ("JOB_STATE_FAILED", "JOB_STATE_CANCELLED", "JOB_STATE_EXPIRED"):
                print("  job is dead; run build --retry (units stay missing)")
            continue
        raw = cl.files.download(file=b.dest.file_name)
        (BDIR / f"res_{j['req'][4:6]}.jsonl").write_bytes(raw)
        keys = json.load(open(BDIR / j["chunks"]))
        seen, tin, tout = set(), 0, 0
        for line in raw.decode("utf-8").splitlines():
            if not line.strip():
                continue
            o = json.loads(line)
            key = o["key"]
            seen.add(key)
            res = {}
            if "response" in o:
                try:
                    res = {t["id"]: t["vi"] for t in json.loads(text_of(o["response"]))["translations"]}
                    um = o["response"].get("usageMetadata", {})
                    tin += um.get("promptTokenCount", 0)
                    tout += um.get("candidatesTokenCount", 0) + um.get("thoughtsTokenCount", 0)
                except Exception as e:
                    print("  bad response", key, repr(e)[:100])
            for uid in keys[key]:
                u = units[uid]
                if tr.get(uid, {}).get("status") == "manual":
                    continue
                vi = res.get(uid)
                if vi is None:
                    prob, flag = ["no-response"], []
                else:
                    prob, flag = T.validate(u, vi)
                tr[uid] = {"unit": uid, "ids": u["ids"], "source": u["source"],
                           "vi": T.finalize(u, vi) if not prob else "",
                           "status": "failed" if prob else ("flagged" if flag else "ok"),
                           "problems": prob, "flags": flag, "model": MODEL}
        for key in set(keys) - seen:           # chunk missing from the output file
            for uid in keys[key]:
                if tr.get(uid, {}).get("status") not in GOOD:
                    u = units[uid]
                    tr[uid] = {"unit": uid, "ids": u["ids"], "source": u["source"], "vi": "",
                               "status": "failed", "problems": ["no-response"], "flags": [], "model": MODEL}
        j["done"] = True
        print(f"  ingested; tokens in {tin:,} out {tout:,}")
    json.dump(jobs, open(BDIR / "jobs.json", "w"), indent=1)
    save_tr(tr)
    stats()

def stats():
    tr = load_tr()
    n = len(T.load_units())
    c = collections.Counter(r["status"] for r in tr.values())
    pr = collections.Counter(p for r in tr.values() for p in r["problems"])
    print(f"units {n} | in translations.jsonl {len(tr)} | {dict(c)} | missing {n - len(tr)} | problems {dict(pr)}")

if __name__ == "__main__":
    {"build": build, "submit": submit, "status": status, "fetch": fetch, "stats": stats}[sys.argv[1]]()
