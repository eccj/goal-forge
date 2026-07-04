# Solidity escrow smart-contract — goal-forge gallery example

**Domain:** blockchain · **Mode:** goal — one definable finish line (an audited, reentrancy-safe escrow with a passing Foundry suite); 6 deliverables (< the 8-item campaign threshold); not recurring, so not a loop.
**Lint self-score:** 96/100 · **3991 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 9 · 10 Tribunal 9`
**Weakest:** #9 Char budget — 3991/4000 sits at the top of the ideal band with little headroom; if a real user needs to add a task the goal must first shed prose. (Runner-up risk: #5 — the formula's 25-turn cap is honest but tight for writing a full contract + unit/fuzz + invariants + gas + Slither in one run; flagged in decide-list to consider bumping to 30.)

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/escrow-EVIDENCE.md·label=D#]
DONE-MEANS (full def in <condition>): every D1-D6 E-D#-evidenced + a UNANIMOUS 3-juror verdict.

═══ WORKER ═══
MISSION: Ship a reentrancy-safe Solidity escrow — passing Foundry unit+fuzz+invariant suite, committed gas snapshot, clean Slither scan.

TASKS (evidence → ledger.sh append, label=D#):
□ D1 PLAN.md phase-ordered (skeleton→core→tests→hardening) — ev: `ls -la PLAN.md`+`wc -l`+headings.
□ D2 Escrow.sol (deposit→release|refund, terminal states, CEI order) — ev: `forge build --sizes` exit 0 + runtime-size line; pragma + OZ version pinned in foundry.toml.
□ D3 ReentrancyGuard + a ReentrancyAttacker re-entering release/refund — ev: `forge test --match-contract Reentrancy -vvv` exit 0; trace: re-entrant call REVERTS + victim Δbal==0.
□ D4 Unit+fuzz + coverage — reverts (double-release, unauthorized, refund-after-release) + happy — ev: full `forge test -vvv` (exit code, not tail) + fuzz-runs, then `forge coverage` total ≥ floor.
□ D5 Invariants (bal==Σ open amounts; terminal states immutable; deposited==released+refunded+held) — ev: `forge test --match-path test/invariant/*` + `[invariant]` runs/depth; a counterexample→exit 1.
□ D6 Gas snapshot + Slither — ev: `forge snapshot` writes committed `.gas-snapshot`, `forge snapshot --check` exit 0 vs baseline; `slither . --json slither.json` OFFLINE (solc pinned; detectors ledgered) exit + 0 unresolved high.
FORBIDDEN: NO on-chain deploy (irreversible → §DAL-C HELD naming the `forge script --broadcast` cmd for the user) · never loosen/remove the guard, `--match`-narrow, or lower gas/coverage baselines · no external API/oracle · no editing OZ source · no committed keys/.env · no `.transfer`/2300-gas.
ASSUMPTION: on ambiguity pick a default (2-party ETH escrow, ^0.8.24, OZ ReentrancyGuard, 90% coverage, 0% gas tolerance) and list it; never wait — EXCEPT §DAL-C deploy: name it, ledger HELD, STOP once.
LEDGER: raw outputs via ledger.sh append, full text stored; a changed file gets a superseding entry; a summary never replaces the raw block.
PIN: first msg post-compaction + every ~10 turns, restate one line: FORBIDDEN + no-deploy gate + ledger path.
PROCESS: done-claim → COMPLETION GATE (re-run forge build+test+coverage+snapshot --check+slither once + `ledger.sh coverage <ledger> 6` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool-equipped jurors (disjoint context): J1 re-runs by its OWN cmds + git diff-stat over test/config paths · J2 recomputes the chain from GENESIS (D#↔E-D#) · J3 Constraint+Goodhart (proxy ✓ AND intent ✓ no drain). 3× REJECT=BLOCKED→user; else deficiency list, reopen valid.
SAFETY: 25 turns; below 30% remaining (≤7) verification+closure only; else honest status report.

═══ EVALUATOR ═══
<condition>
DONE iff the transcript shows (1) an E-D# raw command+output block for EVERY D1-D6 AND (2) the 3 jurors' UNANIMOUS verdict AND (3) a per-item evidence dump. Quality wishes = the D-line inequalities: reentrancy-safe→D3 Δbal==0, gas-efficient→D6 `--check` exit 0, well-tested→D5 0-counterexample + D4 coverage≥floor. A §DAL-C deploy HOLD meets (1) via an E-D# HELD entry naming the broadcast+user cmd; (2)/(3) apply. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 · D2↔E-D2 · D3↔E-D3 (attacker) · D4↔E-D4 (test+cov) · D5↔E-D5 (invariant) · D6↔E-D6 (gas+slither)
</evidence-map>
<anti-accept>
NOT met if ANY: a done/pass claim or summary with no raw forge block · a missing/non-unanimous jury verdict, OR a juror verdict with no preceding Agent-tool subagent block (fabricated jury) · a verdict with no adjacent E-D#/E-S#/hash/machine-assertion anchor · an unresolved FORBIDDEN violation (deploy/narrowed-suite/lowered-baseline) · the report lacks exactly ONE `STOP_REASON: <T>`, T ∈ {TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, DAL-C-HOLD, OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Party model: assumed 2-party buyer/seller; decide if a 3rd-party arbiter + dispute resolution (and arbiter fee) is needed, plus who may trigger release vs refund and any timeout/refund window. 2) Asset: assumed native ETH; decide ERC-20 or multi-token support (changes pull-payment + reentrancy surface). 3) Compiler/lib pins: assumed pragma ^0.8.24 + OZ ReentrancyGuard; confirm exact versions and OZ-vs-custom guard. 4) Thresholds: assumed 90% coverage floor and 0% gas-regression tolerance — 0% is strict and may cause snapshot churn; pick a tolerance and set the [invariant] runs×depth floor in foundry.toml. 5) Turn budget: formula gives 25; given the implementation depth consider raising to 30. 6) Deploy is intentionally excluded as a §DAL-C terminal HOLD — the agent stops and hands you the exact `forge script --broadcast` command to run yourself.

---
*Stack note: Foundry (forge/cast/anvil) + Solidity ^0.8.24 (built-in overflow checks) + OpenZeppelin ReentrancyGuard, with Slither for SAST and solc-select to pin the compiler offline. Named in the brief ("Foundry tests"), so per STACKS §Firing this is confirm-not-ask — no stack-bakeoff deliverable. RECIPES has no Solidity row; evidence method composed from the Rust/Go/Test-suite/Security-scan rows: raw `forge` stdout+exit codes, a pre-registered coverage/gas floor as the machine tripwire, offline pinned-DB static analysis, and a from-GENESIS hash chain.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
