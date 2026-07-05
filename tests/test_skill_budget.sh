#!/usr/bin/env bash
# test_skill_budget.sh — regression test for the 1.9 SKILL.md size invariant.
#
# Invariant under test (replaced the old 97-line freeze in 1.9):
#   (A) SKILL.md measures <= 8000 chars by the CANONICAL tool
#       (scripts/ledger.sh measure — UTF-8 wc -m, trailing newline stripped).
#       Chars, not lines, are the metric.
#   (B) The frontmatter `description:` is <= 45 words (it sits in every
#       session's context; the body loads on invoke).
#
# Self-verified GREEN + RED:
#   GREEN: the real SKILL.md passes both bounds.
#   RED:   an oversized fixture (real SKILL + padding past 8000) must FAIL the
#          same check — proving the assertion actually bites.
#
# Deps: bash + the skill's own ledger.sh (shasum) only. Read-only on the real
# skill; fixtures live in mktemp scratch. Exit 0 = pass.

set -u
SKILL_DIR="${GF_SKILL_DIR:-/Users/emrew/.claude/skills/goal-forge}"
LED="$SKILL_DIR/scripts/ledger.sh"
SKILL="$SKILL_DIR/SKILL.md"
LIMIT=8000
DESC_LIMIT=45

fail() { echo "TEST-FAIL: $*" >&2; exit 1; }
pass() { echo "TEST-PASS: $*"; }

[ -f "$SKILL" ] || fail "SKILL.md not found at $SKILL"
[ -f "$LED" ]   || fail "ledger.sh not found at $LED"

measure_chars() { # canonical measure -> just the number
  bash "$LED" measure "$1" 2>/dev/null | sed -n 's/^\([0-9][0-9]*\) chars.*/\1/p'
}

# --- GREEN A: real SKILL.md within the char budget ---------------------------
chars="$(measure_chars "$SKILL")"
case "$chars" in ''|*[!0-9]*) fail "could not parse a char count from ledger.sh measure";; esac
[ "$chars" -le "$LIMIT" ] || fail "SKILL.md is ${chars} chars > ${LIMIT} (budget invariant broken)"
pass "SKILL.md = ${chars} chars <= ${LIMIT} (canonical measure)"

# --- GREEN B: frontmatter description <= 45 words ----------------------------
desc_words="$(sed -n 's/^description: //p' "$SKILL" | wc -w | tr -d ' ')"
case "$desc_words" in ''|*[!0-9]*) fail "could not extract the description line";; esac
[ "$desc_words" -ge 1 ] || fail "description line missing/empty"
[ "$desc_words" -le "$DESC_LIMIT" ] || fail "description = ${desc_words} words > ${DESC_LIMIT}"
pass "description = ${desc_words} words <= ${DESC_LIMIT}"

# --- RED: an oversized fixture must FAIL the same check ----------------------
WORK="$(mktemp -d "${TMPDIR:-/tmp}/gf-skillbudget.XXXXXX")" || fail "mktemp failed"
trap 'rm -rf "$WORK"' EXIT
BIG="$WORK/oversized-skill.md"
cp "$SKILL" "$BIG"
need=$(( LIMIT - chars + 100 ))            # pad definitively past the limit
awk -v n="$need" 'BEGIN{ s=""; while (length(s) < n) s = s "x"; print s }' >> "$BIG"
big_chars="$(measure_chars "$BIG")"
[ "$big_chars" -gt "$LIMIT" ] || fail "RED fixture failed to exceed the limit (got ${big_chars})"
pass "RED fixture = ${big_chars} chars > ${LIMIT} -> correctly rejected by the same bound"

echo "ALL-PASS: SKILL budget invariant (chars<=${LIMIT}, description<=${DESC_LIMIT}w) green+red."
