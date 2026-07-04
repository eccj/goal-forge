#!/usr/bin/env bash
# ============================================================================
# test_template_integrity.sh
# Regression test: goal-forge TEMPLATE.md structural integrity.
#
# Asserts the source template still carries every load-bearing structural
# marker the compiler and the LINT/SKILL references depend on:
#   * 9 top-level "## §" sections
#   * 4 inline structural anchors
#   * the 3 canonical XML tag names (open AND close)
#   * the canonical metadata token scheme (keys + "·" separators)
#
# Deps: bash + grep + cp/mktemp/awk ONLY. Zero external API. Deterministic.
# Operates on a COPY in a throwaway scratch dir; it NEVER reads-to-mutate,
# writes, or otherwise touches the real skill files.
#
# Usage:
#   bash test_template_integrity.sh                 # test the real TEMPLATE.md
#   bash test_template_integrity.sh /path/to/file   # test a specific file
#   bash test_template_integrity.sh --selftest      # prove the test is red-able
#   GOAL_FORGE_DIR=/somewhere bash test_template_integrity.sh
# Exit: 0 = all markers present; 1 = one or more missing; 2 = target not found.
# ============================================================================
set -u
export LC_ALL=C   # byte-level matching so multibyte "§"/"·" compare literally

SKILL_DIR="${GOAL_FORGE_DIR:-/Users/emrew/.claude/skills/goal-forge}"

SCRATCH=""                                   # global so the EXIT trap can see it
trap 'rm -rf "${SCRATCH:-}"' EXIT            # cleanup fires even under set -u

# --- fixed-string tokens that MUST appear verbatim in TEMPLATE.md -----------
REQUIRED=(
  # -- 9 top-level "## §" sections (heading prefix must be present) --
  '## §Ledger'
  '## §Juror prompt core'
  '## §DAL-C'
  '## §Fallback'
  '## §SAFETY'
  '## §Roadmap'
  '## §Light mode'
  '## §Archive'
  '## §No-external-dependency'
  # -- 4 inline structural anchors (labels, not headings) --
  'INDEPENDENCE MODEL'
  'JUROR HARDENING'
  'TRANSCRIPT-ANCHOR'
  'STYLE-BLIND'
  # -- 3 canonical XML tag names: open AND close --
  '<condition>'    '</condition>'
  '<evidence-map>' '</evidence-map>'
  '<anti-accept>'  '</anti-accept>'
  # -- metadata token scheme: canonical never-translate keys + separators --
  'GF·budget·jury·ledger·label'
  'GF·'
  '·budget:'
  '·jury:'
  '·ledger:'
  '·label='
)

run_checks() {
  # $1 = file to check. Prints per-token PASS/FAIL, returns count of failures.
  local file="$1" fails=0 tok
  for tok in "${REQUIRED[@]}"; do
    if grep -Fq -- "$tok" "$file"; then
      printf '  PASS  %s\n' "$tok"
    else
      printf '  FAIL  %s   <-- MISSING\n' "$tok"
      fails=$((fails + 1))
    fi
  done
  return "$fails"
}

main() {
  local target="${1:-$SKILL_DIR/TEMPLATE.md}"
  if [ ! -f "$target" ]; then
    printf 'ERROR: target not found: %s\n' "$target" >&2
    return 2
  fi
  SCRATCH="$(mktemp -d)" || { printf 'ERROR: mktemp failed\n' >&2; return 2; }
  cp "$target" "$SCRATCH/TEMPLATE.md"   # test a COPY; real file is untouched

  printf 'TEMPLATE.md structural-integrity check\n'
  printf 'target : %s\n'   "$target"
  printf 'copy   : %s\n\n' "$SCRATCH/TEMPLATE.md"
  run_checks "$SCRATCH/TEMPLATE.md"
  local fails=$?

  printf '\n'
  if [ "$fails" -eq 0 ]; then
    printf 'RESULT: PASS — all %d structural tokens present\n' "${#REQUIRED[@]}"
    return 0
  fi
  printf 'RESULT: FAIL — %d of %d structural token(s) missing\n' \
    "$fails" "${#REQUIRED[@]}"
  return 1
}

selftest() {
  # Proves the test is discriminating: an intact copy passes, and a copy with
  # one "## §" section surgically removed fails. Never touches the real file.
  local real="$SKILL_DIR/TEMPLATE.md"
  if [ ! -f "$real" ]; then
    printf 'ERROR: real TEMPLATE.md not found: %s\n' "$real" >&2
    return 2
  fi
  SCRATCH="$(mktemp -d)" || { printf 'ERROR: mktemp failed\n' >&2; return 2; }
  cp "$real" "$SCRATCH/green.md"
  # break the copy: delete the whole "## §Fallback" block up to the next "## "
  awk '
    /^## §Fallback/ { del = 1; next }
    del && /^## /   { del = 0 }
    !del            { print }
  ' "$SCRATCH/green.md" > "$SCRATCH/red.md"

  printf '=== SELFTEST (red-proof) ===\n\n'
  printf '[1] intact copy  (expect all PASS / 0 failures):\n'
  run_checks "$SCRATCH/green.md"; local g=$?
  printf '\n[2] broken copy  ("## §Fallback" section removed, expect a FAIL):\n'
  run_checks "$SCRATCH/red.md";   local r=$?
  printf '\nintact-copy failures = %d   broken-copy failures = %d\n' "$g" "$r"
  if [ "$g" -eq 0 ] && [ "$r" -gt 0 ]; then
    printf 'SELFTEST OK: test is discriminating (green=0 fails, red>0 fails)\n'
    return 0
  fi
  printf 'SELFTEST BROKEN: not discriminating — the test would be vacuous\n'
  return 1
}

if [ "${1:-}" = "--selftest" ]; then
  selftest
  exit $?
fi
main "$@"
exit $?