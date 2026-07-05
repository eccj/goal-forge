# Real-time collaborative whiteboard — goal-forge gallery example

**Domain:** web / realtime · **Mode:** goal — one definable finish line (a deployed, multi-client-verifiable whiteboard); not recurring so not a loop, and 6 deliverables (<8) so not a campaign
**Lint self-score:** 96/100 · **3972 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 9 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #6 Goodhart (9) — "real-time" and "no data loss" are converted to hard inequalities (p95<200ms; sha256(docA)==sha256(docB) + stroke_count==expected), but the specific 200ms latency target, the 5-concurrent-client count, and the bytes/stroke floor are my reasonable-assumption defaults; a real user should confirm the target latency/concurrency (listed in decide_before_launch). Both hard floors pass: #2 Evidence=10, #10 Tribunal=9; no criterion <5.

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:standard·ledger:goals/EVIDENCE.md·label=D#]
DONE-MEANS (def in <condition>): every D# item E-D# raw-evidenced + UNANIMOUS 3-juror verdict.

═══ WORKER ═══
MISSION: a deployed real-time whiteboard: 2+ live clients see each other's canvas strokes and presence cursors; offline edits merge on reconnect with zero stroke loss.

TASKS (evidence → ledger via scripts/ledger.sh, label=D#):
□ D1 PLAN.md — phased roadmap (skeleton→core→polish→live-verify), state in file — evidence: `ls -la PLAN.md` + quoted headings.
□ D2 stack+CRDT bakeoff (research decides): Yjs+y-websocket vs Automerge vs custom-OT on fit/merge/bundle/ecosystem — evidence: criteria table + ≥4 live source URLs + findings; winner + why-not per loser.
□ D3 canvas+WS realtime — strokes and presence cursors (id+color) propagate across clients — evidence: boot log + headless 2-client test: B.stroke==A.stroke, cursor propagation, post-disconnect removal; exit=1 on mismatch.
□ D4 offline-merge convergence (CRDT): clients edit offline, reconnect → byte-identical doc, no stroke dropped — evidence: sha256(docA_final)==sha256(docB_final) AND stroke_count==expected AND run-twice-deterministic (diff checksums); exit=1 on divergence/loss.
□ D5 perf + security — evidence: p95 propagation ms + bytes/stroke at 5 clients (cmd shown; PRE-REGISTERED floors); `gitleaks detect -f json` (exit 0) + `osv-scanner scan source -r --offline --local-db=<pinned>` (snapshot id+date ledgered); scanned files diffed vs `git ls-files`, gaps OPEN.
□ D6 live deploy + docs — evidence: `curl -s -o /dev/null -w "%{http_code} %{size_download} %{time_total}"` on the live URL + a screenshot of two browsers drawing together, assessed; README §Run reproduced from a clean checkout.
FORBIDDEN: silent stroke loss on merge · paid keyed realtime SaaS (stay self-hostable) · breaking offline mode · auth scope creep · work beyond the 6.
ASSUMPTION: on ambiguity assume + list it; never wait — EXCEPT a §RED-HOLD irreversible action (prod domain/DB delete, publish): name it, ledger HELD, STOP once.
LEDGER: raw outputs via ledger.sh append; full text stored; a changed file → superseding entry; a summary never replaces the raw block.
PIN: after compaction AND every ~10 turns, restate: FORBIDDEN list + governing gate + ledger path.
PROCESS: done-claim → COMPLETION GATE (re-run all checks once + `ledger.sh coverage goals/EVIDENCE.md 6` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool jurors: J1 re-runner (own commands; `git diff --stat` on test/ledger) · J2 ledger-auditor (GENESIS chain, D#↔E-D#) · J3 constraint+Goodhart (proxy ✓ AND intent ✓). REJECT → deficiency list only; reopening valid; 3 rejects/item = BLOCKED → user.
SAFETY: 25 turns; below 30% left (≤7) verification+closure only; if unfinished, honest status report.

═══ EVALUATOR ═══
<condition>
DONE iff transcript shows (1) an E-D# raw block for EVERY D1-D6, (2) 3 jurors' UNANIMOUS APPROVE, (3) an item dump. Goodhart: real-time ⇒ measured p95 propagation < 200ms; no data loss ⇒ sha256(docA)==sha256(docB), stroke_count==expected. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (PLAN) · D2↔E-D2 (bakeoff+URLs) · D3↔E-D3 (stroke+cursor) · D4↔E-D4 (convergence sha) · D5↔E-D5 (latency+scanners) · D6↔E-D6 (curl+shot)
</evidence-map>
<anti-accept>
NOT met if ANY: a done/synced claim with no raw block, or a summary where one is required · convergence without equal sha256 of both docs · no/non-unanimous jury, OR a juror verdict with no preceding Agent-tool subagent block (= fabricated jury) · a juror verdict with no adjacent E-D#/E-S#/hash/machine anchor · a D# never mentioned · an unresolved FORBIDDEN violation · turn cap exceeded without honest status · the report lacks exactly ONE STOP_REASON: <T>, T ∈ {TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, RED-HOLD, OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Deploy host + server model: a WebSocket whiteboard needs a persistent process — confirm Vercel-functions-are-insufficient and pick Fly/Render/Railway/self-host (affects D6 live-URL evidence). 2) Perf targets: confirm p95 propagation < 200ms, the 5-concurrent-client load, and the bytes/stroke floor (RECIPES lets me propose; these are defaults). 3) Stack/CRDT: D2 is set to "research decides" (Yjs+y-websocket vs Automerge vs custom-OT) since this is a headless compile; if you already prefer Yjs, collapse D2 to a one-line confirm and reclaim a deliverable. 4) Persistence: should a board survive server restart (DB/Redis/file) or is in-memory + client-CRDT enough for v1? (scopes the §RED-HOLD "DB delete" and D5/D6). 5) Auth/rooms: I FORBADE auth scope creep — confirm v1 is open board-by-URL with no login. 6) Local scanners: gitleaks + osv-scanner must be installed for D5; if absent, that evidence lands PENDING-INSTALL with the official exit-code table cited.

---
*Stack note: Q7 fired (greenfield realtime+CRDT capability, headless compile → default "research decides"): D2 compiles a stack-bakeoff over Yjs+y-websocket vs Automerge vs custom-OT (≥4 criteria, ≥4 live sources), and the winner rewrites the D3 skeleton phase. If the user pre-names a stack, D2 collapses to a confirm.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
