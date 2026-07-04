#!/usr/bin/env bash
# test_ledger_measure.sh — regression test for goal-forge scripts/ledger.sh `measure`
# (LINT #9: the /goal char-budget is counted in CHARACTERS, not bytes).
#
# Deps: bash + python3 ONLY (python3 is used purely as an independent oracle for
# len() / utf-8 byte length; no shasum needed for the measure path). Deterministic,
# self-contained, zero external/network deps.
#
# NEVER mutates the real skill: every fixture is created in a fresh mktemp -d
# scratch dir and removed on exit. The script-under-test is READ (executed),
# never written.
#
# Usage:
#   test_ledger_measure.sh [path/to/ledger.sh]
#   LEDGER_SH=/path/to/ledger.sh test_ledger_measure.sh
# Default target is the installed skill. Pass a (mutated) copy to prove RED.
#
# Exit 0 = all assertions pass. Non-zero = a regression was caught.

set -u

LEDGER="${1:-${LEDGER_SH:-/Users/emrew/.claude/skills/goal-forge/scripts/ledger.sh}}"
[ -f "$LEDGER" ] || { echo "FATAL: ledger.sh not found: $LEDGER" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "FATAL: python3 required (oracle)" >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/ledgm.XXXXXX")" || { echo "FATAL: mktemp" >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

echo "target : $LEDGER"
echo "scratch: $WORK"
echo

pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'PASS  %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }

# ---- deterministic UTF-8 fixtures, written byte-exact via python3 ----
python3 - "$WORK" <<'PY'
import sys, os
work = sys.argv[1]
def w(name, s):
    with open(os.path.join(work, name), "wb") as f:
        f.write(s.encode("utf-8"))
# Turkish chars: ö ü ş İ ç ğ Ö Ş … all multi-byte => char count < byte count.
turk = "Görüşürüz — İstanbul çğıöşü ÇĞİÖŞÜ"
w("turk.txt",       turk)              # char count must != byte count
w("turk_nl.txt",    turk + "\n\n\n")   # same content + trailing newlines
w("ascii4000.txt",  "a" * 4000)        # boundary OK (ASCII)
w("ascii4001.txt",  "a" * 4001)        # boundary OVER (ASCII)
w("turk4000.txt",   "ş" * 4000)   # 'ş' x4000 = 4000 chars / 8000 bytes -> OK on chars, OVER if bytes
w("turk4001.txt",   "ş" * 4001)   # 4001 chars -> OVER
w("empty.txt",      "")                # empty -> rejected
w("newlines.txt",   "\n\n\n")          # only newlines -> strips to empty -> rejected
PY
[ $? -eq 0 ] || { echo "FATAL: fixture generation failed" >&2; exit 2; }

# ---- helpers ----
# Run measure; capture stdout in MOUT and exit code in MRC. (No `set -e`, so a
# non-zero exit is observable rather than aborting the test.)
run_measure() { MOUT="$("$LEDGER" measure "$1" 2>/dev/null)"; MRC=$?; }

# First "<N> chars" integer in the report (note the report also ends with
# "...4000 chars: OK/OVER", so take the FIRST match = the leading metric).
parse_chars() { printf '%s\n' "$1" | grep -oE '[0-9]+ chars' | head -1 | grep -oE '[0-9]+'; }
# The single "<N> bytes" integer.
parse_bytes() { printf '%s\n' "$1" | grep -oE '[0-9]+ bytes' | head -1 | grep -oE '[0-9]+'; }
# OK / OVER verdict against the 4000 limit.
parse_verdict() { case "$1" in *"4000 chars: OK"*) echo OK;; *"4000 chars: OVER"*) echo OVER;; *) echo '?';; esac; }

# python oracles (rstrip('\n') mirrors $(cat) trailing-newline stripping — LINT #9 cross-check)
py_chars() { python3 -c 'import sys; print(len(open(sys.argv[1],encoding="utf-8").read().rstrip("\n")))' "$1"; }
py_bytes() { python3 -c 'import sys; print(len(open(sys.argv[1],encoding="utf-8").read().rstrip("\n").encode("utf-8")))' "$1"; }

# =====================================================================
# 1. CHARACTERS not bytes, on Turkish text; cross-checked against python len()
# =====================================================================
run_measure "$WORK/turk.txt"
tc=$(parse_chars "$MOUT"); tb=$(parse_bytes "$MOUT")
pc=$(py_chars "$WORK/turk.txt"); pb=$(py_bytes "$WORK/turk.txt")
[ "$MRC" -eq 0 ] && ok "turk: exit 0" || bad "turk: expected exit 0, got $MRC"
[ "$tc" = "$pc" ] && ok "turk: reported chars=$tc == python len()=$pc" \
                  || bad "turk: reported chars=$tc != python len()=$pc"
[ "$tb" = "$pb" ] && ok "turk: reported bytes=$tb == python utf8 bytes=$pb" \
                  || bad "turk: reported bytes=$tb != python utf8 bytes=$pb"
# The load-bearing LINT #9 property: this string's char count is strictly less
# than its byte count, so a byte-counter would report a different (larger) number.
if [ -n "$tc" ] && [ -n "$tb" ] && [ "$tc" -lt "$tb" ]; then
  ok "turk: char count ($tc) < byte count ($tb) — proves it is NOT counting bytes"
else
  bad "turk: expected char<byte (chars=$tc bytes=$tb) — cannot distinguish char vs byte counting"
fi

# =====================================================================
# 2. Trailing newlines are stripped (same content ± trailing \n\n\n => same count)
# =====================================================================
run_measure "$WORK/turk_nl.txt"
nc=$(parse_chars "$MOUT")
[ "$MRC" -eq 0 ] && ok "turk_nl: exit 0" || bad "turk_nl: expected exit 0, got $MRC"
[ "$nc" = "$tc" ] && ok "trailing-newline strip: with \\n\\n\\n chars=$nc == without=$tc" \
                  || bad "trailing-newline strip: with \\n\\n\\n chars=$nc != without=$tc"
[ "$nc" = "$(py_chars "$WORK/turk_nl.txt")" ] \
  && ok "turk_nl: chars=$nc == python rstrip('\\n') len" \
  || bad "turk_nl: chars=$nc != python rstrip('\\n') len=$(py_chars "$WORK/turk_nl.txt")"

# =====================================================================
# 3a. OK/OVER boundary on ASCII
# =====================================================================
run_measure "$WORK/ascii4000.txt"; c=$(parse_chars "$MOUT"); v=$(parse_verdict "$MOUT")
{ [ "$c" = 4000 ] && [ "$v" = OK ]; } && ok "ascii 4000: chars=4000, verdict=OK" \
  || bad "ascii 4000: chars=$c verdict=$v (want 4000/OK)"
run_measure "$WORK/ascii4001.txt"; c=$(parse_chars "$MOUT"); v=$(parse_verdict "$MOUT")
{ [ "$c" = 4001 ] && [ "$v" = OVER ]; } && ok "ascii 4001: chars=4001, verdict=OVER" \
  || bad "ascii 4001: chars=$c verdict=$v (want 4001/OVER)"

# =====================================================================
# 3b. OK/OVER boundary on Turkish — the decisive LINT #9 case:
#     4000 two-byte chars = 4000 chars (OK) but 8000 bytes (a byte-counter
#     would wrongly say OVER). Proves the limit is applied to CHARS.
# =====================================================================
run_measure "$WORK/turk4000.txt"; c=$(parse_chars "$MOUT"); b=$(parse_bytes "$MOUT"); v=$(parse_verdict "$MOUT")
{ [ "$c" = 4000 ] && [ "$b" = 8000 ] && [ "$v" = OK ]; } \
  && ok "turk 4000: chars=4000 bytes=8000 verdict=OK (byte-count would say OVER)" \
  || bad "turk 4000: chars=$c bytes=$b verdict=$v (want 4000/8000/OK)"
run_measure "$WORK/turk4001.txt"; c=$(parse_chars "$MOUT"); v=$(parse_verdict "$MOUT")
{ [ "$c" = 4001 ] && [ "$v" = OVER ]; } && ok "turk 4001: chars=4001, verdict=OVER" \
  || bad "turk 4001: chars=$c verdict=$v (want 4001/OVER)"

# =====================================================================
# 4. Empty file (and newline-only file that strips to empty) are REJECTED
# =====================================================================
run_measure "$WORK/empty.txt"
[ "$MRC" -ne 0 ] && ok "empty file: rejected (exit $MRC)" \
                 || bad "empty file: expected non-zero exit, got 0 (output: $MOUT)"
run_measure "$WORK/newlines.txt"
[ "$MRC" -ne 0 ] && ok "newline-only file: rejected (exit $MRC)" \
                 || bad "newline-only file: expected non-zero exit, got 0 (output: $MOUT)"

# ---- summary ----
echo
echo "----------------------------------------"
echo "PASS: $pass   FAIL: $fail"
[ "$fail" -eq 0 ] || { echo "RESULT: RED (regression detected)"; exit 1; }
echo "RESULT: GREEN"
exit 0