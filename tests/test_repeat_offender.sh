#!/usr/bin/env bash
# test_repeat_offender.sh — locks the DISTINCT-RUN counting of repeat-offender.sh
# (prosecutor 2.0-S3/S4: it must count distinct RUNS, not files; a run's
# EVIDENCE+prosecutor pair is ONE run; GUARDRAILS is not a run). Green+red.
set -u
SKILL="${GF_SKILL_DIR:-$HOME/.claude/skills/goal-forge}"
RO="$SKILL/scripts/repeat-offender.sh"
[ -f "$RO" ] || { echo "TEST-FAIL: repeat-offender.sh not found" >&2; exit 1; }
WORK="$(mktemp -d "${TMPDIR:-/tmp}/ro-test.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
pass=0; fail=0
ok(){ echo "  PASS $1"; pass=$((pass+1)); }
bad(){ echo "  FAIL $1"; fail=$((fail+1)); }

echo "repeat-offender distinct-run test"

# GREEN: two DIFFERENT runs share a class -> [2 runs]
G="$WORK/g"; mkdir -p "$G"
printf '| elle-say kokusu\n'  > "$G/EVIDENCE-runA.md"
printf '| yine elle-say\n'    > "$G/EVIDENCE-runB.md"
printf '# GUARDRAILS\n- x\n'  > "$G/GUARDRAILS.md"
out="$(bash "$RO" "$G" 2>&1)"
printf '%s' "$out" | grep -qE '\[2 runs\] +elle-say' && ok "two-distinct-runs -> [2 runs]" || bad "two-distinct-runs (got: $(printf '%s' "$out" | grep elle-say))"

# RED-1: same run's EVIDENCE + prosecutor pair -> ONE run, NOT reported
R="$WORK/r"; mkdir -p "$R"
printf '| elle-say\n'          > "$R/EVIDENCE-1.4.md"
printf '| elle-say tekrar\n'   > "$R/1.4-prosecutor.md"
printf '# GUARDRAILS\n- x\n'   > "$R/GUARDRAILS.md"
out="$(bash "$RO" "$R" 2>&1)"
printf '%s' "$out" | grep -q "elle-say" && bad "same-run-pair falsely reported" || ok "same-run pair -> 1 run, not reported (S3)"

# RED-2: GUARDRAILS lesson + a SINGLE run -> not a cross-run problem
R2="$WORK/r2"; mkdir -p "$R2"
printf '| session-scope\n'              > "$R2/EVIDENCE-solo.md"
printf '# GUARDRAILS\n- session-scope\n'> "$R2/GUARDRAILS.md"
out="$(bash "$RO" "$R2" 2>&1)"
printf '%s' "$out" | grep -q "session-scope" && bad "GUARDRAILS+1run falsely reported" || ok "GUARDRAILS not a run, single run not reported (S4)"

# candidate framing present (not sold as confirmed)
bash "$RO" "$G" 2>&1 | grep -q "CANDIDATES to verify" && ok "output framed as candidates, not confirmed" || bad "candidate framing missing"

# empty dir -> clean handled exit, no crash
bash "$RO" "$WORK/empty-nonexistent" >/dev/null 2>&1; [ $? -ne 0 ] && ok "missing dir -> clean non-zero exit" || bad "missing dir not handled"

echo "RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
