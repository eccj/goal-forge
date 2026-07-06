#!/bin/bash
# retro.sh — post-seal retro scan (v3.1, minimal; presence-pattern uyarlaması).
# NO daemon, NO watcher: seal-time bir aralık kaydı + SONRAKİ derlemenin
# önkoşulunda tek komutluk tarama. Bir seal'den sonra o aralıktaki iş
# revert/amend edildiyse, bir SONRAKİ goal derlenirken 1 satırda görünür
# (sessiz gerileme, GUARDRAILS'e ders adayı olur).
#
#   retro.sh seal  <retro-log> <proj-dir> <label> <start-sha>   # aralığı arşivle (end=HEAD)
#   retro.sh check <retro-log> <proj-dir>                       # kayıtlı aralıkları tara → satır/aralık
#
# check çıktısı (aralık başına 1 satır):
#   retro: <label> a1b2c3d..e4f5a6b — temiz (revert=0, aralık-erişilebilir)
#   retro: <label> ... — UYARI: aralık-dosyalarına dokunan N revert / end-sha erişilemez (rewrite/amend)
set -euo pipefail
CMD="${1:-}"; LOG="${2:-}"; PROJ="${3:-}"
case "$CMD" in
  seal)
    LABEL="$4"; START="$5"
    END=$(git -C "$PROJ" rev-parse HEAD)
    START=$(git -C "$PROJ" rev-parse "$START^{commit}")  # sembolik ref (HEAD~1) sabit sha'ya çözülür
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)|$LABEL|$START|$END" >> "$LOG"
    echo "retro-seal kaydı: $LABEL $(git -C "$PROJ" rev-parse --short "$START")..$(git -C "$PROJ" rev-parse --short "$END") → $LOG" ;;
  check)
    [ -f "$LOG" ] || { echo "retro: kayıtlı seal-aralığı yok ($LOG) — tarama boş-geçti"; exit 0; }
    WARN=0
    while IFS='|' read -r TS LABEL START END; do
      [ -n "$END" ] || continue
      S7=$(echo "$START" | cut -c1-7); E7=$(echo "$END" | cut -c1-7)
      if ! git -C "$PROJ" cat-file -e "$END" 2>/dev/null || \
         ! git -C "$PROJ" merge-base --is-ancestor "$END" HEAD 2>/dev/null; then
        echo "retro: $LABEL $S7..$E7 — UYARI: end-sha HEAD'den erişilemez (rewrite/amend olası)"; WARN=1; continue
      fi
      # aralığın dosyalarına dokunan, aralıktan SONRAKİ revert commitleri
      RFILES=$(git -C "$PROJ" diff --name-only "$START" "$END")
      NREV=0
      for C in $(git -C "$PROJ" log --format=%H -i --grep=revert "$END"..HEAD); do
        if git -C "$PROJ" show --name-only --format= "$C" | grep -qxF -f <(echo "$RFILES") 2>/dev/null; then
          NREV=$((NREV+1))
        fi
      done
      if [ "$NREV" -gt 0 ]; then
        echo "retro: $LABEL $S7..$E7 — UYARI: aralık-dosyalarına dokunan $NREV revert (seal-sonrası gerileme?)"; WARN=1
      else
        echo "retro: $LABEL $S7..$E7 — temiz (revert=0, aralık-erişilebilir)"
      fi
    done < "$LOG"
    exit $WARN ;;
  *) echo "usage: retro.sh seal <retro-log> <proj-dir> <label> <start-sha> | check <retro-log> <proj-dir>"; exit 1 ;;
esac
