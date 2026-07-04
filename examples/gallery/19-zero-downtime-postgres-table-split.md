# Zero-downtime Postgres table split — goal-forge gallery example

**Domain:** database migration (expand-contract / online schema change) · **Mode:** goal — one definable done-state (the split rehearsed and PROVEN end-to-end on a live Postgres); nothing recurring rules out /loop, and 5 deliverables sit well under the 8+ campaign threshold. Single-topic goal.
**Lint self-score:** 96/100 · **3977 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 9 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #6 Goodhart (9) — the "zero-downtime" proxy inequalities (max lock <200ms, mismatch==0, empty read-diff) are strong, but the INTENT side (no row lost to a backfill↔dual-write race, no failed query mid-cutover) rests on D3's ASSESSED sample rows + J3's proxy✓/intent✓ sign-off rather than a dedicated adversarial concurrency probe, and it runs a STANDARD (not heavy) jury on a data-loss-capable migration. Tied at 9: #8 Focus — D2 merges the additive-schema and dual-write concerns into one deliverable (a char-budget compromise; still one coherent "expand" phase). Both are honestly mitigable by upgrading to jury:heavy (see decide-list).

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/pgsplit.ledger·label=D#]
DONE-MEANS (full def below): every D# item E-D#-raw-evidenced + UNANIMOUS 3-juror verdict.

═══ WORKER LAYER ═══
MISSION: PROVE a zero-downtime expand-contract split of table T into T+T_ext (1:1 on PK): additive dual-write, batched backfill+parity, flag-gated read cut-over under a sub-200ms lock window, and a HELD prod contract-drop.

TASKS (evidence → the ledger via scripts/ledger.sh, label=D#):
□ D1 PLAN.md, phase-ordered (expand→backfill+parity→cut-over→contract), each closes E-D# before the next — evidence: `ls -la PLAN.md`+`wc -l`+quoted headings.
□ D2 Expand+dual-write: additive migration→T_ext+FK (NOT VALID→VALIDATE; no T rewrite), writes mirrored to T_ext in ONE txn — evidence: `information_schema.columns` state + `lock_timeout='200ms'` commit + a test (exit visible): writes keep T↔T_ext consistent, a failed T_ext write ABORTS T; nonzero exit OR missing row→FAIL.
□ D3 Backfill+parity: batched throttled copy T→T_ext, reconciled post-catch-up — evidence [data-pipeline]: src==dst count + `sha256sum`(sorted sample) + run TWICE→identical checksums + FULL OUTER JOIN=0 mismatches + 10 rows ASSESSED vs mapping; any {src≠dst, rerun differs, mismatch≠0}→exit 1.
□ D4 Cut-over+rollback+lock: reads flip to T_ext via a flag, flip-back rehearsed — evidence: old-vs-new reads EMPTY `diff` + queried-back flag + rollback verified + MEASURED max ACCESS EXCLUSIVE hold on T over all steps (`pg_locks`/timed); nonempty diff OR max hold ≥200ms→FAIL.
□ D5 Contract (§DAL-C HOLD): the prod DROP of T's moved columns/old table is irreversible, NOT self-authorized — evidence: an E-D5 HELD entry naming the exact `DROP TABLE`/`ALTER TABLE T DROP COLUMN…` AND the user command to run after the dual-write soak; STOP once.

FORBIDDEN: rewrite/DROP any T column this run · any long-lock DDL on T (ADD COLUMN NOT NULL DEFAULT on legacy PG, full-table rewrite, un-throttled backfill) · re-run evidence to "verify" · touch prod · nothing beyond D1-D5.
ASSUMPTION: on ambiguity assume + list it; never wait — except the §DAL-C D5 HOLD. Stack: Docker Postgres 16 + raw SQL via psql; migration tool + trigger-vs-app dual-write: decide-before-launch swaps.
LEDGER: raw cmd+stdout via ledger.sh append; full text stored; changed file→superseding entry; summaries never replace a raw block.
PIN: every ~10 turns + post-compaction: restate FORBIDDEN + gate + ledger path.
PROCESS: done-claim → COMPLETION GATE (re-run checks + `ledger.sh coverage goals/pgsplit.ledger 5` + `ledger.sh verify`; any fail→no jury) → PROSECUTOR self-audit (parity/race/lock/DROP gaps) → 3 isolated jurors: J1 Re-runner · J2 Ledger-Auditor(chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart(proxy✓ AND intent✓). REJECT→deficiency list; reopening valid; 3 rejects/item=BLOCKED→user.
SAFETY: 25 turns; below 30% left: verification+closure only; else honest status.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript shows (1) an E-D#-labeled raw command+output block for EVERY D1-D5 item, dumped item-by-item, AND (2) the 3 jurors' UNANIMOUS verdict; E-D4 shows max lock-hold <200ms and E-D3 mismatch==0 ("zero-downtime"). D5 meets (1) via its E-D5 HELD entry naming the gated DROP AND the user command (no exec output); a bare "HELD" → NOT DONE. Anything missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 · D2↔E-D2 · D3↔E-D3 · D4↔E-D4 · D5↔E-D5(HELD)
</evidence-map>
<anti-accept>
NOT met if ANY appear: a done-claim with no raw block · no/non-unanimous jury, or a juror verdict with no preceding subagent block or no cited E-D#/hash/assertion · a D# never mentioned · a DROP/rewrite of T executed instead of HELD · an unresolved FORBIDDEN violation · turn cap exceeded, no status · the report lacks exactly ONE `STOP_REASON: <T>` ∈ {TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, DAL-C-HOLD, OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Migration TOOLING — assumed raw SQL applied via psql; real options are Flyway / Liquibase / sqitch / alembic (governs versioning, rollback, and the coverage of the "idempotent re-apply" check). 2) DUAL-WRITE mechanism — assumed app-layer in one service; alternative is a DB trigger (transactional by default, DB-coupled) vs app-level (explicit, must guard EVERY write path). 3) The concrete table T, the split boundary (which columns move to T_ext), and the 1:1 join key. 4) Postgres VERSION — assumed 16; matters because "ADD COLUMN NOT NULL DEFAULT" is safe on PG11+ (the "legacy PG" FORBIDDEN gotcha targets ≤10) and lock semantics differ. 5) TRIBUNAL strictness — compiled at STANDARD; for a real production cutover, upgrade to jury:heavy (adds an independent prosecutor to hunt the backfill↔dual-write race and concurrent-write-during-cutover; budget then recomputes to 30). 6) THRESHOLDS — the 200ms max-lock window and the N-day dual-write soak before the contract-drop. 7) ENVIRONMENT — assumed a disposable Dockerized Postgres seeded to mirror prod SHAPE and VOLUME; confirm the seed is large enough that the backfill throttle/timing and the lock measurement are meaningful.

---
*Stack note: Off-map domain (database migration is not in the STACKS.md seed table); the core tech is essentially named (Postgres), so Q7 did not fire a full stack-bakeoff. Assumed stack: Dockerized Postgres 16 + raw SQL migrations via psql + app-level dual-write. The genuine tooling choices (raw SQL vs Flyway/Liquibase/sqitch/alembic; trigger vs app dual-write) were folded into ASSUMPTION + the decide-list rather than a bakeoff deliverable, to preserve 5-item single-topic focus. Evidence method composed from the RECIPES "Data pipeline" row (counts + checksum + rerun-determinism + assessed sample rows for backfill/parity) plus "Config/infra" (schema queried BACK from information_schema, not the migration file) for the expand step.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
