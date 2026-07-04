# E-commerce checkout revamp — goal-forge gallery example

**Domain:** web / e-commerce (Next.js + Stripe) · **Mode:** goal — the finish line is definable and one-shot (working live checkout, a 200/200-green synthetic check suite, orders schema byte-identical), not recurring monitoring (loop) and not 8+ items (campaign); 7 coherent deliverables under one mission.
**Lint self-score:** 97/100 · **3992 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 9 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 10 · 7 Independence 10 · 8 Focus 9 · 9 Budget 10 · 10 Tribunal 10`
**Weakest:** #2 Evidence (scored 9, floor ≥8 met): D2-D7 each carry a hard machine tripwire, but D1 (PLAN.md) rests on a doc-existence check (ls/wc + "headings pasted") whose assertion is soft; acceptable because D1 is a planning artifact and every load-bearing deliverable has a falsifiable exit-code/diff/count. Tie: #3 Constraints and #8 Focus also 9 — #3 names the orders table as a DB object rather than an exact schema-file path (mitigated by D4's migrations-diff exit-0 tripwire), and #8 sits at the 7-item single-goal ceiling (justified as one coherent checkout mission; D7 perf could fold into D6 if a stricter split were wanted).

## Compiled `/goal`

```text
/goal [GF·goal·budget:30·jury:std·ledger:goals/checkout.ledger·label=D#]
DONE-MEANS (summary — full in <condition>): every D# E-D# raw-evidenced + UNANIMOUS 3-juror verdict.

═══ WORKER LAYER ═══
MISSION: revamped Next.js + Stripe checkout, live preview deploy: 200-check suite runs 200/200 green, orders schema byte-identical to baseline.

TASKS (evidence → ledger via scripts/ledger.sh, label=D#):
□ D1 create/update PLAN.md, phase-ordered (skeleton→Stripe→UI→checks→perf/verify) — evidence: `ls -la PLAN.md`+`wc -l`+headings pasted.
□ D2 Revamp checkout UI (cart→address→payment→confirm) — evidence: `curl -w '%{http_code} %{time_total}'` on live /checkout + screenshot assessed IN WRITING vs spec (Payment Element mounted).
□ D3 Stripe PaymentIntent route (TEST mode) — evidence: raw POST + JSON resp (client_secret, status=requires_payment_method); error probe (no amount→400, bad key→401); a test-card confirm →succeeded.
□ D4 Orders schema INVARIANT — evidence: dump schema baseline vs after (`\d orders`/prisma introspect) → `diff` EMPTY (exit 0); `git diff --stat` over migrations shows NO new orders migration.
□ D5 Test suite (checkout unit+integration incl. declined-card) — evidence: full `npm test` stdout, exit code visible.
□ D6 200-check live suite — evidence: `scripts/checks.sh <preview-url>` (happy path, tax/shipping, card-decline, idempotency, order-row==1) → `PASS=200 FAIL=0` exit 0; FAIL>0→exit 1.
□ D7 Perf basics — evidence: cold-load /checkout DOM interactive <2000ms + Stripe.js deferred; cmd + numbers pasted.
FORBIDDEN: any orders-table schema change (columns/types/new migration) · LIVE Stripe keys or real charges — TEST mode only, never commit secrets · nothing outside checkout scope (incl. auth/product-catalog) · `vercel --prod`/prod promotion (user-gated).
ASSUMPTION: on ambiguity assume reasonably + list in report; never wait on the user — EXCEPT a §DAL-C irreversible action (prod promotion): name it, ledger a HELD entry, STOP once.
LEDGER: raw outputs via ledger.sh append (full text); a changed file gets a superseding entry; a summary never replaces the raw block.
PIN: after compaction AND every ~10 turns restate: FORBIDDEN (orders-schema+test-mode-only) + gate decision + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run ALL checks + `ledger.sh coverage <ledger> 7` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool-equipped jurors: J1 Re-runner (own cmds) · J2 Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart dual sign-off. REJECT → deficiency list only; reopen valid; "could be better"≠REJECT; 3 rejects = BLOCKED→user.
SAFETY: 30 turns; below 30% remaining → verification+closure only; unfinished → honest status.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript has (1) an E-D# raw cmd+output block for EVERY D1-D7, (2) the 3 jurors' UNANIMOUS APPROVE, (3) an item-by-item evidence dump. Goodhart: "200 green" holds ONLY when proxy ✓ (PASS=200 FAIL=0, exit 0) AND intent ✓ (≥1 test-mode PaymentIntent →succeeded AND ≥1 declined-card path handled, not 200 `/` pings); "no schema change" holds ONLY when the baseline↔after diff is EMPTY and no orders migration added. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1(PLAN) · D2↔E-D2(curl) · D3↔E-D3(Stripe) · D4↔E-D4(diff∅) · D5↔E-D5(test) · D6↔E-D6(200) · D7↔E-D7(perf)
</evidence-map>
<anti-accept>
NOT met if ANY: "done/passed" with no raw output · a summary in place of a raw block · no jury verdict / non-unanimous / a juror verdict with NO preceding Agent-tool subagent (fabricated jury) or no adjacent E-D#/E-S#/hash/assertion anchor · a D# never mentioned · an unresolved FORBIDDEN violation (orders-schema touched or non-test-mode Stripe) · turn cap exceeded, no honest status · report lacks exactly ONE STOP_REASON ∈ {TRIBUNAL-UNANIMOUS,TURN-CAP-STATUS,BLOCKED-3REJECT,DAL-C-HOLD,OUTAGE-FALLBACK,CRASH-RESUME,NO-PROGRESS,AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Stripe integration surface — assumed embedded Payment Element; confirm vs hosted Checkout Session or Payment Links (changes D2/D3 shape). 2) Live target + credentials — assumed a Vercel preview URL + a Stripe TEST account/keys; provision and supply the preview URL and test keys. 3) The 200-check suite contents — D6 scaffolds categories (happy path, tax/shipping, card-decline, idempotency, order-row==1); confirm the exact endpoints/scenarios and that scripts/checks.sh enumerates 200 named checks (not 200 repeats of one). 4) Orders persistence layer — assumed Prisma/Postgres; if a different ORM/DB, adjust D4's schema-dump command. 5) Supported payment methods — assumed cards only; confirm if wallets/APMs (Apple/Google Pay) are in scope. 6) Production promotion is a §DAL-C terminal HOLD — after sign-off the USER runs `vercel --prod`; the goal finishes on the live preview, never self-promotes to prod.

---
*Stack note: Stack NAMED in brief (Next.js + Stripe) → STACKS §Firing SKIP case: confirmed as prefilled default, no Q7 bakeoff. Assumed within that: embedded Stripe Payment Element (vs hosted Checkout Session / Payment Links), Prisma+Postgres orders persistence (drives the `\d orders`/prisma-introspect dump in D4 — swap the dump command for a different ORM/DB), and a Vercel preview deployment as the "live" target with Stripe TEST-mode keys.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
