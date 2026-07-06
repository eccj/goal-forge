#!/usr/bin/env bash
# test_ledger_tamper.sh — regression test for goal-forge ledger.sh TAMPER-EVIDENCE.
#
# Deps: bash + shasum + python3 ONLY (self-contained, deterministic, no external API).
# NEVER mutates the real skill: it only *executes* ledger.sh and writes into a mktemp
# scratch dir. Point it at a (possibly mutated) skill root via $1.
#
# Asserts three documented tamper-evidence properties:
#   (A) label mutation — editing the "### E# · <label>" header — does NOT break the
#       chain, because only the hashed body (entry_text) matters. [documented behavior]
#   (B) body mutation — editing text inside <<<ENTRY … ENTRY>>> — DOES break the chain,
#       and the break CASCADES forward (later prev-links fail too: true chaining).
#   (C) a from-scratch re-forge over ALTERED evidence verifies CLEAN — the keyless
#       weakness the "Honest scope" comment openly claims. The *same* falsified body
#       that is caught as an in-place edit in (B) sails through when re-forged in (C).
#
# Exit 0 => all assertions green. Exit 1 => at least one assertion red (regression).

set -uo pipefail   # NOT -e: we deliberately run commands that exit nonzero (broken verify)

SKILL="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LEDGER="$SKILL/scripts/ledger.sh"

[ -f "$LEDGER" ] || { echo "SETUP-FAIL: no ledger.sh at $LEDGER"; exit 2; }
command -v shasum  >/dev/null 2>&1 || { echo "SETUP-FAIL: shasum missing";  exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "SETUP-FAIL: python3 missing"; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/ledgertamper.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

PASS=0; FAILN=0
ok()  { PASS=$((PASS+1));   printf 'PASS  %s\n' "$1"; }
bad() { FAILN=$((FAILN+1)); printf 'FAIL  %s\n' "$1"; }

# Exact in-file string replace via python3; nonzero exit unless it replaces exactly N.
pyreplace() { # <file> <old> <new> <expected_count>
  python3 - "$@" <<'PY'
import sys
f, old, new, exp = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
s = open(f, encoding='utf-8').read()
c = s.count(old)
if c != exp:
    sys.stderr.write("replace count %d != %d for %r\n" % (c, exp, old)); sys.exit(3)
open(f, 'w', encoding='utf-8').write(s.replace(old, new))
PY
}

# Build a 2-entry ledger from given evidence using the real append path.
build_ledger() { # <ledger-path> <label1> <body1> <label2> <body2>
  local L="$1"
  printf '%s' "$3" > "$WORK/e1.txt"
  printf '%s' "$5" > "$WORK/e2.txt"
  bash "$LEDGER" append "$L" "$2" "$WORK/e1.txt" >/dev/null || { bad "append E1 failed"; return 1; }
  bash "$LEDGER" append "$L" "$4" "$WORK/e2.txt" >/dev/null || { bad "append E2 failed"; return 1; }
}

run_verify() { # <ledger-path> ; sets VOUT (combined stdout+stderr) and VRC (exit code)
  VOUT="$(bash "$LEDGER" verify "$1" 2>&1)"; VRC=$?
}

has() { printf '%s' "$1" | grep -q -- "$2"; }

echo "=== ledger.sh TAMPER-EVIDENCE regression — skill: $SKILL ==="

# Evidence: an honest ledger, and one falsified line reused across (B) and (C).
HONEST_E1=$'check: build passes\nexit: 0'
HONEST_E2=$'check: 42 tests green\nexit: 0'
FALSIFIED_E1=$'check: build passes\nexit: 1'   # the LIE: build actually failed

# ---------------------------------------------------------------------------
# (A) LABEL mutation does NOT break the chain — only the hashed body matters.
# ---------------------------------------------------------------------------
build_ledger "$WORK/a.ledger" build "$HONEST_E1" tests "$HONEST_E2" || true
run_verify "$WORK/a.ledger"
if [ "$VRC" -eq 0 ] && has "$VOUT" 'CHAIN INTACT'; then
  : # baseline clean, as required before we can attribute any change to the mutation
else
  bad "A-baseline: freshly forged honest ledger should verify CLEAN (rc=$VRC) :: $VOUT"
fi

cp "$WORK/a.ledger" "$WORK/a.mut"
# rewrite ONLY the header line's label text; body 'build' token is left untouched.
if pyreplace "$WORK/a.mut" '### E1 · build' '### E1 · HIJACKED-LABEL' 1; then
  run_verify "$WORK/a.mut"
  # Chain must stay intact AND verify must have actually READ the mutated label
  # (proves the header changed and was parsed, yet contributes nothing to the hash).
  if [ "$VRC" -eq 0 ] && has "$VOUT" 'CHAIN INTACT' && has "$VOUT" 'HIJACKED-LABEL'; then
    ok "A: label (### E# header) mutation does NOT break the chain — hash is over body only"
  else
    bad "A: label mutation changed verify result — header must NOT be hashed (rc=$VRC) :: $VOUT"
  fi
else
  bad "A: could not locate unique '### E1 · build' header to mutate"
fi

# ---------------------------------------------------------------------------
# (B) BODY mutation DOES break the chain, and the break CASCADES forward.
# ---------------------------------------------------------------------------
cp "$WORK/a.ledger" "$WORK/b.mut"
# flip the recorded outcome inside E1's body: 'exit: 0' -> 'exit: 1' (in-place edit).
if pyreplace "$WORK/b.mut" $'| check: build passes\n| exit: 0' $'| check: build passes\n| exit: 1' 1; then
  run_verify "$WORK/b.mut"
  # must fail (nonzero) AND report E1 hash mismatch AND cascade to E2 prev-link.
  if [ "$VRC" -ne 0 ] \
     && has "$VOUT" 'CHAIN BROKEN' \
     && has "$VOUT" 'FAIL at E1' && has "$VOUT" 'hash mismatch' \
     && has "$VOUT" 'FAIL at E2' && has "$VOUT" 'prev-link broken'; then
    ok "B: body mutation DOES break the chain; break cascades E1 hash -> E2 prev-link"
  else
    bad "B: in-place body edit was NOT fully detected (rc=$VRC) :: $VOUT"
  fi
else
  bad "B: could not locate unique E1 body line to mutate"
fi

# ---------------------------------------------------------------------------
# (C) From-scratch RE-FORGE over ALTERED evidence verifies CLEAN (keyless weakness).
#     Same falsified body as (B), but authored via append instead of in-place edit.
# ---------------------------------------------------------------------------
build_ledger "$WORK/c.ledger" build "$FALSIFIED_E1" tests "$HONEST_E2" || true
run_verify "$WORK/c.ledger"
if [ "$VRC" -eq 0 ] && has "$VOUT" 'CHAIN INTACT'; then
  ok "C: from-scratch re-forge over ALTERED evidence verifies CLEAN — keyless, as documented"
else
  bad "C: re-forged ledger should verify CLEAN (keyless-scope claim) (rc=$VRC) :: $VOUT"
fi

# Cross-check tying (B) and (C): identical falsified 'exit: 1' body — caught in-place,
# clean when re-forged. Prove the two ledgers really differ only by that provenance.
if has "$(cat "$WORK/c.ledger")" 'exit: 1'; then
  ok "C-contrast: identical falsified 'exit: 1' is REJECTED as edit (B) yet ACCEPTED re-forged (C)"
else
  bad "C-contrast: expected falsified 'exit: 1' body inside the re-forged ledger"
fi

# ---------------------------------------------------------------------------
# Documentation anchors: the two above are asserted as DOCUMENTED behavior.
# ---------------------------------------------------------------------------
if grep -q 'sha256(prev' "$LEDGER"; then
  ok "DOC-A: ledger.sh documents hash = sha256(prev + entry) — header/label is out of scope"
else
  bad "DOC-A: ledger.sh no longer documents the body-only hash formula"
fi
if grep -qi 'keyless' "$LEDGER" && grep -qi 're-forge' "$LEDGER"; then
  ok "DOC-C: ledger.sh openly documents the keyless re-forge weakness (honest scope)"
else
  bad "DOC-C: ledger.sh no longer documents the keyless re-forge weakness"
fi

echo "--- ${PASS} passed, ${FAILN} failed ---"
[ "$FAILN" -eq 0 ] && { echo "GREEN: tamper-evidence properties hold"; exit 0; } \
                   || { echo "RED: tamper-evidence regression detected"; exit 1; }