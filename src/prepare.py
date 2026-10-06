"""KEEP classification + dedup + token protection -> data/units.jsonl
Run: python src/prepare.py"""
import json, collections
from common import *

rows = read_rows()
units, keys = [], {}
keep = collections.Counter()
keep_ids = []
bad = 0
for r in rows:
    if "⟦" in r["src"] or "⟧" in r["src"]:
        raise SystemExit(f"placeholder char in source: {r['id']}")
    p, toks = protect(r["src"])
    if restore(p, toks) != r["src"]:
        bad += 1
    why = keep_reason(r["id"], r["src"], p)
    if why:
        keep[why] += 1
        keep_ids.append(r["id"])
        continue
    k = dedup_key(r["id"], r["src"])
    if k not in keys:
        keys[k] = {"unit": f"u{len(units) + 1:05d}", "ids": [], "source": r["src"],
                   "protected": p, "tokens": toks}
        units.append(keys[k])
    keys[k]["ids"].append(r["id"])

assert bad == 0, f"{bad} rows fail protect/restore round trip"
assert sum(len(u["ids"]) for u in units) + sum(keep.values()) == len(rows)
with open(ROOT / "data" / "units.jsonl", "w", encoding="utf-8", newline="\n") as f:
    for u in units:
        f.write(json.dumps(u, ensure_ascii=False) + "\n")
(ROOT / "data" / "keep_ids.txt").write_text("\n".join(keep_ids), encoding="utf-8")
print("rows", len(rows), "| keep", dict(keep), "| translate rows", len(rows) - sum(keep.values()),
      "| units", len(units))
print("protect/restore round trip: OK for all rows")
