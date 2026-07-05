#!/usr/bin/env bash
# repeat-offender.sh — cross-run system-problem finder.
# "The same failure showing up in two different runs is not two bugs; it's one
# system problem wearing two costumes." Scans every EVIDENCE-*.md ledger + the
# prosecutor reports + GUARDRAILS lessons in a goals/ dir, and reports each
# recurring error-class together with the DISTINCT runs it appears in, ranked
# by spread. Deterministic (sorted). Deps: bash + grep + sort/awk only.
# Usage: repeat-offender.sh [goals-dir]   (default: ./goals or the skill's goals)
set -u
DIR="${1:-}"
if [ -z "$DIR" ]; then
  for c in "./goals" "$HOME/.claude/skills/goal-forge/goals"; do
    [ -d "$c" ] && DIR="$c" && break
  done
fi
[ -n "$DIR" ] && [ -d "$DIR" ] || { echo "usage: repeat-offender.sh <goals-dir>" >&2; exit 2; }

# Files that record failures across runs.
FILES=""
while IFS= read -r _ff; do FILES="$FILES$_ff"$'\n'; done < <(ls "$DIR"/EVIDENCE-*.md "$DIR"/*prosecutor*.md "$DIR"/GUARDRAILS.md 2>/dev/null | sort)
[ -n "$FILES" ] || { echo "no ledger/prosecutor/GUARDRAILS files in $DIR" >&2; exit 2; }
NFILES=$(printf '%s' "$FILES" | grep -c .)

# Error-class keyword set: a curated seed of recurring classes + auto-mined
# bracket tags from GUARDRAILS lessons (e.g. "[skills5-S4]" -> skills5-S4).
SEED=(
  "elle-say|hand-typed|snippet-say"        # fabricated/uncomputed numbers
  "assert|sessiz-no-op|silent"             # assert-less silent failure
  "grep.?yetmez|grep-değil|theater|tiyatro" # grep-not-enough / verification theater
  "session-scope|oturum-kapsam|session_id" # session-scoping
  "escape|kaçır"                           # escape-char / regex escaping
  "fail-open|injection"                    # fail-open / injection
  "over-claim|overclaim|µs|micro-fast|abart" # overclaim
  "master-MERGE|master-merge"              # merge discipline
  "post-gate.*push|unpush|not pushed|push.?edilmedi"  # post-gate fix left unpushed (1.6-J2)
)
echo "== repeat-offender scan: $DIR ($NFILES files) =="
found=0
scan_key() {  # $1=label  $2=ERE
  local label="$1" ere="$2" hits="" f n=0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if grep -qiE -- "$ere" "$f" 2>/dev/null; then hits="$hits $(basename "$f")"; n=$((n+1)); fi
  done < <(printf '%s' "$FILES")
  if [ "$n" -ge 2 ]; then                       # recurs across >=2 distinct sources
    printf '%03d|  [%d runs] %-22s :%s\n' "$n" "$n" "$label" "$hits"
  fi
}
# Rank by spread (numeric prefix), strip prefix, count.
RESULTS="$(for pair in "${SEED[@]}"; do lbl="${pair%%|*}"; scan_key "$lbl" "$pair"; done | sort -rn | sed 's/^[0-9]*|//')"
found=$(printf '%s' "$RESULTS" | grep -c .)
[ "$found" -gt 0 ] && printf '%s\n' "$RESULTS"
echo "-- system problems (>=2 runs): $found --"
[ "$found" -gt 0 ] && echo "-- these are ONE problem each, not N; fix the class, not the instances --"
exit 0
