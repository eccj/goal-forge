# Reproduce a research paper result — goal-forge gallery example

**Domain:** ML reproduction · **Mode:** goal — a single, definable finish line (reproduce one reported metric within a fixed tolerance from a pinned, seed-threaded env); not recurring, so not a loop, and 5 deliverables (<8) so not a campaign.
**Lint self-score:** 97/100 · **3992 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn-cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #6 Goodhart (9): the "reproduced" inequality (|acc−0.960|≤0.010, beats-baseline, seed-threaded) is fully mechanical but lives inline in D4/D3 rather than restated in <condition> (kept out to fit 4000 chars; the anti-accept still guards TOL-fitted-after and seed-gaming). Its correctness also rests on the user confirming the target 0.960 and ±0.010 are the paper's real values — hence they head the decide-before-launch list.

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/EVIDENCE-repro.md·label=D#]
DONE-MEANS (full definition in <condition>): every D# item E-D# raw-evidenced + UNANIMOUS 3-juror verdict in the final report.

═══ WORKER LAYER ═══
MISSION: Reproduce <PAPER>'s headline held-out metric (Table 1 test accuracy 0.960) to within ±0.010 from a pinned, seed-threaded env.

TASKS (evidence → goals/EVIDENCE-repro.md via ledger.sh, label=D#):
□ D1 Create/update PLAN.md (phases pin→seed→eval→report) — ev: `ls -la PLAN.md`+`wc -l`+quoted headings.
□ D2 Pin inputs. Env: requirements.txt `==`+hashes, install to a clean venv. Data: fetch the paper's split — ev: `python --version`, `pip install --require-hashes` exit 0, `pip freeze`, `sha256sum requirements.txt`; `wc -l` row count + `sha256sum` of the split == a PRE-REGISTERED hash (pre-download); mismatch=STOP.
□ D3 Thread ONE seed (SEED=42) through split+estimator+shuffle — ev: a fixture prints m1(SEED), m2(SEED), m3(SEED+1); exit 0 ONLY if m1==m2 (|Δ|<1e-9, determinism) AND m3≠m1 (seed threads); an ignored seed exits 1.
□ D4 Held-out reproduction eval — ev: printed `classification_report` (per-class P/R/F1/support) + `confusion_matrix.ravel()`→(tn,fp,fn,tp) + a `DummyClassifier(most_frequent)` baseline; ONE fixture exits 0 ONLY if acc>baseline AND |acc−0.960|≤0.010 (TOL fixed BEFORE the run); a lone scalar or baseline-less exit is insufficient.
□ D5 Write REPRODUCE.md (reported-vs-reproduced table, pins, SEED, per-metric Δ, discrepancies surfaced) — ev: file list + quoted headings + reader-task check: re-run D4's fixture from a clean venv per §Repro, paste exit 0.
FORBIDDEN: tuning/peeking on the held-out test split · fitting TOL after seeing the result · changing SEED to force a match · unpinned/"latest" deps · live network at eval (data cached once, offline re-read) · editing the paper's numbers · nothing outside scope.
ASSUMPTION: make reasonable assumptions, list them in the report, never wait on the user — EXCEPT a §RED-HOLD irreversible action (name it, ledger a HELD entry, STOP once).
LEDGER: raw outputs via `ledger.sh append`, full text stored; changed env/re-run = SUPERSEDING entry; a summary never replaces the raw block.
PIN: after compaction + every ~10 turns, restate active FORBIDDEN + gate + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run all fixtures + `ledger.sh coverage <ledger> 5` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool-equipped jurors: J1 re-runs checks by OWN commands · J2 recomputes the hash chain from GENESIS (D#↔E-D#) · J3 guards FORBIDDEN + Goodhart dual sign-off (proxy ✓ AND intent ✓). REJECT → deficiency list only; reopening valid; 3 rejects = BLOCKED → user.
SAFETY: 25 turns; below ~7 remaining, verification+closure only; if unfinished, honest status report.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript shows (1) an E-D#-labeled raw command+output block for EVERY D1-D5, (2) the 3 jurors' UNANIMOUS verdict, and (3) an item-by-item evidence dump. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 · D2↔E-D2 (pins+data) · D3↔E-D3 (seed-thread exit) · D4↔E-D4 (report+matrix+baseline+tol) · D5↔E-D5 (clean-venv re-run)
</evidence-map>
<anti-accept>
NOT met if ANY appear: a "reproduced/passed" claim or required raw block replaced by a summary · a lone accuracy scalar where classification_report+confusion_matrix+baseline are required · TOL widened/chosen AFTER the result · SEED changed to force a match, or a seed that doesn't move the numbers · deps unpinned or eval on live network · no/non-unanimous jury verdict, a juror verdict with no preceding Agent-tool subagent block (prose = fabricated jury), or one lacking an adjacent E-D#/hash/machine anchor · an unresolved FORBIDDEN violation · not exactly ONE `STOP_REASON: <T>`, T ∈ {TRIBUNAL-UNANIMOUS,TURN-CAP-STATUS,BLOCKED-3REJECT,RED-HOLD,OUTAGE-FALLBACK,CRASH-RESUME,NO-PROGRESS,AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) The actual <PAPER> + which number is 'headline' (I assumed Table 1 test accuracy = 0.960) and the metric type (accuracy vs macro-F1 vs AUC vs RMSE). 2) Tolerance TOL (assumed ±0.010 absolute; some reproductions use ±1σ or relative %). 3) Dataset/split identity AND the PRE-REGISTERED expected sha256 — must be fixed from the paper's canonical data source BEFORE download (D2 machine tripwire depends on it). 4) Seed value (assumed 42; use the paper's stated seed if given). 5) GPU nondeterminism: if the model is CUDA-nondeterministic, decide whether to force torch deterministic algorithms/CPU-only or widen TOL — either way record the choice in D2's env pins. 6) Task family: confirm classification vs regression/ranking so D4's fixture matches. 7) Tribunal strictness: I set standard; a high-stakes public reproduction claim may warrant jury:heavy (+prosecutor, +5 turns → budget 30).

---
*Stack note: Q7 SKIP (paper NAMES its stack → confirm-not-ask, no bakeoff). Assumed: Python + the paper's own framework, modeled as a scikit-learn-style CLASSIFICATION reproduction (classification_report / confusion_matrix.ravel() / DummyClassifier per RECIPES 'ML model evaluation'). If the paper uses PyTorch/TF, swap D4's fixture and add framework seed + deterministic-algorithm flags in D3; if the metric is regression/ranking (RMSE/MAE/NDCG), replace the classification-report block with the matching held-out metric + a trivial baseline the fixture must beat.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
