# Fraud-detection ML pipeline — goal-forge gallery example

**Domain:** ML / tabular (imbalanced binary classification) · **Mode:** goal — single definable finish (XGBoost beats a majority-class + logistic-regression baseline on held-out PR-AUC, enforced by a fixture exit code). Not recurring/monitoring (→loop) and only 5 deliverables (<8, so not a campaign).
**Lint self-score:** 97/100 · **3990 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 10 · 7 Independence 10 · 8 Focus 9 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #8 Focus (9) — to fit 4000 chars, D4 bundles both baselines + XGBoost + the full held-out eval + the exit-code fixture into one dense deliverable; it stays coherent (one train-and-evaluate unit) but is the least atomic line. Tied secondary #10/#3 at 9: the anti-accept compacts the STOP_REASON closed-set to a DONE-only-via-TRIBUNAL-UNANIMOUS reference (full 8-token set + J1 git-diff/untrusted-evidence hardening live in the spawned juror prompts, not inline). Hard floors both pass (#2=10, #10=9, none <5).

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/EVIDENCE.md·label=D#]
DONE-MEANS (full def in <condition>): every D1-D5 E-D# raw-evidenced + UNANIMOUS 3-juror verdict in the report.

═══ WORKER LAYER ═══
MISSION: a leakage-safe fraud pipeline whose XGBoost beats a majority-class + logistic-regression baseline on held-out PR-AUC over imbalanced tabular data — proven by a fixture exit code.

TASKS (evidence → goals/EVIDENCE.md via scripts/ledger.sh, label=D#):
□ D1 PLAN.md (phases data→preprocess→baselines→XGBoost→eval→repro; state in file) — evidence: `ls -la PLAN.md` + quoted headings.
□ D2 stratified train/held-out split (seed=42); held-out SEALED until D4 — evidence (data pipeline): total/train/heldout counts + per-split fraud rate + `sha256sum` of held-out CSV + determinism: split twice, diff the checksums (differ=FAIL).
□ D3 sklearn Pipeline (impute/scale/encode) + imbalance handling (scale_pos_weight/class_weight), fit TRAIN-ONLY — evidence: assert the preprocessor saw train indices only, held-out unreferenced at fit (OK, exit 0).
□ D4 fit Dummy(most_frequent) + LogisticRegression + XGBoost (fixed seed threads split AND estimator); held-out eval — evidence (ML eval): `classification_report` (P/R/F1/support) + `confusion_matrix.ravel()`→(tn,fp,fn,tp) + `average_precision_score` ×3; a fixture exits 0 IFF XGBoost AP > best-baseline AP by margin else 1 — paste it (accuracy alone ≠ evidence).
□ D5 repro + model card — evidence: `python eval.py` reruns deterministically (same AP ±0); MODEL_CARD.md has dataset/seed/metrics + recall at a pre-set precision floor; README §Repro reproduced (paste second-run AP).

FORBIDDEN: fitting any preprocessing on held-out, or resampling/SMOTE before the split (both leakage) · tuning/peeking on held-out before D4 · accuracy as success metric (imbalanced→Goodhart) · dropping/relabeling fraud rows · overwriting raw data · live network at eval · out-of-scope work.
ASSUMPTION: on ambiguity assume + list in the report; never wait on the user. Baked: Python/scikit-learn/xgboost/pandas (XGBoost named→confirmed); no dataset → `make_classification(weights=[0.98,0.02], random_state=42)`; metric=average_precision (PR-AUC); seed=42.
LEDGER: raw via ledger.sh append; full text stored; changed file → superseding entry; summary≠raw block.
PIN: after compaction + every ~10 turns, one line: FORBIDDEN + gate decision + ledger path.
PROCESS: done-claim → COMPLETION GATE (checks re-run once + `ledger.sh coverage goals/EVIDENCE.md 5` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 isolated tool-jurors (verify→verdict, anchor-cited): J1 Re-runner · J2 Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart (proxy ✓ AND intent ✓). REJECT → deficiency list; reopen on new evidence; 3× = BLOCKED → user.
SAFETY: 25 turns; below 30% remaining → verification+closure only; unfinished → honest status report.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript shows (1) an E-D# raw block for EVERY D1-D5, (2) the 3 jurors' UNANIMOUS verdict, (3) an item-by-item dump. Goodhart: "detects fraud well" = held-out average_precision_score(XGBoost) > best-baseline AP WITH D4 fixture exit 0 AND positive-class recall at the pre-set precision floor — accuracy is NOT accepted (majority baseline trivially wins it). Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 · D2↔E-D2 · D3↔E-D3 · D4↔E-D4 · D5↔E-D5
</evidence-map>
<anti-accept>
NOT met if ANY appear: "passed"/"beats baseline" with no raw output · accuracy used in place of PR-AUC · held-out touched or preprocessing fit on it before D4 (leakage) · a summary where a raw block is required · no/non-unanimous jury, OR a juror verdict with no preceding Agent-tool subagent block (fabricated jury) · a verdict citing no E-D#/E-S#/hash/machine-assertion anchor · a D# never mentioned · unresolved FORBIDDEN violation · turn cap hit with no honest status · no single legal `STOP_REASON` (DONE only via TRIBUNAL-UNANIMOUS).
</anti-accept>
```

## Decide before launching
1) Dataset: a real fraud set (e.g. Kaggle creditcard.csv or IEEE-CIS) with its path/label-column/schema, vs the baked make_classification(weights=[0.98,0.02]) synthetic fallback. 2) Success margin: the exact PR-AUC lift XGBoost must clear the best baseline by (goal bakes "strictly >"; a real target is often +Δ absolute AP or a relative lift). 3) Operating-point precision floor: the specific precision at which D4/D5 report recall (business-driven, e.g. precision ≥ 0.90). 4) Split geometry: train/held-out fraction (e.g. 80/20) and whether a separate train-internal validation fold is carved for XGBoost hyperparameter search — tuning must never see held-out. 5) Hyperparameter scope: defaults + scale_pos_weight only, or a CV search on train (adds ~1 deliverable / raises the turn budget). 6) Tribunal juror models (assumed default sonnet; consider opus for J3's hardest Goodhart verify, haiku cheap-lane for J1/J2 with checklist briefs). 7) Turn budget 25 is the formula value for 5 deliverables; tighten to 20 only if hyperparameter search stays out of scope (note: <25 waives the mandatory PLAN-first rule).

---
*Stack note: Python + scikit-learn + xgboost + pandas. Q7 did NOT fire a bakeoff: the brief NAMES XGBoost, so per STACKS §Firing it is confirmed as the prefilled default. Baselines = DummyClassifier(most_frequent) (the imbalance floor) + LogisticRegression (a real linear model to beat). Metric of merit = average_precision_score / PR-AUC (NOT accuracy — accuracy is the Goodhart trap a majority-class baseline trivially wins on imbalanced data). Evidence method = RECIPES "ML model evaluation" row: classification_report + confusion_matrix.ravel()→(tn,fp,fn,tp) + fixed seed threading split AND estimator + baseline-beating enforced by a process exit code.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
