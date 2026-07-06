#!/bin/bash
# state.sh — live goal progress (v3.0). Regenerates STATE.md wholly from ledger+PLAN
# (script-made, never hand-edited; fields discipline per Anthropic harness lesson).
# Usage: state.sh update      <state-file> <ledger> <plan> <goal-label> [note]
#        state.sh resume-card <out-file>   <ledger> <plan> <goal-label> <mission> [pin]
# resume-card (v3.1): fresh-session handoff card (TEMPLATE §Resume) — heavy
# goals continue in a NEW session when the token-report diagnostic flags
# avg-context/request > 100k; the card carries everything the new session needs.
set -euo pipefail
CMD="${1:-}"
case "$CMD" in update|resume-card) ;; *)
  echo "usage: state.sh update <state-file> <ledger> <plan> <label> [note] | resume-card <out> <ledger> <plan> <label> <mission> [pin]"; exit 1 ;;
esac
OUT="$2"; LED="$3"; PLAN="$4"; LABEL="$5"; NOTE="${6:-}"
if [ "$CMD" = "resume-card" ]; then
  MISSION="${6:?mission gerekli}"; PIN="${7:-}"
  ENTRIES=$(grep -c '^### E' "$LED" 2>/dev/null || true)
  LAST=$(grep '^### E' "$LED" 2>/dev/null | tail -1 | sed 's/^### //')
  NEXT=$(grep -m1 '^\- \[ \]' "$PLAN" 2>/dev/null | sed 's/^\- \[ \] *//' || true)  # all-done/boş-plan: pipefail'i öldürmesin (savcı-S4)
  MDIR=$(cd "$(dirname "$LED")" && pwd)
  {
    echo "# RESUME — $LABEL (taze-oturum devir-kartı; script-üretimi, elle düzenlenmez)"
    echo "updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    echo "- **misyon:** $MISSION"
    [ -n "$PIN" ] && echo "- **PIN:** $PIN"
    echo "- **ledger:** $LED ($ENTRIES girdi · son: ${LAST:-—})"
    echo "- **sıradaki:** ${NEXT:-tüm PLAN maddeleri tamam → GATE/tribunal aşaması}"
    echo "- **token-marker:** $MDIR/.tokens-marker (KORU — yeniden mark ETME)"
    echo ""
    echo "## Devir talimatı (yeni oturumda sırayla)"
    echo "1. Bu kartı ve \`goals/GUARDRAILS.md\`'yi oku; PIN'i İLK mesajda yeniden beyan et."
    echo "2. \`scripts/ledger.sh verify $LED\` — CHAIN INTACT görmeden iş yapma."
    echo "3. Token-muhasebesi: ESKİ oturum raporu marker'la, YENİ oturumunki 0 ile;"
    echo "   toplam = ikisinin toplamı; eski-oturum JSONL yolunu ledger'a not düş."
    echo "4. Sıradaki maddeden devam; kanıt standardı/tribunal AYNEN sürer."
  } > "$OUT"
  echo "RESUME yazıldı: $OUT (sıradaki: ${NEXT:-—})"
  exit 0
fi
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
