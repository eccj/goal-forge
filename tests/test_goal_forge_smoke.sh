#!/usr/bin/env bash
# test_goal_forge_smoke.sh — END-TO-END SMOKE test for the goal-forge skill.
#
# Exercises the full loop on SCRATCH COPIES (never mutates the real skill):
#   1. assemble a tiny VALID /goal text (metadata + 1 D# + <condition>)
#   2. ledger.sh measure   -> assert char-count <=4000 AND "...limit 4000 chars: OK"
#   3. ledger.sh append     -> append a fake evidence entry to a scratch ledger (x2, to chain)
#   4. ledger.sh verify     -> assert "CHAIN INTACT"
#   5. grep the goal        -> assert every required STRUCTURAL token is present
#
# Deps: bash + shasum (via ledger.sh) + grep only. Deterministic. Self-contained.
#
# Red-proof hook (deliberate break, for the RED run only):
#   GF_SMOKE_BREAK=malformed-goal  -> assemble the goal WITHOUT its <condition>
#   evaluator layer. The structural grep then fails -> exit non-zero. Default
#   (unset) is the GREEN run.
#
# Skill location override for portability: GF_SKILL_DIR (default: real install).

set -uo pipefail

SKILL="${GF_SKILL_DIR:-/Users/emrew/.claude/skills/goal-forge}"
REAL_LEDGER="$SKILL/scripts/ledger.sh"
BREAK="${GF_SMOKE_BREAK:-none}"

fails=0
pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; fails=$((fails+1)); }

# --- preconditions -----------------------------------------------------------
[ -f "$REAL_LEDGER" ] || { echo "FATAL: ledger.sh not found at $REAL_LEDGER" >&2; exit 2; }

SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/gf-smoke.XXXXXX")" || { echo "FATAL: mktemp failed" >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

# Work on a COPY of the tool so the real skill is never touched.
LEDGER="$SCRATCH/ledger.sh"
cp "$REAL_LEDGER" "$LEDGER"

GOAL="$SCRATCH/goal.txt"
LEDFILE="$SCRATCH/EVIDENCE-smoke.md"

# --- assemble a tiny VALID /goal (metadata + 1 D# + condition) ---------------
# Worker layer (always present). Note: DONE-MEANS intentionally does NOT contain
# the literal "</condition>" closing tag, so the closing-tag grep truly requires
# the evaluator layer to exist.
{
cat <<'HEAD'
[GF·goal·budget:20·jury:std·ledger:goals/EVIDENCE-smoke.md·label=D#]
DONE-MEANS (summary — full definition in the condition block below): D1 is
E-D1 raw-evidenced + a UNANIMOUS jury verdict in the final report.

═══ WORKER LAYER ═══
MISSION: the smoke-test fixture reaches a verifiable finished state.

TASKS (evidence appended to the ledger via scripts/ledger.sh, label=D#):
□ D1 create/update PLAN.md — evidence: file contents + the ledger append line.
FORBIDDEN: no scope creep · no external API · no network juror.
LEDGER: raw outputs via ledger.sh append; full text stored verbatim.
PROCESS: on done-claim COMPLETION GATE (mechanical checks re-run) → single
tool-equipped auditor APPROVE/REJECT.
SAFETY: 20 turns; below 30% only verification+closure; else honest status report.
HEAD

# Evaluator layer — OMITTED when GF_SMOKE_BREAK=malformed-goal (the red case).
if [ "$BREAK" != "malformed-goal" ]; then
cat <<'TAIL'

═══ EVALUATOR LAYER ═══
<condition>
DONE if and only if the transcript shows an E-D1-labeled raw command+output
block for D1 AND the auditor's APPROVE verdict AND an item-by-item evidence
dump. If any is missing: NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (PLAN)
</evidence-map>
<anti-accept>
NOT met if ANY appear: "done" claimed with no raw output · no auditor verdict ·
D1 never mentioned · an unresolved FORBIDDEN violation.
</anti-accept>
TAIL
fi
} > "$GOAL"

echo "=== goal-forge END-TO-END SMOKE (break=$BREAK) ==="
echo "scratch: $SCRATCH"
echo

# --- STAGE 1: measure --------------------------------------------------------
m_out="$(bash "$LEDGER" measure "$GOAL")"
echo "[measure] $m_out"
# first whitespace-delimited field is the canonical char count
read -r chars _ <<<"$m_out"
if [[ "$chars" =~ ^[0-9]+$ ]] && [ "$chars" -le 4000 ]; then
  pass "measure: $chars chars <= 4000"
else
  fail "measure: char count '$chars' not a number <=4000"
fi
if [[ "$m_out" == *"/goal limit 4000 chars: OK"* ]]; then
  pass "measure: tool reports limit OK"
else
  fail "measure: tool did not report 'limit 4000 chars: OK'"
fi

# --- STAGE 2: append (fake evidence, two entries to exercise the chain) ------
e1="$SCRATCH/e1.txt"; e2="$SCRATCH/e2.txt"
printf '%s\n' '$ printf "PLAN v1\n" > PLAN.md && cat PLAN.md' 'PLAN v1' > "$e1"
printf '%s\n' '$ printf "PLAN v2\n" > PLAN.md && cat PLAN.md' 'PLAN v2 (superseding)' > "$e2"

a1="$(bash "$LEDGER" append "$LEDFILE" D1 "$e1")"; echo "[append] $a1"
a2="$(bash "$LEDGER" append "$LEDFILE" D1 "$e2")"; echo "[append] $a2"
if [[ "$a1" == *"appended (hash: "* ]] && [[ "$a2" == *"appended (hash: "* ]]; then
  pass "append: two evidence entries written to scratch ledger"
else
  fail "append: did not echo the expected 'appended (hash: ...)' lines"
fi

# --- STAGE 3: verify ---------------------------------------------------------
if v_out="$(bash "$LEDGER" verify "$LEDFILE")"; then v_rc=0; else v_rc=$?; fi
echo "[verify] ${v_out//$'\n'/ | }"
if [ "$v_rc" -eq 0 ] && [[ "$v_out" == *"CHAIN INTACT"* ]]; then
  pass "verify: CHAIN INTACT (exit 0)"
else
  fail "verify: expected 'CHAIN INTACT' + exit 0 (got rc=$v_rc)"
fi

# --- STAGE 4: structural token grep -----------------------------------------
# Canonical never-translate tokens the compiler MUST emit (per TEMPLATE.md).
required=(
  '[GF·'          # metadata open
  'budget:'       # turn budget key
  'jury:'         # tribunal key
  'ledger:'       # ledger path key
  'label=D#'      # deliverable label scheme
  '□ D1'          # at least one deliverable task line
  'E-D1'          # evidence id scheme
  '<condition>'   # evaluator layer open
  '</condition>'  # evaluator layer CLOSE (absent in a malformed goal)
  '<evidence-map>'
  '<anti-accept>'
)
missing=0
for tok in "${required[@]}"; do
  if ! grep -qF -- "$tok" "$GOAL"; then
    echo "[structure] MISSING token: $tok"
    missing=$((missing+1))
  fi
done
if [ "$missing" -eq 0 ]; then
  pass "structure: all ${#required[@]} required tokens present"
else
  fail "structure: $missing required token(s) missing"
fi

# --- verdict -----------------------------------------------------------------
echo
if [ "$fails" -eq 0 ]; then
  echo "RESULT: GREEN — end-to-end smoke passed (measure→append→verify→structure)"
  exit 0
else
  echo "RESULT: RED — $fails stage(s) failed"
  exit 1
fi