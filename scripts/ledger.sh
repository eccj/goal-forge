#!/usr/bin/env bash
# ledger.sh — append-only Evidence Ledger with a sha256 hash chain.
# Dependencies: bash + shasum (macOS/Linux built-ins). Nothing else.
#
#   ledger.sh append <ledger-file> <label> <entry-file>
#   ledger.sh verify <ledger-file>
#   ledger.sh measure <file>       — canonical char count (LINT #9): trailing
#       newlines stripped, UTF-8 locale enforced (self-checks against the
#       C-locale byte trap), method-labeled output; bytes shown but NOT the metric.
#
# Chain: hash = sha256(prev + "\n--\n" + entry_text); first entry chains from
# the literal string GENESIS. verify recomputes the chain from GENESIS and
# PROPAGATES the RECOMPUTED hash forward — an early corruption therefore fails
# every later prev-link too (true chaining).
#
# Storage: entry lines are stored verbatim but PREFIXED with "| " between the
# <<<ENTRY / ENTRY>>> markers, so evidence that itself contains ledger tokens
# ("hash: ...", "### E...", nested verify output) can never be parsed as
# structure — format injection is impossible by construction. verify strips
# the prefix before hashing, so hashes are over the ORIGINAL text.
#
# Honest scope (not a signature): the chain is tamper-EVIDENT against in-place
# edits of a ledger you already hold. It is keyless — anyone with this script
# can re-forge a whole new ledger from altered evidence. The guarantee against
# that is the Tribunal re-running commands and cross-checking the transcript;
# the chain is an audit aid, not cryptographic authentication.
#
# Normalization: $(cat) drops trailing newlines, so entries differing only in
# trailing blank lines hash identically; empty entries are rejected.
#
# Concurrency: append takes a mkdir-based lock (<ledger>.lock) — portable to
# macOS (no flock). Parallel appends queue instead of interleaving.

set -euo pipefail

die() { echo "ledger.sh: $*" >&2; exit 1; }

hash_of() { # $1=prev  $2=entry-text
  printf '%s\n--\n%s' "$1" "$2" | shasum -a 256 | cut -d' ' -f1
}

cmd="${1:-}"; ledger="${2:-}"
[ -n "$cmd" ] && [ -n "$ledger" ] || die "usage: ledger.sh append|verify <ledger-file> [...] | measure <file>"

case "$cmd" in
  append)
    label="${3:-}"; entry_file="${4:-}"
    [ -n "$label" ] && [ -f "$entry_file" ] || die "usage: ledger.sh append <ledger-file> <label> <entry-file>"
    entry=$(cat "$entry_file")
    [ -n "$entry" ] || die "empty entry (nothing to attest)"

    lock="${ledger}.lock"; tries=0
    until mkdir "$lock" 2>/dev/null; do
      tries=$((tries+1)); [ "$tries" -lt 50 ] || die "lock timeout: $lock held too long"
      sleep 0.1
    done
    trap 'rmdir "$lock" 2>/dev/null || true' EXIT

    prev=$(grep '^hash: ' "$ledger" 2>/dev/null | tail -1 | cut -d' ' -f2 || true)
    prev="${prev:-GENESIS}"
    seq=$(( $(grep -c '^### E' "$ledger" 2>/dev/null || true) + 1 ))
    h=$(hash_of "$prev" "$entry")
    {
      echo "### E${seq} · ${label}"
      echo "<<<ENTRY"
      printf '%s\n' "$entry" | sed 's/^/| /'
      echo "ENTRY>>>"
      echo "prev: ${prev}"
      echo "hash: ${h}"
      echo
    } >> "$ledger"
    rmdir "$lock" 2>/dev/null || true; trap - EXIT
    echo "E${seq} appended (hash: ${h})"
    ;;

  verify)
    [ -f "$ledger" ] || die "no such ledger: $ledger"
    expected_prev="GENESIS"; n=0; fail=0; in_entry=0; entry=""; cur=""
    while IFS= read -r line; do
      if [ "$in_entry" = 1 ] && [ "$line" != "ENTRY>>>" ]; then
        # inside entry: strip the "| " storage prefix; nothing here is structure
        entry="${entry}${line#| }"$'\n'
        continue
      fi
      case "$line" in
        '### E'*) n=$((n+1)); entry=""; cur="${line#\#\#\# }" ;;
        '<<<ENTRY') in_entry=1; entry="" ;;
        'ENTRY>>>') in_entry=0; entry="${entry%$'\n'}" ;;
        'prev: '*)
          prev_claim="${line#prev: }"
          [ "$prev_claim" = "$expected_prev" ] || { echo "FAIL at ${cur}: prev-link broken (claims ${prev_claim:0:12}…, recomputed chain says ${expected_prev:0:12}…)"; fail=1; } ;;
        'hash: '*)
          hash_claim="${line#hash: }"
          recomputed=$(hash_of "$expected_prev" "$entry")
          if [ "$recomputed" = "$hash_claim" ]; then
            echo "OK   ${cur} (${hash_claim:0:12}…)"
          else
            echo "FAIL at ${cur}: hash mismatch (recomputed ${recomputed:0:12}…, recorded ${hash_claim:0:12}…) — entry text was altered"
            fail=1
          fi
          expected_prev="$recomputed" ;;   # propagate RECOMPUTED hash: early break cascades
      esac
    done < "$ledger"
    [ "$n" -gt 0 ] || die "empty ledger"
    if [ "$fail" = 0 ]; then echo "CHAIN INTACT (${n} entries, GENESIS→tip recomputed)"; else echo "CHAIN BROKEN"; exit 1; fi
    ;;

  measure)
    f="$ledger"   # second arg is the file to measure
    [ -f "$f" ] || die "no such file: $f (usage: ledger.sh measure <file>)"
    # pick a UTF-8 locale; die if none works (C-locale makes wc -m count bytes)
    for loc in C.UTF-8 en_US.UTF-8 tr_TR.UTF-8; do
      if [ "$(printf 'é' | LC_ALL=$loc wc -m 2>/dev/null | tr -d ' ')" = "1" ]; then LOC=$loc; break; fi
    done
    [ -n "${LOC:-}" ] || die "no UTF-8 locale available — wc -m would count BYTES (the exact trap this tool exists to prevent)"
    content=$(cat "$f")                      # strips trailing newlines (LINT #9 scope; NUL bytes dropped — binary files unsupported)
    [ -n "$content" ] || die "empty file — nothing to measure (a blank draft cannot pass)"
    wcerr=$(printf '%s' "$content" | LC_ALL=$LOC wc -m 2>&1 >/dev/null || true)
    [ -z "$wcerr" ] || die "invalid UTF-8 in $f ($wcerr) — fix encoding before measuring"
    chars=$(printf '%s' "$content" | LC_ALL=$LOC wc -m | tr -d ' ')
    bytes=$(printf '%s' "$content" | wc -c | tr -d ' ')
    echo "$chars chars (method: wc -m, locale=$LOC, trailing-newline stripped — LINT #9 canonical) · $bytes bytes (INFO — not the metric) · /goal limit 4000 chars: $([ "$chars" -le 4000 ] && echo OK || echo OVER)"
    ;;

  *) die "unknown command: $cmd (use append|verify|measure)" ;;
esac
