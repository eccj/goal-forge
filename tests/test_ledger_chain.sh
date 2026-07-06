#!/usr/bin/env bash
# test_ledger_chain.sh — regression test for goal-forge ledger.sh CHAIN INTEGRITY.
#
# Property under test:
#   verify recomputes the sha256 hash-chain from the literal GENESIS to the tip
#   and PROPAGATES the RECOMPUTED hash forward. So a single-character edit inside
#   one <<<ENTRY..ENTRY>>> body must (a) fail that entry's hash, and (b) cascade —
#   every LATER entry's prev-link breaks against the recomputed chain — ending in
#   "CHAIN BROKEN" + exit 1.
#
# Deps: bash + shasum + python3 ONLY (same self-contained philosophy as the skill).
# Deterministic (append writes no timestamps/randomness). Operates only on a
# scratch mktemp dir; the REAL skill files are copied out and never modified.
# Exit 0 = pass, non-zero = fail.
#
# The ledger.sh under test is picked from $LEDGER_SH (default: the installed skill),
# so a deliberately-broken copy can be pointed at to prove the test goes RED.

set -u

SKILL_LEDGER="${LEDGER_SH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/ledger.sh}"

fail() { echo "TEST-FAIL: $*" >&2; exit 1; }
pass() { echo "TEST-PASS: $*"; }

[ -f "$SKILL_LEDGER" ] || fail "ledger.sh not found at $SKILL_LEDGER"
command -v shasum  >/dev/null 2>&1 || fail "shasum not available"
command -v python3 >/dev/null 2>&1 || fail "python3 not available"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/ledger_test.XXXXXX")" || fail "mktemp failed"
trap 'rm -rf "$WORK"' EXIT

# Copy the script into scratch — the real skill file is never run in place / mutated.
LEDGER_SH_COPY="$WORK/ledger.sh"
cp "$SKILL_LEDGER" "$LEDGER_SH_COPY"; chmod +x "$LEDGER_SH_COPY"

LEDGER="$WORK/ledger.md"

append() { # $1=label  $2=entry-text
  printf '%s' "$2" > "$WORK/entry.txt"
  bash "$LEDGER_SH_COPY" append "$LEDGER" "$1" "$WORK/entry.txt" >/dev/null \
    || fail "append failed for label=$1"
}

# 1) Build a ledger with four appended entries (deterministic, unique bodies).
append "genesis-step" "alpha evidence one"
append "second-step"  "beta evidence two"
append "third-step"   "gamma evidence three"
append "tip-step"     "delta evidence four"

# 2) GREEN: verify the intact ledger — CHAIN INTACT, exit 0, GENESIS->tip recompute.
green_out="$(bash "$LEDGER_SH_COPY" verify "$LEDGER" 2>&1)"; green_rc=$?
echo "=== GREEN verify (intact, 4 entries) ==="; echo "$green_out"; echo "rc=$green_rc"
[ "$green_rc" -eq 0 ] || fail "intact verify exit=$green_rc (expected 0)"
echo "$green_out" | grep -q "CHAIN INTACT"              || fail "intact verify missing 'CHAIN INTACT'"
echo "$green_out" | grep -q "GENESIS.*tip recomputed"   || fail "intact verify missing GENESIS->tip recompute claim"
[ "$(echo "$green_out" | grep -c '^OK')" -eq 4 ]        || fail "intact verify: expected 4 OK lines"
pass "intact ledger -> CHAIN INTACT (4 entries, GENESIS->tip recomputed)"

# 3) Mutate EXACTLY ONE character inside the E2 <<<ENTRY..ENTRY>>> body, on a COPY.
BROKEN="$WORK/ledger.broken.md"
python3 - "$LEDGER" "$BROKEN" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
data  = open(src, encoding="utf-8").read()
lines = data.split("\n")
i = next(k for k, l in enumerate(lines) if l.startswith("### E2"))       # E2 header
j = next(k for k in range(i, len(lines)) if lines[k] == "<<<ENTRY")      # its body opener
body = j + 1                                                             # first body line
assert lines[body].startswith("| "), "unexpected E2 body line: %r" % lines[body]
pos  = 2                                     # first CONTENT char (0='|', 1=' ')
orig = lines[body][pos]
new  = "x" if orig != "x" else "y"
lines[body] = lines[body][:pos] + new + lines[body][pos+1:]
out = "\n".join(lines)
open(dst, "w", encoding="utf-8").write(out)
# Prove the mutation is a single-character, in-body, no-marker edit.
assert len(data) == len(out), "mutation changed length"
diffs = [k for k in range(len(data)) if data[k] != out[k]]
assert len(diffs) == 1, "expected exactly 1 char changed, got %d" % len(diffs)
line_no = data.count("\n", 0, diffs[0])
assert line_no == body, "diff on line %d, expected E2 body line %d" % (line_no, body)
print("MUTATION-OK: flipped 1 char inside E2 <<<ENTRY body (line %d, %r->%r)" % (body + 1, orig, new))
PY
mrc=$?; [ "$mrc" -eq 0 ] || fail "single-char body mutation step failed (rc=$mrc)"

# 4) RED: verify the mutated ledger — CHAIN BROKEN, exit 1, and the cascade.
red_out="$(bash "$LEDGER_SH_COPY" verify "$BROKEN" 2>&1)"; red_rc=$?
echo "=== RED verify (E2 body mutated by 1 char) ==="; echo "$red_out"; echo "rc=$red_rc"
[ "$red_rc" -ne 0 ] || fail "mutated verify exited 0 (expected non-zero)"
[ "$red_rc" -eq 1 ] || fail "mutated verify exit=$red_rc (expected 1)"
echo "$red_out" | grep -q "CHAIN BROKEN"                       || fail "mutated verify missing 'CHAIN BROKEN'"
# E1 (before the tampered entry) still recomputes clean from GENESIS:
echo "$red_out" | grep -Eq '^OK[[:space:]]+E1'                 || fail "E1 should still verify OK"
# E2 (tampered) fails on its own hash — proves entry text is hashed, prefix-stripped:
echo "$red_out" | grep -Eq 'FAIL at E2 .*hash mismatch'        || fail "E2 should FAIL with hash mismatch"
# PROPAGATION: recomputed (wrong) hash carried forward -> E3 prev-link diverges:
echo "$red_out" | grep -Eq 'FAIL at E3 .*prev-link broken'     || fail "E3 should FAIL prev-link broken (propagation)"
# CASCADE must reach the TIP (E4), not just the tampered entry:
echo "$red_out" | grep -Eq 'FAIL at E4'                        || fail "cascade must reach tip E4"
pass "1-char E2 body edit -> CHAIN BROKEN, exit 1, cascade E2->E3->E4 (GENESIS->tip propagation)"

echo "ALL-PASS: ledger.sh CHAIN INTEGRITY regression test green."