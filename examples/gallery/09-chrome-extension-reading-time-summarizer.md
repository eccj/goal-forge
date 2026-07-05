# Chrome extension: reading-time + summarizer — goal-forge gallery example

**Domain:** browser extension (MV3, content-script, offline summarize, store-policy compliance) · **Mode:** goal — a single definable finished state (a shippable, store-ready MV3 extension). 6 numbered deliverables (<8, so not a campaign) and one coherent artifact; nothing recurring/monitored (so not a loop). Standard tribunal (>3 items AND >15 turns → light mode disallowed).
**Lint self-score:** 97/100 · **3990 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #6 Goodhart (9) — "good summary" is measured by structural anti-hallucination proxies (K sentences, every sentence a verbatim source substring) plus offline proxies (0 remote endpoints, netRequests==0), not by a semantic readability/usefulness metric; that is a deliberate Goodhart-resistant choice but leaves subjective summary quality unmeasured. #3 and #10 also sit at 9 (constraints name categories not literal file paths on a greenfield repo; J2's "broken hash chain = auto-REJECT" is implied via the anchored-verdict clause rather than spelled out — both compressed to hold the 4000-char limit).

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/EVIDENCE.md·label=D#]
DONE-MEANS (full in <condition>): every D1-D6 E-D#-raw-evidenced + a UNANIMOUS 3-juror verdict.

— WORKER —
MISSION: ship an MV3 Chrome extension: a content script computing reading-time + an on-demand extractive summary, fully on-device, passing Chrome Web Store policy checks.

TASKS (raw evidence → the ledger via ledger.sh, label=D#):
□ D1 PLAN.md phase-roadmap (scaffold→cs→summarizer→e2e→policy→pkg), D2-D6 state in file — ev: `wc -l` + 6 headings quoted.
□ D2 MV3 build+package: manifest (v3, service_worker, content_scripts, activeTab+scripting), esbuild→dist/, zip→extension.zip, README (install+perm justification) — ev: build exit0 + node manifest_version==3 check (exit0) + `shasum` dist==zip-entry + README §headings.
□ D3 reading-time cs: article text, words÷WPM, badge — ev: `npx vitest run` full output (exit visible), known word-count fixtures; |computed−analytic|≤10% (miss→exit1).
□ D4 offline summarizer: in-page frequency/TextRank, K sentences each a VERBATIM source substring — ev: vitest exit0 + `grep -rnE "fetch\(|XMLHttpRequest|https?://" src/summarizer`→0 + every sentence∈source; exit-coded.
□ D5 instrumented e2e: Puppeteer --load-extension in headless Chrome (ver logged), fixture article → cs injected + badge value + K-sentence summary, request-interception counting outbound — ev: stdout exit0 + a netRequests==0-during-summarize line + `shasum` report + Chrome ver.
□ D6 store-policy: policy-check.sh — perms⊆{activeTab,scripting,storage}, no `<all_urls>`, 0 remote code (`grep -rnE "eval\(|new Function|<script src=.https"`→0), CSP in manifest, PRIVACY.md — ev: policy-check.sh raw (exit0/1) + `web-ext lint` else cite its exit-code table, PENDING.

FORBIDDEN: no remote/eval'd code · no network call to summarize · no `<all_urls>`/broad hosts · no telemetry · don't touch the Chrome profile · nothing out of scope.
ASSUMPTION: on ambiguity assume + list it; never wait — EXCEPT §RED-HOLD (e.g. a Web-Store PUBLISH): name it, ledger a HELD entry with the exact user command, STOP once. Stack: vanilla TS+esbuild+vitest+Puppeteer, no framework — recorded.
LEDGER: raw outputs via `ledger.sh append`; full text stored; changed file→superseding entry; no summary replaces a raw block.
PIN: after compaction & every ~10 turns restate FORBIDDEN + gate decision + ledger path.
PROCESS: on done → COMPLETION GATE (rerun mechanical checks + `ledger.sh coverage goals/EVIDENCE.md 6` + `ledger.sh verify`; fail=no jury) → PROSECUTOR self-audit → 3 tool-jurors (separate context, verdicts ground-truth-anchored): J1 Re-runner (own commands + `git status`/`diff --stat` over test/build/policy; undeclared edit=REJECT) · J2 Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart dual sign-off. REJECT→deficiency list; reopen valid; 3 REJECT=BLOCKED→user.
SAFETY: 25 turns; below 8 remaining only verification+closure; else honest status report.

— EVALUATOR —
<condition>
DONE ⟺ transcript shows (1) an E-D# raw command+output block for EVERY D1-D6, (2) the 3 jurors' UNANIMOUS verdict, (3) an item-by-item evidence dump. GOODHART "offline+store-safe" = 0 remote endpoints in the summarizer bundle AND D5 netRequests==0 AND policy-check.sh exit==0 — proxy AND intent both. Any gap ⇒ NOT DONE.
</condition>
<evidence-map>
D1↔E-D1(plan)·D2↔E-D2(build+hash)·D3↔E-D3(RT≤10%)·D4↔E-D4(grep0+substr)·D5↔E-D5(netReq0)·D6↔E-D6(policy0)
</evidence-map>
<anti-accept>
Any of: a done-claim with no raw output · no/non-unanimous jury verdict, OR a verdict with no preceding Agent-subagent block (prose seal=fabricated jury) · a verdict lacking a cited E-D#/E-S#, hash or machine-assertion · a D# unmentioned · a FORBIDDEN violation · turn cap exceeded, no status report · the report lacks exactly ONE `STOP_REASON: <T>`, T∈{TRIBUNAL-UNANIMOUS,TURN-CAP-STATUS,BLOCKED-3REJECT,RED-HOLD,OUTAGE-FALLBACK,CRASH-RESUME,NO-PROGRESS,AWAITING-USER} · DONE with STOP_REASON≠TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Summarizer engine depth — pure extractive frequency/TextRank (assumed: zero-weight, guarantees the offline+no-remote-code invariant) vs a bundled small on-device model (e.g. transformers.js); a model adds bundle size, a store-review surface, and turns. 2) Reading-time WPM constant (assumed 200 wpm) and article-extraction approach (assumed Mozilla Readability.js vs custom heuristics); a per-user WPM setting would add a chrome.storage pref. 3) Target browsers — Chrome-only (assumed) vs also Edge/Firefox; note `web-ext lint` is Firefox-oriented, so Chrome store-policy is enforced mainly by policy-check.sh. 4) Whether to actually PUBLISH to the Web Store — assumed OUT of scope and modeled as a §RED-HOLD terminal HOLD (goal ships the store-ready extension.zip; the human runs the publish/upload step). 5) UI surface — assumed content-script badge + on-demand summarize trigger, no popup/options page (MV3-minimal); a popup would add a deliverable. 6) The `storage` permission is in the allowlist for prefs — drop it from {activeTab,scripting,storage} if no settings are stored, to tighten the permission footprint further.

---
*Stack note: Stack was NAMED by the theme (MV3 Chrome extension), so STACKS §Firing = CONFIRM-not-ask, no bakeoff. Assumed toolchain baked into the contract: vanilla TypeScript + esbuild (small MV3 bundle, no UI framework), vitest for unit tests (D3/D4 tolerance + substring tripwires), Puppeteer `--load-extension` in headless Chrome for the instrumented e2e (D5), plus a repo-local policy-check.sh + optional `web-ext lint` for store-policy (D6). This is the browser-extension analog of the RECIPES mobile row (instrumented device test + hashed report artifact + engine/version fingerprint) fused with the security-scan row (named scanner + exit code + file-scope diff) for the store-policy gate.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
