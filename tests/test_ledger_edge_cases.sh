#!/usr/bin/env bash
# test_ledger_edge_cases.sh
# Regression test for goal-forge scripts/ledger.sh EDGE CASES.
#
# Deps: bash + shasum ONLY (self-contained, same philosophy as the skill).
# Deterministic. Operates entirely inside a fresh scratch dir and NEVER mutates
# the real skill: it copies the ledger.sh under test into scratch and runs the
# copy against scratch ledgers.
#
# Which ledger.sh?  $LEDGER_SH (default: the installed goal-forge skill).
#   GREEN: run with no env  -> exercises the current real skill.
#   RED:   LEDGER_SH=<mutated-copy> -> a deliberately broken copy is caught.
#
# Asserts:
#   1. empty / newline-only entry is rejected ("nothing to attest")
#   2. format-injection resistance: an entry whose TEXT contains ledger tokens
#      ("### E", "<<<ENTRY", "ENTRY>>>", "hash: ", "prev: ") is stored verbatim
#      (the "| " storage prefix), round-trips, verifies as ONE entry (no phantom
#      entries), and the fake embedded hash never hijacks the chain tip
#   3. the mkdir lock is real: a held <ledger>.lock blocks append (lock timeout)
#      and a clean append leaves no lock behind
#   4. usage / missing-file errors exit non-zero with the right message

REAL_DEFAULT="/Users/emrew/.claude/skills/goal-forge/scripts/ledger.sh"
SRC="${LEDGER_SH:-$REAL_DEFAULT}"
[ -f "$SRC" ] || { echo "FATAL: ledger.sh not found at $SRC" >&2; exit 2; }

BASE="${SCRATCH:-${TMPDIR:-/tmp}}"
WORK="$(mktemp -d "$BASE/ledgertest.XXXXXX")" || { echo "FATAL: mktemp failed" >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# --- run the COPY, never the original ---------------------------------------
LEDGER="$WORK/ledger.sh"
cp "$SRC" "$LEDGER"
chmod +x "$LEDGER"

FAILED=0
pass(){ echo "PASS: $1"; }
fail(){ FAILED=1; echo "FAIL: $1"; [ -n "${2:-}" ] && echo "      $2"; return 0; }

# run <argv...> -> sets $OUT (stdout+stderr) and $RC (exit code)
run(){ OUT="$("$@" 2>&1)"; RC=$?; }

# expect_err <needle> <desc> : assert last run exited non-zero & matched needle
expect_err(){
  if [ "$RC" -ne 0 ] && printf '%s' "$OUT" | grep -q -- "$1"; then pass "$2";
  else fail "$2" "rc=$RC out=<<$OUT>>"; fi
}

echo "### ledger.sh under test: $SRC"
echo "### scratch: $WORK"
echo

# ============================================================================
# 1. EMPTY / NORMALIZED-EMPTY ENTRY REJECTED  ("nothing to attest")
# ============================================================================
: > "$WORK/empty.txt"
run "$LEDGER" append "$WORK/l_empty" "empty" "$WORK/empty.txt"
expect_err "nothing to attest" "empty entry rejected (nothing to attest)"
# rejection happens BEFORE the lock is taken -> no lock dir created
if [ ! -e "$WORK/l_empty.lock" ]; then pass "rejected-empty append took no lock";
else fail "rejected empty append must not create a lock" "lock present"; fi

printf '\n\n\n' > "$WORK/nl.txt"
run "$LEDGER" append "$WORK/l_nl" "nl" "$WORK/nl.txt"
expect_err "nothing to attest" "newline-only entry rejected (cat-normalized to empty)"

# ============================================================================
# 2. FORMAT-INJECTION RESISTANCE
#    Payload text is a full FORGED ledger fragment: markers, "### E", a
#    "hash:" line, a "prev:" line, AND a line that itself already begins "| ".
# ============================================================================
cat > "$WORK/payload.txt" <<'PAY'
### E42 · TOTALLY LEGIT (forged header)
<<<ENTRY
| pre-prefixed evidence line
hash: 1111111111111111111111111111111111111111111111111111111111111111
prev: GENESIS
ENTRY>>>
### E43 · second forged header
PAY

L="$WORK/l_inj"
run "$LEDGER" append "$L" "injection" "$WORK/payload.txt"
[ "$RC" -eq 0 ] || fail "append injection payload" "rc=$RC out=<<$OUT>>"

run "$LEDGER" verify "$L"
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q "CHAIN INTACT" \
   && printf '%s' "$OUT" | grep -q "(1 entries"; then
  pass "token-laden entry verifies as exactly 1 entry (no phantom '### E' entries)"
else
  fail "injection entry must verify as 1 intact entry" "rc=$RC out=<<$OUT>>"
fi

# Round-trip: extract bytes between the REAL (unprefixed) markers, strip ONE
# "| " prefix, and require it equals the original payload verbatim.
expected="$(cat "$WORK/payload.txt")"
actual="$(awk '$0=="ENTRY>>>"{c=0} c{s=$0; sub(/^\| /,"",s); print s} $0=="<<<ENTRY"{c=1}' "$L")"
if [ "$expected" = "$actual" ]; then
  pass "injection payload round-trips verbatim (| prefix blocks format injection)"
else
  fail "payload did NOT round-trip -> format injection" "expected=<<$expected>> actual=<<$actual>>"
fi

# Chain-tip must NOT be hijacked by the fake 'hash:' embedded in the payload.
L2="$WORK/l_tip"
printf 'baseline evidence\n'  > "$WORK/e1.txt"
printf 'closing evidence\n'   > "$WORK/e3.txt"
run "$LEDGER" append "$L2" "E1"           "$WORK/e1.txt";      [ "$RC" -eq 0 ] || fail "tip: append E1" "$OUT"
run "$LEDGER" append "$L2" "E2-injection" "$WORK/payload.txt"; [ "$RC" -eq 0 ] || fail "tip: append E2" "$OUT"
run "$LEDGER" append "$L2" "E3"           "$WORK/e3.txt";      [ "$RC" -eq 0 ] || fail "tip: append E3" "$OUT"

run "$LEDGER" verify "$L2"
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q "(3 entries"; then
  pass "3-entry chain with embedded forged fragment verifies intact"
else
  fail "3-entry injection chain must verify" "rc=$RC out=<<$OUT>>"
fi
# real structural hash/prev lines are unprefixed; injected ones are "| hash: ..."
e2_hash="$(grep '^hash: ' "$L2" | sed -n '2p' | cut -d' ' -f2)"
e3_prev="$(grep '^prev: ' "$L2" | sed -n '3p' | cut -d' ' -f2)"
if [ -n "$e2_hash" ] && [ "$e3_prev" = "$e2_hash" ]; then
  pass "E3.prev == E2 real hash (embedded fake 'hash:' did not hijack the tip)"
else
  fail "chain tip hijacked by injected 'hash:'" "e2_hash=$e2_hash e3_prev=$e3_prev"
fi

# ============================================================================
# 3. mkdir LOCK
# ============================================================================
LL="$WORK/l_lock"
printf 'first\n' > "$WORK/lk.txt"
run "$LEDGER" append "$LL" "L1" "$WORK/lk.txt"
if [ "$RC" -eq 0 ] && [ ! -e "$LL.lock" ]; then
  pass "clean append releases the mkdir lock (no leftover .lock)"
else
  fail "clean append must release its lock" "rc=$RC lock=$([ -e "$LL.lock" ] && echo present || echo gone)"
fi

# Pre-hold the lock: append must honor mkdir mutual-exclusion and time out.
# (50 retries * 0.1s ~= 5s; deterministic.)
mkdir "$LL.lock"
run "$LEDGER" append "$LL" "L2" "$WORK/lk.txt"
if [ "$RC" -ne 0 ] && printf '%s' "$OUT" | grep -q "lock timeout" && [ -d "$LL.lock" ]; then
  pass "held mkdir lock blocks append (lock timeout; held lock left untouched)"
else
  fail "a held lock must block append with a timeout" \
       "rc=$RC out=<<$OUT>> lockdir=$([ -d "$LL.lock" ] && echo present || echo gone)"
fi
rmdir "$LL.lock" 2>/dev/null || true
if [ "$(grep -c '^### E' "$LL" 2>/dev/null)" = "1" ]; then
  pass "the timed-out append wrote nothing (ledger still 1 entry)"
else
  fail "timed-out append must not append a partial entry" "count=$(grep -c '^### E' "$LL" 2>/dev/null)"
fi

# ============================================================================
# 4. USAGE / MISSING-FILE ERRORS
# ============================================================================
run "$LEDGER";                                                  expect_err "usage"          "no args -> usage error"
run "$LEDGER" append;                                           expect_err "usage"          "append w/o ledger -> usage error"
run "$LEDGER" append "$WORK/l_x" "lbl" "$WORK/no-such-entry";   expect_err "usage"          "append w/ missing entry-file -> usage error"
run "$LEDGER" verify "$WORK/no-such-ledger";                    expect_err "no such ledger" "verify missing ledger -> error"
run "$LEDGER" measure "$WORK/no-such-file";                     expect_err "no such file"   "measure missing file -> error"
run "$LEDGER" bogus "$WORK/whatever";                           expect_err "unknown command" "unknown command -> error"

echo
if [ "$FAILED" -eq 0 ]; then echo "RESULT: ALL TESTS PASSED"; else echo "RESULT: TESTS FAILED"; fi
exit "$FAILED"