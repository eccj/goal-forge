#!/bin/bash
# state.sh — live goal progress (v3.0). Regenerates STATE.md wholly from ledger+PLAN
# (script-made, never hand-edited; fields discipline per Anthropic harness lesson).
# Usage: state.sh update <state-file> <ledger> <plan> <goal-label> [note]
set -euo pipefail
[ "${1:-}" = "update" ] || { echo "usage: state.sh update <state-file> <ledger> <plan> <label> [note]"; exit 1; }
OUT="$2"; LED="$3"; PLAN="$4"; LABEL="$5"; NOTE="${6:-}"
DONE=$(grep -c '^\- \[x\]' "$PLAN" 2>/dev/null || true)
TOT=$(grep -c '^\- \[' "$PLAN" 2>/dev/null || true)
ENTRIES=$(grep -c '^### E' "$LED" 2>/dev/null || true)
LAST=$(grep '^### E' "$LED" 2>/dev/null | tail -1 | sed 's/^### //')
{
  echo "# STATE — $LABEL"
  echo "updated: $(date -u +%Y-%m-%dT%H:%M:%SZ) (script-üretimi; elle düzenlenmez)"
  echo ""
  echo "| alan | değer |"
  echo "|------|-------|"
  echo "| ilerleme | $DONE/$TOT madde tamam |"
  echo "| ledger | $ENTRIES girdi |"
  echo "| son-kanıt | ${LAST:-—} |"
  [ -n "$NOTE" ] && echo "| not | $NOTE |"
  echo ""
  echo "## Madde durumu (PLAN'dan)"
  grep '^\- \[' "$PLAN" 2>/dev/null || echo "(plan boş)"
} > "$OUT"
echo "STATE yazıldı: $OUT ($DONE/$TOT tamam, $ENTRIES ledger-girdi)"
