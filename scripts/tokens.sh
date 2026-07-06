#!/bin/bash
# tokens.sh — goal-forge token & cost report (v3.0)
# Parses Claude Code session JSONL (+optional subagent transcripts) from a goal-start
# marker; reports TOTAL tokens+$ then a per-model breakdown (input/output/cache split).
# Prices: platform.claude.com/docs/en/about-claude/pricing (fetched 2026-07-06) — LIST-PRICE ESTIMATE.
# Known limit (documented): JSONL input/output_tokens can be streaming placeholders
# (github.com/anthropics/claude-code/issues/28197) → dedup by requestId, keep max per field;
# cache fields are reliable. Numbers are ESTIMATES, not billing data.
# Usage:
#   tokens.sh mark <session.jsonl> <marker-file>       # record start line
#   tokens.sh report <session.jsonl> <marker-file|0> [extra-transcript-glob ...]
set -euo pipefail
CMD="${1:-}"; shift || true
case "$CMD" in
  mark)
    SES="$1"; MARK="$2"
    { echo "session=$SES"; echo "line=$(grep -c '' "$SES")"; echo "utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"; } > "$MARK"
    echo "marked: $(cat "$MARK" | tr '\n' ' ')" ;;
  report)
    SES="$1"; MARKARG="$2"; shift 2 || true
    if [ -f "$MARKARG" ]; then
      START=$(grep '^line=' "$MARKARG" 2>/dev/null | cut -d= -f2 || true)
      [ -n "$START" ] || START=$(tr -dc '0-9' < "$MARKARG")   # düz-sayı marker da kabul
    else START="$MARKARG"; fi
    [ -n "$START" ] || { echo "HATA: start-line çözülemedi" >&2; exit 1; }
    MARKUTC=""; [ -f "$MARKARG" ] && MARKUTC=$(grep '^utc=' "$MARKARG" 2>/dev/null | cut -d= -f2 || true)
    export GF_MARK_UTC="$MARKUTC"
    python3 - "$SES" "$START" "$@" <<'PYEOF'
import json, sys, glob, os, calendar, time
ses, start = sys.argv[1], int(sys.argv[2])
mark_utc = os.environ.get("GF_MARK_UTC","")
start_ep = calendar.timegm(time.strptime(mark_utc, "%Y-%m-%dT%H:%M:%SZ")) if mark_utc else 0
extra, skipped_old = [], 0
for g in sys.argv[3:]:
    for f in glob.glob(g):
        if start_ep and os.path.isfile(f) and os.path.getmtime(f) < start_ep: skipped_old += 1
        else: extra.append(f)
# price table (USD per MTok): input, output; cache: write5m=1.25x in, write1h=2x in, read=0.1x in
# source: platform.claude.com/docs/en/about-claude/pricing (2026-07-06)
PRICE = {"fable":(10,50), "mythos":(10,50), "opus":(5,25), "sonnet":(2,10), "haiku":(1,5)}
unmatched = set()
def bucket(model):
    m = (model or "").lower()
    for k in PRICE:
        if k in m: return k
    unmatched.add(model or "(boş)")
    return "other"
agg = {}  # bucket -> dict
def add(b, f, v):
    d = agg.setdefault(b, {"in":0,"out":0,"cw5":0,"cw1":0,"cr":0,"msgs":0})
    d[f] += v
def scan(path, main=False):
    seen = {}  # requestId -> per-field max
    n = 0
    with open(path, encoding="utf-8", errors="replace") as fh:
        for i, line in enumerate(fh, 1):
            if main and i <= start: continue
            try: j = json.loads(line)
            except Exception: continue
            if not isinstance(j, dict): continue
            msg = j.get("message")
            if not isinstance(msg, dict): msg = {}
            u = msg.get("usage")
            if j.get("type") != "assistant" or not isinstance(u, dict): continue
            rid = j.get("requestId") or msg.get("id") or f"{path}:{i}"
            cc = u.get("cache_creation") if isinstance(u.get("cache_creation"), dict) else {}
            cw5 = cc.get("ephemeral_5m_input_tokens", None)
            cw1 = cc.get("ephemeral_1h_input_tokens", 0)
            if cw5 is None:
                cw5 = u.get("cache_creation_input_tokens",0) or 0; cw1 = cw1 or 0
            rec = {"model": msg.get("model",""),
                   "in": u.get("input_tokens",0) or 0, "out": u.get("output_tokens",0) or 0,
                   "cw5": cw5 or 0, "cw1": cw1 or 0, "cr": u.get("cache_read_input_tokens",0) or 0}
            if rid in seen:  # dedup: streaming duplicates share requestId → keep per-field max
                for f in ("in","out","cw5","cw1","cr"): seen[rid][f] = max(seen[rid][f], rec[f])
            else:
                seen[rid] = rec; n += 1
    for rec in seen.values():
        b = bucket(rec["model"])
        for f in ("in","out","cw5","cw1","cr"): add(b, f, rec[f])
        add(b, "msgs", 1)
    return n
n_main = scan(ses, main=True)
n_sub = sum(scan(p) for p in extra if os.path.isfile(p))
def cost(b, d):
    pin, pout = PRICE.get(b, (10,50))  # unknown → EN-PAHALI(fable)-fiyatı: gerçek muhafazakârlık
    return (d["in"]*pin + d["out"]*pout + d["cw5"]*pin*1.25 + d["cw1"]*pin*2 + d["cr"]*pin*0.1)/1e6
tot = {"in":0,"out":0,"cw5":0,"cw1":0,"cr":0}; tc = 0.0
rows = []
for b, d in sorted(agg.items(), key=lambda x: -cost(x[0],x[1])):
    c = cost(b,d); tc += c
    for f in tot: tot[f] += d[f]
    rows.append((b,d,c))
tt = sum(tot.values())
print("TOKEN-RAPORU (script-üretimi; TAHMİN — liste-fiyat, fatura değil)")
print(f"TOPLAM: {tt:,} token · ~${tc:.2f}   [in {tot['in']:,} · out {tot['out']:,} · cache-wr {tot['cw5']+tot['cw1']:,} · cache-rd {tot['cr']:,}]")
for b,d,c in rows:
    print(f"  {b:<7} {d['in']+d['out']+d['cw5']+d['cw1']+d['cr']:>12,} tok → ${c:>8.2f}   [in {d['in']:,} · out {d['out']:,} · cw {d['cw5']+d['cw1']:,} · cr {d['cr']:,} · {d['msgs']} mesaj]")
print(f"kapsam: ana-oturum satır>{start} ({n_main} istek) + {len([p for p in extra if os.path.isfile(p)])} subagent-dosya ({n_sub} istek)" + (f" · goal-öncesi {skipped_old} dosya mtime-filtresiyle HARİÇ" if skipped_old else ""))
print("not: in/out streaming-placeholder-riskli (issue#28197) → requestId-dedup uygulandı; cache-alanları güvenilir.")
if unmatched: print(f"UYARI: eşleşmeyen model(ler) 'other'a fable-fiyatıyla yazıldı: {sorted(unmatched)}")
print("fiyat-kaynağı: platform.claude.com/docs/en/about-claude/pricing (2026-07-06)")
PYEOF
    ;;
  *) echo "usage: tokens.sh mark <session.jsonl> <marker> | report <session.jsonl> <marker|start-line> [extra-globs...]"; exit 1 ;;
esac
