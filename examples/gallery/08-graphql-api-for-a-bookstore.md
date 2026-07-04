# GraphQL API for a bookstore — goal-forge gallery example

**Domain:** API / backend · **Mode:** goal — a single definable done-state (build + prove one API); not recurring/monitoring (→loop) and only 5 deliverables, well under the 8-item campaign line (→campaign)
**Lint self-score:** 97/100 · **3978 chars** (canonical, ≤4000)

`1 End state 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #10 Tribunal (9) — juror disjoint-context/isolation is implied by spawning J1/J2/J3 as separate Agent-tool subagents (and the anti-accept requires a preceding subagent block + anchored verdict per juror) but is not spelled out in-text, to stay under 4000 chars; everything else in the v5 protocol is present.

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:EVIDENCE.md·label=D#]
DONE-MEANS (see <condition>): every D# E-D#-evidenced + UNANIMOUS 3-juror verdict.

═══ WORKER LAYER ═══
MISSION: a running Apollo 4 GraphQL bookstore API (Book/Author/Review/User): N+1-safe via DataLoader, JWT-auth mutations, probed error paths — each proven by a pasted request/response.

TASKS (ev → EVIDENCE.md via ledger.sh, label=D#):
□ D1 PLAN.md: schema sketch + phase order (boot→N+1→auth→errors→tests) + stack (Apollo4/TS/Prisma/SQLite/DataLoader/JWT) + N+1-count method — ev: `test -f PLAN.md && wc -l PLAN.md`.
□ D2 Server + persistence: SDL types + Query/Mutation, Apollo 4 listens, Prisma/SQLite seeded — ev: `curl -s -w "\n%{http_code}"` POST `books{id title author{name}}`; raw JSON w/ seeded rows + http==200 + `SELECT count(*)`==returned length (exit 1 on NEQ).
□ D3 N+1 guard: DataLoader batches author+reviews — ev: query ≥10 books nesting author{name} reviews{id}; DB-query counter pasted; a test asserts author-loader SQL ==1 (batched); exit 1 if it scales with book count.
□ D4 Auth: JWT context; createBook/addReview require a valid token — ev: the SAME mutation: no-token → extensions.code UNAUTHENTICATED, valid-token → OK; both raw JSON + before/after row count proving no write (diff==0).
□ D5 Error-path probes + integration suite: probe malformed query, unknown field, bad ISBN, missing id (NOT_FOUND/null), unauthenticated — each asserting its extensions.code; offline vs the server (executeOperation/HTTP) — ev: full `npm test` output, exit code shown (no tail), each expected error-code visible.
FORBIDDEN: mocking the DB/resolver path in D3-D5 (hit real resolvers) · disabling validation to hide errors · resolvers that echo input · secrets committed (JWT from env) · live network in tests · test-scope narrowing · scope creep beyond the API.
ASSUMPTION: on ambiguity, assume + list it; never wait on the user — EXCEPT a §DAL-C irreversible action: name it, ledger a HELD entry, STOP once.
LEDGER: raw outputs via ledger.sh append (full text stored); changed files get a superseding entry; a summary never replaces a raw block.
PIN: post-compaction & every ~10 turns, restate one line: active FORBIDDEN + gate decision + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run all checks once + `ledger.sh coverage EVIDENCE.md 5` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 method-diverse jurors: J1 Re-runner (own commands; git diff on test/ledger) · J2 Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart (proxy ✓ AND intent ✓). REJECT → deficiency list only; reopen valid; 3 rejects/item = BLOCKED→user.
SAFETY: 25 turns; below ~7 left, verification+closure only; unfinished → honest status.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript shows (1) an E-D# raw request/output block for EVERY D1-D5 AND (2) the 3 jurors' UNANIMOUS APPROVE AND (3) an item-by-item dump. Goodhart: D3 (author-SQL ==1, not ×book-count), D4 (blocked-write-diff ==0), D5 (each probe's expected error-code) each bind on a machine assertion; a proxy without it doesn't count. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (PLAN) · D2↔E-D2 (boot 200+rowcount EQ) · D3↔E-D3 (batched SQL==1) · D4↔E-D4 (no-token+write-diff) · D5↔E-D5 (probe codes+npm exit0)
</evidence-map>
<anti-accept>
NOT met if ANY appear: a done/pass claim (or summary) where a raw block is required · an N+1/auth/error-path proxy without its machine assertion (query-count / write-diff==0 / expected error-code) · no jury verdict / non-unanimous / a juror verdict with NO preceding Agent-tool subagent block = fabricated jury · a juror verdict with no E-D#/hash/machine-assertion anchor · an unresolved FORBIDDEN violation · the report lacks exactly ONE `STOP_REASON: <T>`, T∈{TRIBUNAL-UNANIMOUS,TURN-CAP-STATUS,BLOCKED-3REJECT,DAL-C-HOLD,OUTAGE-FALLBACK,CRASH-RESUME,NO-PROGRESS,AWAITING-USER} · DONE with STOP_REASON≠TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Data layer: assumed Prisma+SQLite (clean N+1 counting via the query event); alternatives better-sqlite3 + counting wrapper, or Drizzle — confirm. 2) Auth depth: assumed JWT (jsonwebtoken) with an UNAUTHENTICATED extensions.code and a minimal token-issue/login path or a pre-seeded test token — confirm whether real register/login is in scope or a stub issuer suffices. 3) Test runner + transport: assumed node:test or vitest driving Apollo `executeOperation` over the standalone HTTP server on a chosen port — confirm (Express/Fastify integration? fixed port?). 4) Tribunal strictness: assumed standard (3 jurors + self-audit prosecutor); if the API is treated as security-sensitive, upgrade to heavy (+independent prosecutor, formula +5 → budget 30). 5) Juror models: assumed sonnet across J1/J2/J3 (opus optional for J3-Goodhart on the hardest verify) — confirm. 6) Error-probe set: assumed the 5 named probes; add any domain-specific ones (duplicate-ISBN conflict, pagination bounds, rate-limit) if wanted. 7) Turn budget: 25 is the formula suggestion; a real user may tighten it, at the cost of less reopen/rework headroom.

---
*Stack note: Named tech (Apollo) confirmed as prefilled default per STACKS §Firing SKIP-case (mission names the tech → confirm, don't re-ask 4 options). Assumed full stack: Apollo Server 4 (startStandaloneServer) + TypeScript + Prisma/SQLite + DataLoader + jsonwebtoken + node:test/vitest, with the N+1 query-count read off Prisma's `$on('query')` event (or a counting DB wrapper). Data-layer choice and auth-depth are decide-list items.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
