#!/usr/bin/env bash
# test_lint_structural_smoke.sh
# ---------------------------------------------------------------------------
# Regression test: the goal-forge LINT rubric behaves as a REAL structural
# filter. It is a grep-based smoke test (NOT a full LLM score) that asserts:
#
#   (A) a KNOWN-GOOD compiled goal (goals/1.7-m1-draft.txt AND goals/1.6-draft.txt)
#       carries EVERY structural marker a >=80 goal needs:
#         metadata line, budget, ledger, DONE-MEANS, all D# with INLINE evidence,
#         FORBIDDEN, <condition>/<evidence-map>/<anti-accept> slots,
#         3-juror tribunal (J1/J2/J3), COMPLETION GATE, PROSECUTOR,
#         GENESIS-chain (ANCHORED-VERDICT compatible).
#
#   (B) a KNOWN-BAD stub (no evidence, no tribunal, no slots) is FLAGGED by
#       the very same structural check.
#
# If a good goal ever loses a marker, or the check stops flagging garbage,
# the test goes RED.
#
# Deps: bash + grep + wc ONLY (zero external API, self-contained -- same
# philosophy as the skill). Deterministic. Read-only on the real skill;
# every fixture / mutation lives in a mktemp scratch dir that is cleaned up.
# The real skill files are NEVER written to.
#
# Exit: 0 = PASS . 1 = assertion failed (RED) . 3 = fixture missing (FATAL)
# ---------------------------------------------------------------------------

export LC_ALL=C   # deterministic byte-level matching for the box / Turkish glyphs
set -u

SKILL_DIR="${GF_SKILL_DIR:-/Users/emrew/.claude/skills/goal-forge}"

# Known-good set. GF_GOOD_FILE overrides the whole set with a single file
# (used by the RED harness to point the test at a deliberately broken copy).
if [ -n "${GF_GOOD_FILE:-}" ]; then
  GOOD_FILES=("$GF_GOOD_FILE")
else
  GOOD_FILES=("$SKILL_DIR/goals/1.7-m1-draft.txt" "$SKILL_DIR/goals/1.6-draft.txt")
fi

for f in "${GOOD_FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "FATAL: known-good goal fixture not found: $f" >&2
    exit 3
  fi
done

WORK="$(mktemp -d "${TMPDIR:-/tmp}/gf-lint-smoke.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# --- KNOWN-BAD stub fixture: a low-score goal (no evidence, no tribunal) -----
BAD_FILE="$WORK/bad-stub.txt"
cat > "$BAD_FILE" <<'EOF'
/goal make the project great and production-ready
Please just do everything that is needed:
- build the website
- make it fast
- make sure the tests pass
Deliver it when it looks good. The user will explain the rest later.
EOF

# ---------------------------------------------------------------------------
# structural_check <file>
#   Prints a PASS/FAIL line per marker to stdout.
#   Sets global STRUCT_FAILS to the number of failed markers.
#   Returns 0 iff ALL markers pass, non-zero otherwise.
# ---------------------------------------------------------------------------
structural_check() {
  local f="$1"
  STRUCT_FAILS=0

  _m() {  # _m <name> <ERE-pattern>   (marker satisfied iff pattern matches)
    if grep -qiE -- "$2" "$f"; then
      printf '  PASS  %s\n' "$1"
    else
      printf '  FAIL  %s\n' "$1"
      STRUCT_FAILS=$((STRUCT_FAILS + 1))
    fi
  }

  # --- LINT #1: measurable end state -------------------------------------
  _m "metadata-line (/goal [ ... ])"      '^/goal \['
  _m "budget-declared (budget:N)"         'budget:[0-9]'
  _m "ledger-declared (ledger:...)"       'ledger:[^]]*EVIDENCE'
  _m "done-means-pointer"                 'DONE-MEANS'

  # --- LINT #2: every deliverable is a D# line with INLINE evidence -------
  local total missing
  total=$(grep -cE $'\xe2\x96\xa1'' ?D[0-9]' "$f" 2>/dev/null || true); total=${total:-0}
  missing=$(grep -E $'\xe2\x96\xa1'' ?D[0-9]' "$f" 2>/dev/null | grep -cviE $'kan\xc4\xb1t''|kanit|evidence' || true)
  missing=${missing:-0}
  if [ "$total" -ge 3 ] && [ "$missing" -eq 0 ]; then
    printf '  PASS  all-D#-inline-evidence (D#=%s, no-evidence=%s)\n' "$total" "$missing"
  else
    printf '  FAIL  all-D#-inline-evidence (D#=%s, no-evidence=%s)\n' "$total" "$missing"
    STRUCT_FAILS=$((STRUCT_FAILS + 1))
  fi

  # --- LINT #3: constraint clarity ---------------------------------------
  _m "FORBIDDEN block"                    '^FORBIDDEN:'

  # --- LINT #10: tribunal + skeleton-v2 slots + anchored verdict ---------
  _m "condition-slot open"                '<condition>'
  _m "condition-slot close"               '</condition>'
  _m "evidence-map-slot"                  '<evidence-map>'
  _m "anti-accept-slot"                   '<anti-accept>'

  # 3 method-diverse jurors must ALL be named
  if grep -qE 'J1' "$f" && grep -qE 'J2' "$f" && grep -qE 'J3' "$f"; then
    printf '  PASS  tribunal-3-jurors (J1+J2+J3)\n'
  else
    printf '  FAIL  tribunal-3-jurors (J1+J2+J3)\n'
    STRUCT_FAILS=$((STRUCT_FAILS + 1))
  fi

  _m "completion-gate"                    'COMPLETION GATE'
  _m "prosecutor"                         'PROSECUTOR'
  # ANCHORED-VERDICT compat: J2's from-GENESIS chain re-verification anchor
  _m "anchored-verdict/GENESIS-chain"     'GENESIS'

  return "$STRUCT_FAILS"
}

# ---------------------------------------------------------------------------
FAILS=0

echo "=============================================================="
echo " goal-forge LINT structural smoke test"
echo "=============================================================="

# --- ASSERT A: every KNOWN-GOOD goal passes ALL structural markers ---------
for GOOD in "${GOOD_FILES[@]}"; do
  echo
  echo "[A] KNOWN-GOOD must pass ALL markers: $GOOD"
  structural_check "$GOOD"
  if [ "$STRUCT_FAILS" -eq 0 ]; then
    echo "  => PASS (0 missing markers)"
  else
    echo "  => FAIL: $STRUCT_FAILS structural marker(s) missing from a >=80 goal"
    FAILS=$((FAILS + 1))
  fi
done

# --- ASSERT B: the KNOWN-BAD stub is FLAGGED ------------------------------
echo
echo "[B] KNOWN-BAD stub must be FLAGGED: $BAD_FILE"
structural_check "$BAD_FILE"
if [ "$STRUCT_FAILS" -gt 0 ]; then
  echo "  => PASS (stub flagged: $STRUCT_FAILS missing markers)"
else
  echo "  => FAIL: structural check did NOT flag an evidence-less, tribunal-less stub"
  FAILS=$((FAILS + 1))
fi

echo
echo "--------------------------------------------------------------"
if [ "$FAILS" -eq 0 ]; then
  echo "RESULT: PASS -- rubric filters good from bad."
  exit 0
else
  echo "RESULT: FAIL -- $FAILS assertion(s) violated."
  exit 1
fi