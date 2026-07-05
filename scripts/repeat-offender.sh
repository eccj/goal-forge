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
[ -n "$DIR" ] && [ -d "$DIR" ] || { echo "usage: repeat-offender.sh <goals-dir> [self-run-stem]" >&2; exit 2; }
SELF="${2:-__none__}"

# Files that record failures across runs.
FILES=""
while IFS= read -r _ff; do FILES="$FILES$_ff"$'\n'; done < <(ls "$DIR"/EVIDENCE-*.md "$DIR"/*prosecutor*.md "$DIR"/GUARDRAILS.md 2>/dev/null | sort)
[ -n "$FILES" ] || { echo "no ledger/prosecutor/GUARDRAILS files in $DIR" >&2; exit 2; }
NFILES=$(printf '%s' "$FILES" | grep -c .)

# Curated seed of recurring error-classes. NOTE: this is grep over prose, so a
# hit is a CANDIDATE to verify against the cited files, not a confirmed problem
# (a generic word like "escape" can match innocent text). Classes outside the
# seed are invisible — this surfaces known recurring classes, it is not a scanner.
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
echo "== repeat-offender: $DIR ($NFILES files) — CANDIDATES to verify, not confirmed =="
found=0
scan_key() {  # $1=label  $2=ERE
  local label="$1" ere="$2" runs="" guard="" f b stem
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    grep -qiE -- "$ere" "$f" 2>/dev/null || continue
    b="$(basename "$f")"
    case "$b" in
      GUARDRAILS.md) guard=" +GUARDRAILS"; continue ;;         # lessons file: not a run
      EVIDENCE-$SELF.md|$SELF-*) continue ;;                    # this scan's own ledger: exclude self-feedback
    esac
    # run-stem: strip EVIDENCE- prefix + role/.md suffixes -> the run id
    stem="${b#EVIDENCE-}"; stem="${stem%.md}"
    stem="${stem%-prosecutor}"; stem="${stem%-redteam-verdicts}"
    stem="${stem%-J1-verdict}"; stem="${stem%-J2-verdict}"; stem="${stem%-J3-haiku-verdict}"
    stem="${stem%-gate-verdict}"; stem="${stem%-diet-prosecutor}"; stem="${stem%-prosecutor.md}"
    runs="$runs$stem"$'\n'
  done < <(printf '%s' "$FILES")
  # distinct run count
  local n uniq
  uniq="$(printf '%s' "$runs" | grep . | sort -u)"
  n=$(printf '%s' "$uniq" | grep -c .)
  if [ "$n" -ge 2 ]; then                       # recurs across >=2 DISTINCT runs
    printf '%03d|  [%d runs] %-22s : %s%s\n' "$n" "$n" "$label" "$(printf '%s ' $uniq)" "$guard"
  fi
}
# Rank by spread (numeric prefix), strip prefix, count.
RESULTS="$(for pair in "${SEED[@]}"; do lbl="${pair%%|*}"; scan_key "$lbl" "$pair"; done | sort -rn | sed 's/^[0-9]*|//')"
found=$(printf '%s' "$RESULTS" | grep -c .)
[ "$found" -gt 0 ] && printf '%s\n' "$RESULTS"
echo "-- candidate classes (>=2 distinct runs): $found — verify each against its cited runs --"
[ "$found" -gt 0 ] && echo "-- these are ONE problem each, not N; fix the class, not the instances --"
exit 0
