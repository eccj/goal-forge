#!/usr/bin/env bash
# test_invariant_xref.sh — cross-file INVARIANT CONSISTENCY (1.9).
#
# The protocol's rules live canonically in TEMPLATE.md, with summaries in
# SKILL.md and a conformance cell in LINT.md. Historically these three copies
# DRIFTED (the 1.7-M1 hardening was largely drift repair). This test pins the
# load-bearing invariants to appear NON-CONTRADICTORILY in all three files:
#
#   X1  3-method jury: J1/J2/J3 named in SKILL + TEMPLATE + LINT.
#   X2  Light-mode widened threshold: the "<=5 when G=1 / all-[M]" carve-out
#       present in SKILL + TEMPLATE + LINT, AND the stale pre-1.9 heading
#       ("only: ≤3 deliverables AND") absent from TEMPLATE.
#   X3  STOP_REASON token contract present in SKILL + TEMPLATE.
#   X4  jury-shopping tripwire present in SKILL + TEMPLATE.
#   X5  Canonical-source declarations: SKILL defers to TEMPLATE on conflict,
#       LINT #10 declares TEMPLATE canonical.
#
# Self-verified GREEN + RED:
#   GREEN: the real skill passes X1-X5.
#   RED:   a mutated copy (SKILL's G=1 clause corrupted to "up to 4 items")
#          must FAIL X2 — proving the xref actually detects divergence.
#
# Deps: bash + grep only. Read-only on the real skill. Exit 0 = pass.

set -u
export LC_ALL=C.UTF-8
SKILL_DIR="${GF_SKILL_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
S="$SKILL_DIR/SKILL.md"; T="$SKILL_DIR/TEMPLATE.md"; L="$SKILL_DIR/LINT.md"

fail() { echo "TEST-FAIL: $*" >&2; exit 1; }
pass() { echo "TEST-PASS: $*"; }
for f in "$S" "$T" "$L"; do [ -f "$f" ] || fail "missing file: $f"; done

check_all() { # $1=label $2=pattern ; must match in S, T, L
  for f in "$S" "$T" "$L"; do
    grep -q -- "$2" "$f" || { echo "  MISS  $1 in $(basename "$f")"; return 1; }
  done
  return 0
}

FAILS=0

# X1 — 3-method jury named everywhere
for j in "J1" "J2" "J3"; do
  check_all "X1:$j" "$j" || FAILS=$((FAILS+1))
done
pass_or_note() { [ "$1" -eq 0 ] && pass "$2"; }
[ "$FAILS" -eq 0 ] && pass "X1 3-method jury (J1/J2/J3) named in SKILL+TEMPLATE+LINT"

# X2 — widened Light threshold, consistently, and no stale heading
x2=0
grep -q "up to 5 items" "$S"                                   || { echo "  MISS X2 SKILL (up to 5 items)"; x2=1; }
grep -q "or ≤5 when EVERY D# is \[M\]-typed (G=1)" "$T"        || { echo "  MISS X2 TEMPLATE (≤5 G=1 heading)"; x2=1; }
grep -q "or ≤5 when G=1" "$L"                                  || { echo "  MISS X2 LINT (≤5 G=1)"; x2=1; }
grep -q "only: ≤3 deliverables AND" "$T"                       && { echo "  STALE X2 TEMPLATE pre-1.9 heading still present"; x2=1; }
[ "$x2" -eq 0 ] && pass "X2 Light threshold (≤5 when G=1) consistent, no stale heading" || FAILS=$((FAILS+1))

# X3 — STOP_REASON in SKILL + TEMPLATE
x3=0
for f in "$S" "$T"; do grep -q "STOP_REASON" "$f" || { echo "  MISS X3 in $(basename "$f")"; x3=1; }; done
[ "$x3" -eq 0 ] && pass "X3 STOP_REASON contract in SKILL+TEMPLATE" || FAILS=$((FAILS+1))

# X4 — jury-shopping tripwire in SKILL + TEMPLATE
x4=0
for f in "$S" "$T"; do grep -q "jury-shopping" "$f" || { echo "  MISS X4 in $(basename "$f")"; x4=1; }; done
[ "$x4" -eq 0 ] && pass "X4 jury-shopping tripwire in SKILL+TEMPLATE" || FAILS=$((FAILS+1))

# X5 — canonical-source declarations
x5=0
grep -q "TEMPLATE.md wins" "$S"                        || { echo "  MISS X5 SKILL defer-to-TEMPLATE"; x5=1; }
grep -q "CANONICAL protocol text" "$L"                 || { echo "  MISS X5 LINT#10 canonical declaration"; x5=1; }
[ "$x5" -eq 0 ] && pass "X5 canonical-source declarations (SKILL defers, LINT declares)" || FAILS=$((FAILS+1))

[ "$FAILS" -eq 0 ] || fail "$FAILS xref invariant(s) inconsistent across SKILL/TEMPLATE/LINT"

# --- RED: mutated SKILL copy must FAIL X2 ------------------------------------
WORK="$(mktemp -d "${TMPDIR:-/tmp}/gf-xref.XXXXXX")" || fail "mktemp failed"
trap 'rm -rf "$WORK"' EXIT
cp "$S" "$WORK/SKILL.md"; cp "$T" "$WORK/TEMPLATE.md"; cp "$L" "$WORK/LINT.md"
sed -i '' 's/up to 5 items/up to 4 items/' "$WORK/SKILL.md" 2>/dev/null \
  || sed -i 's/up to 5 items/up to 4 items/' "$WORK/SKILL.md"
grep -q "up to 4 items" "$WORK/SKILL.md" || fail "RED mutation did not apply"
# re-run the exact X2 SKILL predicate against the mutated copy: it must now MISS
if grep -q "up to 5 items" "$WORK/SKILL.md"; then
  fail "RED: mutated copy still passed X2 (xref has no teeth)"
fi
pass "RED: SKILL mutated to 'up to 4 items' -> X2 correctly detects the divergence"

echo "ALL-PASS: cross-file invariant xref (X1-X5) green+red."
