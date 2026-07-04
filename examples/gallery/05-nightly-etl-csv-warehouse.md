# Nightly ETL: CSV → warehouse — goal-forge gallery example

**Domain:** data pipeline (ETL) · **Mode:** goal — building the pipeline has one definable finished state; the nightly recurrence is the artifact's runtime behavior, not a monitoring loop, and 5 items is far under the campaign threshold
**Lint self-score:** 96/100 · **3995 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 9 · 10 Tribunal 9 = 96/100`
**Weakest:** #6 Goodhart — the anti-gaming spine is strong (2×run idempotence, EMPTY-diff determinism, source↔warehouse checksum parity, FORBIDDEN row-padding), but the "5 sample rows show the CORRECT transform" check keeps one human-judged element; mitigated by anchoring it to explicit expected-transform rules (type coercion, key-dedup, null policy) so a no-op/same-count-but-corrupted load is caught, not waved through. Runner-up: #9 (3995 chars sits at the top edge of the 3000-4000 band with little margin).

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/etl.ledger·label=D#]
DONE-MEANS (full def below): every D# item E-D# raw-evidenced + UNANIMOUS 3-juror verdict in the final report.

═══ WORKER LAYER ═══
MISSION: Ship a nightly CSV→warehouse ETL — idempotent load, source↔warehouse row-count+checksum parity, deterministic reruns. Stack: Python3+DuckDB+SQL MERGE+cron; a managed warehouse/orchestrator is a decide-before-launch swap.

TASKS (evidence → goals/etl.ledger via scripts/ledger.sh, label=D#):
□ D1 PLAN.md, phase-ordered (schema→load→parity+determinism→schedule) — evidence: `ls -la PLAN.md`+`wc -l`+quoted phase headings; before D2.
□ D2 Extract→validated staging (schema check, bad rows→quarantine) — evidence: `wc -l input.csv`(−header) vs `SELECT count(*) FROM staging`; a K-bad-row fixture asserts quarantine==K AND staging==total−K; mismatch→exit 1.
□ D3 Idempotent transactional MERGE (natural-key upsert, atomic txn) — evidence: load run TWICE (identical input); paste target `count(*)`+`sha256sum` after run1 AND run2 (identical); raise mid-MERGE → count==pre-load (rollback, no partial commit), exit 0.
□ D4 Parity + rerun-determinism — evidence: source count==warehouse count AND `sha256sum`(sorted projection) match; run pipeline TWICE → both sample `sha256sum` identical + EMPTY `diff` (else FAIL); + 5 sample rows ASSESSED vs expected transform (coercion, dedup, nulls); mismatch→exit 1.
□ D5 Nightly schedule + operator runbook — evidence: applied state via `crontab -l` (nightly entry, NOT the config file) + runbook file list + quoted §headings (Run/Backfill/Recover); reader-task: follow §Backfill → SAME parity checksum (pasted).

FORBIDDEN: no live/prod creds or network in tests (offline vs local DuckDB) · never mutate source CSVs · no wall-clock/random/unordered-SELECT in transform/samples (always ORDER BY) · no DROP/TRUNCATE of a real warehouse · never pad/drop rows to hit parity · nothing beyond D1-D5.
ASSUMPTION: on ambiguity assume + list in the report; never wait on the user — except a §DAL-C irreversible action (name it, ledger a HELD entry, STOP once).
LEDGER: raw command+stdout via ledger.sh append; full text stored; a changed file→superseding entry; a summary never replaces a raw block.
PIN: every ~10 turns restate FORBIDDEN + gate decision + ledger path.
PROCESS: done-claim → COMPLETION GATE (re-run all checks + `ledger.sh coverage goals/etl.ledger 5` + `ledger.sh verify`; any fail→no jury) → PROSECUTOR self-audit → 3 isolated jurors: J1 Re-runner(own cmds) · J2 Ledger-Auditor(recompute chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart(proxy✓ AND intent✓). REJECT→deficiency list; reopening valid; 3 rejects/item=BLOCKED→user.
SAFETY: 25 turns; below 30% remaining only verification+closure; else honest status report.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript shows (1) an E-D#-labeled raw command+output block for EVERY D1-D5 item, (2) the 3 jurors' UNANIMOUS verdict, (3) an item-by-item evidence dump. GOODHART: counts/checksums/reruns passing (proxy) ≠ intent — the assessed sample rows must prove the CORRECT transform and idempotence hold on rerun. Anything missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 · D2↔E-D2(counts+quarantine) · D3↔E-D3(idempotence+rollback) · D4↔E-D4(parity+determinism) · D5↔E-D5(crontab+runbook)
</evidence-map>
<anti-accept>
NOT met if ANY appear: a done-claim with no raw block · a summary where a raw block is required · no/non-unanimous jury verdict, or a juror verdict with no preceding Agent-tool subagent block (prose-only = fabricated jury) · a juror verdict citing no adjacent E-D#/E-S#, hash, or machine-assertion · a D# never mentioned · an unresolved FORBIDDEN violation · turn cap exceeded with no honest status · the final report lacks exactly ONE `STOP_REASON: <T>`, T ∈ {TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, DAL-C-HOLD, OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Real warehouse target (Snowflake/BigQuery/Postgres/Redshift) vs the assumed local DuckDB — changes MERGE dialect + creds/connection handling. 2) Orchestrator: plain cron (assumed) vs Airflow/Dagster/managed scheduler. 3) Natural/business key for the upsert (which columns define row identity) + the changed/late-arriving-row policy (overwrite vs SCD-2 history). 4) Source contract: landing dir, filename pattern, schema/encoding/delimiter, and where quarantined bad rows + alerts go. 5) Parity policy: strict equality vs allowed deltas, and exactly which columns feed the canonical checksum projection. 6) Backfill window + retention; whether historical reloads are in scope. 7) Tribunal juror models (Q6): defaulted mechanical J1/J2 + semantic J3 to sonnet — confirm, or raise J3 to opus for the hardest verify.

---
*Stack note: Assumed Python3 + local DuckDB warehouse + SQL MERGE + cron — self-contained and offline-reproducible so juror J1 can independently re-run every count/checksum/determinism check without cloud creds (aligns with goal-forge's zero-external-dependency ethos and makes the RECIPES 'Data pipeline' recipe fully verifiable). This is a headless compile: per STACKS §Firing it is a capability-greenfield Q7 that would normally compile a stack-bakeoff; instead recorded as an ASSUMPTION with a one-line trade-off, and the managed-warehouse/orchestrator swap is surfaced in decide_before_launch (never silently dropped).*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
