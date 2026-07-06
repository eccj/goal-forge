#!/bin/bash
# lint.sh — mechanical LINT scorer for compiled /goal drafts (v3.0).
# Scores the MECHANICAL subset of LINT.md (/100, threshold 80). Semantic criteria
# (Goodhart-quality, mission fit) remain the compiler's manual overlay — this
# script exists so the NUMBER is script-made (ELLE-SAYI-YOK), not hand-estimated.
# Placeholder tokens hard-cap the score at 79 (prior-art: prd-taskmaster).
# Usage: lint.sh <goal-draft-file>
set -euo pipefail
F="${1:?usage: lint.sh <goal-draft-file>}"
HERE="$(cd "$(dirname "$0")" && pwd)"
CH=$("$HERE/ledger.sh" measure "$F" | grep -oE '^[0-9]+' | head -1)
python3 - "$F" "$CH" <<'PYEOF'
import sys, re
f, ch = sys.argv[1], int(sys.argv[2])
s = open(f, encoding="utf-8").read()
rows = []  # (name, got, max, note)
def add(n,g,m,note=""): rows.append((n,g,m,note))
# A char-band (15)
if ch > 4000: add("A char≤4000", 0, 15, f"{ch} — HARD-FAIL /goal reddeder")
elif ch >= 3000: add("A char-band", 15, 15, f"{ch} (ideal 3000-4000)")
else: add("A char-band", 10, 15, f"{ch} (<3000: yer israfı olabilir)")
# B structure (20)
need = ["DONE-MEANS","═ WORKER ═","═ EVALUATOR ═","<condition>","<evidence-map>","<anti-accept>"]
got = sum(1 for k in need if k in s)
add("B iskelet 6-parça", round(got/len(need)*20), 20, f"{got}/{len(need)}")
# C D-items typed (10)
items = re.findall(r'^□ D\d+ \[(M|J)\]', s, re.M)
n_items = len(items)
if 1 <= n_items <= 7: add("C D# 1-7+tip", 10, 10, f"{n_items} madde, hepsi [M]/[J]")
elif n_items > 7: add("C D# 1-7+tip", 3, 10, f"{n_items} madde (>7 → campaign)")
else:
    unt = len(re.findall(r'^□ D\d+ ', s, re.M))
    add("C D# 1-7+tip", 5 if unt else 0, 10, f"tipli={n_items}, tipsiz={unt}")
# D per-item evidence (10)
lines = re.findall(r'^□ D\d+.*$', s, re.M)
ev = sum(1 for l in lines if ("kanıt" in l or "evidence" in l.lower()))
add("D madde-başına-kanıt", round(ev/max(1,len(lines))*10), 10, f"{ev}/{len(lines)}")
# E FORBIDDEN + hand-number ban (10)
g = ("FORBIDDEN" in s)*5 + ("ELLE SAYI" in s or "hand-count" in s.lower())*5
add("E FORBIDDEN+elle-sayı-yasağı", g, 10)
# F PIN+SAFETY-turcap+LEDGER (10)
g = ("PIN:" in s)*3 + (re.search(r'SAFETY:.*?\d+\s*tur|SAFETY:.*?\d+\s*turn', s) is not None)*4 + ("LEDGER" in s)*3
add("F PIN+SAFETY(tur)+LEDGER", g, 10)
# G PROCESS jury+gate+stop (10)
g = (re.search(r'3 jüri|3 juror|jüri OYBİRLİĞİ', s) is not None)*4 + ("GATE" in s)*3 + ("STOP_REASON" in s)*3
add("G jüri+GATE+STOP_REASON", g, 10)
# H KILL+PREMORTEM (5)
g = ("KILL-CRITERIA" in s)*3 + ("PREMORTEM" in s)*2
add("H kill+premortem", g, 5)
# I placeholders (5, hard-cap)
ph = re.findall(r'\bTBD\b|\bTODO\b|\{\{[^}]*\}\}|<doldur|<fill', s)
add("I placeholder-yok", 0 if ph else 5, 5, f"{len(ph)} bulundu: {ph[:3]}" if ph else "temiz")
# J evidence-map coverage (5)
em = re.search(r'<evidence-map>(.*?)</evidence-map>', s, re.S)
mapped = len(re.findall(r'D\d+↔', em.group(1))) if em else 0
add("J map-kapsamı", 5 if mapped >= n_items and n_items>0 else (2 if mapped else 0), 5, f"map={mapped}, D#={n_items}")
tot = sum(g for _,g,_,_ in rows); mx = sum(m for _,_,m,_ in rows)
capped = False
if ph and tot > 79: tot, capped = 79, True
print(f"LINT (mekanik alt-küme) — {f}")
for n,g,m,note in rows: print(f"  {n:<28} {g:>3}/{m:<3} {note}")
print(f"  {'TOPLAM':<28} {tot:>3}/{mx}" + ("  [placeholder-CAP 79]" if capped else ""))
print(f"  SONUÇ: {'PASS (≥80)' if tot>=80 else 'FAIL (<80)'}")
print("  not: anlamsal kriterler (Goodhart-kalitesi, misyon-uyumu) derleyici-değerlendirmesinde kalır.")
sys.exit(0 if tot>=80 else 1)
PYEOF
