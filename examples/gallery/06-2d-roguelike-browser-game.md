# 2D roguelike browser game — goal-forge gallery example

**Domain:** game / web · **Mode:** goal — one definable finished state (ship a playable roguelike); 6 deliverables (<8, so not a campaign) and one-shot delivery (not recurring, so not a loop)
**Lint self-score:** 97/100 · **3992 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #10 Tribunal (9) — to fit 4000 chars I compressed the explicit juror-isolation clause ("disjoint context, none sees another's verdict") and the "J2 GENESIS-mismatch = auto-REJECT no semantic juror overrides" line out of the goal text; both still bind because the worker runs the jurors from the skill's TEMPLATE §Juror-prompt core, but the compiled contract itself doesn't restate them. Both hard floors pass (#2=10, #10=9 ≥8; no criterion <5).

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/EVIDENCE.md·label=D#]
DONE-MEANS (full def in <condition>): every D# E-D# raw-evidenced + UNANIMOUS 3-juror verdict in the report.

═══ WORKER LAYER ═══
MISSION: a playable 2D roguelike in the browser — raw Canvas2D + TypeScript + Vite, deterministic procedural levels, localStorage save/load, measured 60fps budget.

TASKS (ev → goals/EVIDENCE.md via ledger.sh, label=D#):
□ D1 PLAN.md, phase-ordered (skeleton→core→polish→live); each phase closes with E-D# before the next — ev: `ls -la PLAN.md` + `wc -l` + quoted phase headings.
□ D2 boots: Vite+TS, fixed-timestep loop (accumulator) draws a frame to <canvas> — ev: `npm run build` stdout+exit 0; dev `curl -w '%{http_code} %{size_download} %{time_total}'`=200; screenshot assessed.
□ D3 procedural gen: seeded PRNG, room/tile graph — ev (data-pipeline): a test gens twice on one seed: sha256(run1)==sha256(run2) AND sha256(seedA)!=sha256(seedB); BFS asserts a start→exit path; exit 1 on fail — paste stdout+exit.
□ D4 core loop: move, AABB collision, enemies, hit/damage, permadeath+win — ev: `npm test` stdout+exit 0 (collision / damage→death / win-transition asserts; test count) + playthrough shot assessed.
□ D5 save/load to localStorage — ev: round-trip test deep-equals before==after (exit 0) AND a corrupt/oversized load rejected without crash — paste stdout+exit.
□ D6 60fps + ship: headless run ≥600 frames — ev (perf): harness prints p95 + max frame ms + cmd; a gate exits 1 if p95 ≥ 16.67ms OR any frame > 33ms. Served prod: `curl` code/size/time=200 + game shot assessed + `ls -la dist/assets/*.js` bytes.
FORBIDDEN: no engine/lib (Phaser/Pixi/Unity), raw Canvas2D only · no runtime network/CDN (offline, self-contained) · never break D3 determinism · don't commit node_modules/dist · nothing outside these 6 items.
ASSUMPTION: on ambiguity assume + list it; never wait — EXCEPT a §RED-HOLD irreversible action (publish to a host): name it, ledger a HELD entry, STOP once.
LEDGER: raw outputs via ledger.sh append; full text stored; a changed file gets a SUPERSEDING entry; a summary never replaces a raw block.
PIN: every ~10 turns and after compaction, restate one line: FORBIDDEN + gate decision + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run build/tests/perf-gate once + `ledger.sh coverage goals/EVIDENCE.md 6` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool-equipped jurors: J1 re-runner (own commands + `git diff --stat`) · J2 ledger-auditor (GENESIS chain; D#↔E-D#) · J3 constraint+Goodhart (proxy✓ AND intent✓). REJECT → deficiency list only; reopen valid; 3 rejects/item = BLOCKED→user.
SAFETY: 25 turns; below 30% (≤7 left) verification+closure only; if unfinished, honest status. Jurors are subagents (sonnet; J3 may run opus) — never text-only.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff, for EVERY D1-D6 item, an E-D# raw cmd+output block appears, PLUS the 3 jurors' UNANIMOUS APPROVE and an item-by-item evidence dump. The D3 equal-hash/BFS and D6 p95<16.67ms/max<33ms machine gates are load-bearing — a proxy pass lacking them is NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (PLAN) · D2↔E-D2 (build+curl+shot) · D3↔E-D3 (seed-hash+BFS+exit) · D4↔E-D4 (test+shot) · D5↔E-D5 (round-trip+corrupt) · D6↔E-D6 (p95/max+served curl+shot)
</evidence-map>
<anti-accept>
NOT met if ANY appear: a done/pass claim backed by no raw block (or a summary in its place) · a 60fps/procedural claim missing its machine evidence (p95/max ms, equal-hash, BFS) · no/non-unanimous jury verdict, a prose-only seal (no preceding Agent-tool subagent block), OR a verdict with no adjacent E-D#/E-S#/hash anchor · a D# never mentioned · an unresolved FORBIDDEN violation · turn cap passed, no honest status · the report lacks exactly ONE STOP_REASON: <T> ∈ {TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, RED-HOLD, OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Engine choice: I assumed raw Canvas2D (brief said "Canvas"). If you want a framework (Phaser/PixiJS), D2 + FORBIDDEN change. 2) Ship target for D6 "served prod" and the §RED-HOLD publish: I assumed a LOCAL static serve (`vite preview`) for evidence and treated any PUBLIC publish (GitHub Pages/Vercel/itch.io) as a §RED-HOLD hold — confirm the host. 3) 60fps threshold + method: I set p95<16.67ms AND no frame>33ms over ≥600 frames via a headless rAF/perf harness; confirm target hardware and whether real-rAF or simulated-tick timing counts. 4) Roguelike scope depth: I assumed single-biome, one enemy archetype, permadeath+win — confirm whether inventory/items, multiple floors, or meta-progression are in scope (those push toward a campaign, not one goal). 5) Jury models: assumed sonnet jurors with J3 opus-eligible; say if you want a cheaper haiku lane or a heavier all-opus panel. 6) Test runner: assumed Vitest (Vite-native); confirm if you prefer Jest/node:test.

---
*Stack note: raw HTML5 Canvas2D + TypeScript + Vite (+ Vitest for `npm test`). Q7 fired (game = capability-greenfield) but the brief NAMES "Canvas", so per STACKS §Firing this is confirm-not-ask: assumed raw Canvas2D (no engine) to keep the bundle tiny and the 60fps budget controllable. Engine alternatives (Phaser / PixiJS) are in the decide-list; picking one rewrites D2 + the FORBIDDEN "raw Canvas2D only" line.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
