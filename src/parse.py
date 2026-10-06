"""Stats + parse round-trip check. Run: python src/parse.py"""
import collections, statistics
from common import *

rows = read_rows()
print("rows", len(rows))
assert len({r["id"] for r in rows}) == len(rows), "duplicate stringid"
assert len({r["hash"] for r in rows}) == len(rows), "duplicate hashid"
src = [r["src"] for r in rows]
print("empty", src.count(""), "unique", len(set(src)))
lens = sorted(map(len, src))
print("median", statistics.median(lens), "p99", lens[int(len(lens) * .99)], "max", lens[-1])

# byte-exact round trip of the reader
for fn in FILES:
    raw = (ROOT / "input" / fn).read_bytes()
    out = "stringid\tsourcetext\thashid\r\n" + "".join(
        f"{r['id']}\t{r['src']}\t{r['hash']}\r\n" for r in rows if r["file"] == fn)
    bom = raw.startswith(b"\xef\xbb\xbf")
    assert out.encode("utf-8-sig" if bom else "utf-8") == raw, fn

c = collections.Counter()
for s in set(src):
    for t in TOKEN_RE.findall(s):
        c[re.sub(r"\d+", "N", t)[:30]] += 1
print("token families:", c.most_common(25))
