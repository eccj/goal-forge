# Docs site for an OSS library — goal-forge gallery example

**Domain:** documentation · **Mode:** goal — one definable "done" (a Docusaurus site that builds clean, has zero broken links, and whose Getting Started reproduces in a fresh env); not recurring (rules out loop), 6 deliverables (<8, rules out campaign)
**Lint self-score:** 97/100 · **3984 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #6 Goodhart (9) — the reader-task and link metrics are exit-code-gated, but D6's "styled code blocks visible" screenshot assessment keeps a small bounded-semantic residue; #3 and #10 also sit at 9 (constraints could name exact library paths; Tribunal prose was compressed for the char budget but retains COMPLETION-GATE, from-GENESIS chain, anchored-verdict, prosecutor self-audit, reopen, 3-strikes, dual sign-off).

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:standard·ledger:goals/EVIDENCE.md·label=D#]
DONE-MEANS (full def in <condition>): every D# item E-D# raw-evidenced + UNANIMOUS 3-juror verdict + per-item ledger.

═ WORKER LAYER ═
MISSION: A Docusaurus docs site for the OSS library: builds clean, zero broken links, and its Getting Started reproduced verbatim in a fresh env yields the documented working example.

TASKS (evidence → ledger via ledger.sh, label=D#):
□ D1 PLAN.md, phase-ordered (scaffold→content→links→repro→live) — evidence: `ls -la PLAN.md`+`wc -l`+`shasum -a 256`; changed ⇒ superseding entry.
□ D2 Docusaurus builds clean, config hard-fails on bad links — evidence: FULL `npm run build` stdout+exit 0 (not tail) + `grep -nE "onBrokenLinks|onBrokenMarkdownLinks" docusaurus.config.*` BOTH ='throw'; exit≠0 or either ≠throw = FAIL.
□ D3 Author landing + getting-started + ≥2 guides + API reference — evidence: `git ls-files docs sidebars.* src/pages` + `grep -nE "^#{1,3} " <each>` headings quoted; each rendered in D6.
□ D4 Reader-task repro — in a FRESH dir run Getting Started §Install+§First-Example VERBATIM — evidence: copied cmds + real stdout + exit codes; script exits 0 ONLY if produced output == the doc's claim. Narrating output = FORBIDDEN.
□ D5 External links unbroken — `lychee --format json build/`; checked-count == links in `find build -name '*.html'` (narrowed scan fails) — evidence: raw lychee summary + scope diff; 4xx=FAIL, flaky 429/timeout=OPEN (internal: D2).
□ D6 Serve + verify live — evidence: `npm run serve` + `curl -s -o /dev/null -w "%{http_code} %{time_total}\n"` on landing/getting-started/api (each 200) + screenshot TAKEN and ASSESSED in writing (nav/sidebar/styled code visible).

FORBIDDEN: onBrokenLinks/onBrokenMarkdownLinks off 'throw'; narrowing/--exclude the link scan; editing library source/API to fit a doc (wrong example → fix the DOC); fabricated repro output; committing build/; secrets in config.
ASSUMPTION: on ambiguity assume + list it; never wait on the user — EXCEPT a §RED-HOLD irreversible action (prod deploy/Pages push): name it, ledger a HELD entry, STOP once.
LEDGER: raw outputs via ledger.sh append; full text stored; changed file ⇒ superseding entry; a summary never replaces a raw block.
PIN: first msg post-compaction AND every ~10 turns restate: active FORBIDDEN + governing gate + ledger path.
PROCESS: done-claim → COMPLETION GATE (re-run all checks once + `ledger.sh coverage goals/EVIDENCE.md 6` + `ledger.sh verify`; any fail ⇒ no jury) → PROSECUTOR self-audit → 3 tool jurors: J1 Re-runner · J2 Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart (proxy ✓ AND intent ✓). REJECT ⇒ deficiency list; reopen valid; 3× one item ⇒ BLOCKED→user.
SAFETY: 25 turns; below 30% left (~7) verification+closure only; unfinished ⇒ honest status.

═ EVALUATOR LAYER ═
<condition>
DONE iff transcript shows (1) an E-D#-labeled raw cmd+output block for EVERY D1-D6, (2) 3 jurors' UNANIMOUS verdict, (3) a per-item dump. Goodhart: "0 broken links" counts ONLY if checked-count==built-link-count AND onBrokenLinks stayed 'throw' (build exit 0) — narrowing scope or downgrading config is proxy-gaming, not done. Any missing ⇒ NOT DONE.
</condition>
<evidence-map>
D1↔E-D1(plan) · D2↔E-D2(build+throw) · D3↔E-D3(pages) · D4↔E-D4(repro exit0) · D5↔E-D5(links+scope) · D6↔E-D6(curl 200+shot)
</evidence-map>
<anti-accept>
NOT met if ANY: "builds clean" with no `npm run build` output · onBrokenLinks set to warn/ignore · repro "works" with no fresh-env cmd+stdout+exit · link scan narrowed (checked < built-link-count) · a juror verdict with no preceding Agent-tool subagent block or no cited E-D#/hash/assertion · a D# unmentioned or an unresolved FORBIDDEN violation · turn cap exceeded, no status · report lacks exactly ONE STOP_REASON ∈ {TRIBUNAL-UNANIMOUS,TURN-CAP-STATUS,BLOCKED-3REJECT,RED-HOLD,OUTAGE-FALLBACK,CRASH-RESUME,NO-PROGRESS,AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Which OSS library/repo the docs describe, and the exact "first working example" the reader-task (D4) must reproduce — compiled assuming the library exists in-repo with an installable Getting Started. 2) Deploy target (GitHub Pages / Vercel / Netlify): the actual publish is a §RED-HOLD terminal HOLD the user runs; confirm the host. 3) External-link policy: internal links are the hard gate (D2 onBrokenLinks:'throw'); external checked by lychee with network-flaky 429/timeout marked OPEN not failed — confirm this is acceptable, and lychee vs linkinator. 4) Tribunal juror models: default sonnet; consider opus for J3 (hardest verify) — Fable optional/unavailable. 5) Exact page set / information architecture — assumed landing + getting-started + ≥2 guides + API reference. 6) Docusaurus major version (assumed v3) so the config keys and build flags match.

---
*Stack note: Docusaurus is user-named in the brief → STACKS §Firing SKIP case (mission names the tech): confirmed as prefilled default, no stack-bakeoff deliverable. Assumed Docusaurus v3 (onBrokenLinks/onBrokenMarkdownLinks config keys); link-checker assumed `lychee` (linkinator is an equivalent swap).*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
