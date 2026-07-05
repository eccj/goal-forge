# Fast fuzzy file-finder CLI — goal-forge gallery example

**Domain:** CLI / Rust · **Mode:** goal — one definable finished state (ship `ff` with test/clippy/coverage/audit gates green + p95<100ms on 1M files); not recurring (so not loop) and only 7 deliverables (so not campaign)
**Lint self-score:** 96/100 · **3983 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 9 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #6 Goodhart (9) — the "fast"→p95<100ms end-to-end inequality is fully specified in D4 (+ guarded in FORBIDDEN and anti-accept), but its restatement was dropped from <condition> as derivable-from-D4 to hold the char budget; template-legal ("only when not derivable from D-items"), yet a strict reviewer may want the one headline metric echoed in the completion condition. Both hard floors (#2, #10) clear ≥8; no criterion <5.

## Compiled `/goal`

```text
/goal [GF·goal·budget:30·jury:std·ledger:EVIDENCE.md·label=D#]
DONE-MEANS (full def below): every D# item E-D# raw-evidenced + UNANIMOUS jury
verdict in the report.

══ WORKER ══
MISSION: Ship `ff`, a Rust fuzzy file-finder CLI ranking a 1,000,000-path corpus
at p95<100ms end-to-end; test/clippy/cov/audit gates green.

TASKS (evidence → EVIDENCE.md via ledger.sh, label=D#):
□ D1 PLAN.md phase-ordered (skeleton→core matcher+walker→gates→1M bench);
  coverage-floor % PRE-REGISTERED here — evidence: `ls -la PLAN.md`+headings.
□ D2 fuzzy lib: subsequence scorer w/ deterministic rank + parallel walker —
  evidence: `cargo test -p <lib>` full stdout+exit 0; a ranking test pins a known
  query's order (mutate scorer→fails).
□ D3 CLI `ff` (clap; dir arg OR stdin; prints ranked paths) — evidence: `cargo
  build --release` + `ls -la target/release/ff` + `shasum -a 256`; run on a
  fixture tree, paste ranked stdout + a no-match probe.
□ D4 perf: p95<100ms on 1,000,000 DISTINCT paths — evidence: ledger the corpus-
  gen cmd (1e6 unique real strings), then `hyperfine -N -w3 -r15 './target/
  release/ff Q < corpus.txt'`; paste p50/p95 ms. Tripwire: p95<100ms spawn→exit
  else FAIL; corpus+CPU named.
□ D5 test+coverage — evidence: `cargo test` (or `cargo nextest run`) FULL stdout
  + exit 0, no required `#[ignore]` + `cargo llvm-cov --summary-only` ≥ the D1
  floor; cover artifact `shasum`d.
□ D6 lint — evidence: `cargo clippy --all-targets --all-features -- -D warnings`
  full stdout + exit 0 (any warning→FAIL).
□ D7 audit — evidence: `cargo audit` (or `osv-scanner --offline` on Cargo.lock)
  OFFLINE vs a pinned advisory-DB snapshot (id+date ledgered); exit 0 = no vulns.
FORBIDDEN: `unsafe` w/o a ledgered rationale · faking the 1M corpus (repeated/
symlinked/padded) · narrowing `--package`, `#[ignore]`-ing a required test, or
fitting the coverage floor post-run · timing warm-cache/tiny-tree/matcher-only ·
network during audit · out-of-scope features.
ASSUMPTION: on ambiguity assume + list it in the report; never wait on the user —
EXCEPT a §RED-HOLD irreversible action (crates.io publish, repo delete): name it,
ledger a HELD entry, STOP once.
LEDGER: raw outputs via `ledger.sh append`; full text stored; a changed file gets
a superseding entry; a summary never replaces the raw block.
PIN: first msg post-compaction + every ~10 turns, restate: active FORBIDDEN +
governing gate decision + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run ALL checks once + `ledger.sh
coverage EVIDENCE.md 7` + `ledger.sh verify`; any failure = no jury) → PROSECUTOR
self-audit → 3 jurors (tools on): J1 Re-runner · J2 Ledger-Auditor (chain from
GENESIS; D#↔E-D#) · J3 Constraint+Goodhart dual sign-off (proxy ✓ AND intent ✓).
REJECT → deficiency list only; reopen valid; 3 rejects/item = BLOCKED → user.
SAFETY: 30 turns; below 30% remaining → verification+closure only; if unfinished,
honest status report.

══ EVALUATOR ══
<condition>
DONE iff the transcript shows (1) an E-D#-labeled raw command+output block for
EVERY D1-D7 item AND (2) the 3 jurors' UNANIMOUS verdict AND (3) an item-by-item
evidence dump. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (PLAN) · D2↔E-D2 (matcher) · D3↔E-D3 (binary) · D4↔E-D4 (p95) · D5↔E-D5
(test+cov) · D6↔E-D6 (clippy) · D7↔E-D7 (audit)
</evidence-map>
<anti-accept>
NOT met if ANY appear: "passes/fast" with no raw block (or a summary where one is
required) · no jury verdict, non-unanimous, OR a juror verdict with NO preceding
Agent-tool subagent block (prose-only seal = fabricated jury) · a verdict with no
adjacent E-D#/E-S#, hash, or machine-assertion anchor · a D# never mentioned · an
unresolved FORBIDDEN violation · turn cap exceeded with no honest status · the
report lacks exactly ONE `STOP_REASON:
<T>`, T ∈ {TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, RED-HOLD,
OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON
≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Ranking engine: hand-rolled subsequence scorer vs a crate (nucleo / fzf-algo / fuzzy-matcher) — drives perf headroom AND the `unsafe` policy. 2) Coverage floor % (D1 pre-registers it; suggest 75). 3) Named host/CPU for the <100ms claim — the number is hardware-bound and only meaningful on one declared machine (e.g. M-series laptop vs a CI runner); pick the reference box. 4) Scope of matching: pure path-string matching vs fd-like .gitignore/hidden-file filtering; Unix-only vs also Windows. 5) Binary/crate name (`ff` assumed — may collide with fzf/fd/existing tools). 6) `cargo audit` needs a pinned advisory-DB snapshot fetched ONCE before the offline run — confirm one is available. 7) Budget stays 30 (coefficient 2.5 per recalibration, median run ≈56%); tighten to 25 only if you accept less tribunal reserve.

---
*Stack note: Rust — named in the brief (cargo/clippy/llvm-cov/audit), so per STACKS §Firing it is CONFIRMED as the prefilled default, not sent to a bakeoff. Sub-choice (hand-rolled scorer vs nucleo/fzf-algo crate) is left to decide_before_launch since it trades perf headroom against the unsafe policy.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
