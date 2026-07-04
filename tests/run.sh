#!/usr/bin/env bash
# tests/run_tests.sh — goal-forge unified test-suite runner.
#
# Runs every self-verified module in tests/ against ONE skill dir and reports a
# per-module PASS/FAIL line plus a final tally. Exit 0 iff all present modules
# pass. Each module already self-verifies (green + red) internally and is
# read-only against the skill (all work happens in mktemp copies); this runner
# only WIRES each module to the target using ITS OWN convention, because the
# modules disagree on how the target is passed (env LEDGER_SH / GF_SKILL_DIR /
# GOAL_FORGE_DIR, positional $1, or fully self-contained). A uniform argv would
# silently break measure/template/tamper — do not "simplify" this to a for-loop.
#
# Usage:   tests/run_tests.sh [SKILL_DIR]
#   SKILL_DIR defaults to $GF_SKILL_DIR, then the installed skill.
# Deps:    bash + python3 + shasum only (no network, no packages).

set -u

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="${1:-${GF_SKILL_DIR:-/Users/emrew/.claude/skills/goal-forge}}"
SKILL="$(cd "$SKILL" 2>/dev/null && pwd || echo "$SKILL")"
LED="$SKILL/scripts/ledger.sh"

[ -f "$LED" ] || { echo "FATAL: ledger.sh not found at $LED" >&2; exit 2; }

# Per-module invocation table: "<module>|<how to run it>".  %M -> module path.
# Each RHS hands the target via the exact env/arg form that module expects.
MODULES=(
  "test_ledger_chain.sh|LEDGER_SH=\"\$LED\" bash %M"
  "test_ledger_measure.sh|bash %M \"\$LED\""
  "test_ledger_tamper.sh|bash %M \"\$SKILL\""
  "test_ledger_edge_cases.sh|LEDGER_SH=\"\$LED\" bash %M"
  "test_lint_structural_smoke.sh|GF_SKILL_DIR=\"\$SKILL\" bash %M"
  "test_template_integrity.sh|GOAL_FORGE_DIR=\"\$SKILL\" bash %M"
  "test_xref_anchors.py|python3 %M \"\$SKILL\""
  "test_version_stamp_consistency.py|python3 %M \"\$SKILL\""
  "test_m2_recipe_fixtures.sh|bash %M"
  "test_goal_forge_smoke.sh|GF_SKILL_DIR=\"\$SKILL\" bash %M"
)

pass=0; fail=0; missing=0; FAILED=()

echo "goal-forge test suite"
echo "  skill : $SKILL"
echo "  tests : $TESTS_DIR  (${#MODULES[@]} modules)"
echo "------------------------------------------------------------"

for spec in "${MODULES[@]}"; do
  mod="${spec%%|*}"; how="${spec#*|}"
  path="$TESTS_DIR/$mod"
  if [ ! -f "$path" ]; then
    printf '  MISSING  %s\n' "$mod"; missing=$((missing+1)); FAILED+=("$mod (missing)"); continue
  fi
  cmd="${how//%M/\"$path\"}"
  log="$(mktemp)"
  if eval "$cmd" >"$log" 2>&1; then
    printf '  PASS     %s\n' "$mod"; pass=$((pass+1))
  else
    code=$?
    printf '  FAIL(%d)  %s\n' "$code" "$mod"; fail=$((fail+1)); FAILED+=("$mod (exit $code)")
    sed 's/^/           | /' "$log" | tail -15
  fi
  rm -f "$log"
done

echo "------------------------------------------------------------"
total=${#MODULES[@]}
echo "RESULT: ${pass}/${total} passed · ${fail} failed · ${missing} missing"
if [ "$fail" -gt 0 ] || [ "$missing" -gt 0 ]; then
  printf '  problems:\n'; printf '    - %s\n' "${FAILED[@]}"
  exit 1
fi
echo "ALL GREEN"
exit 0