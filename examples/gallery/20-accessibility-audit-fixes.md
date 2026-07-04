# Accessibility audit + fixes — goal-forge gallery example

**Domain:** a11y / web · **Mode:** goal — done is definable (axe 0 critical/serious + keyboard-nav + AA contrast + WCAG-AA evidence, proven live); 6 deliverables, one-shot not recurring, <8 items → not loop, not campaign
**Lint self-score:** 96/100 · **3991 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 9 · 10 Tribunal 9`
**Weakest:** #3 Constraints & #6 Goodhart (both 9): FORBIDDEN names areas not concrete repo files (no scanned project — inherent to a template), and "full keyboard operability" is a behavioral pass/fail proxied by the tab-traversal script rather than a pure numeric inequality — grounded by visible-focus + no-trap + no-positive-tabindex machine assertions. #9 docked to 9: 3991 sits at the top of the 3000-4000 band, so a paste that adds whitespace risks the 4000 ceiling.

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/a11y-EVIDENCE.md·label=D#]
DONE-MEANS (full def <condition>): every D1-D6 E-D# raw-evidenced + UNANIMOUS 3-juror verdict.

═══ WORKER LAYER ═══
MISSION: the target web app passes WCAG 2.1 AA — 0 axe critical/serious across ALL core routes, full keyboard operability, AA contrast — proven live.

TASKS (ev → ledger via ledger.sh append, label=D#):
□ D1 PLAN.md: FULL core-route set R (URLs), toolchain, phases baseline→fix→verify — ev: `ls -la PLAN.md`+`wc -l`+|R| pasted.
□ D2 baseline axe-core scan of EVERY route in R (@axe-core/cli or Playwright+axe, wcag2a+wcag2aa) — ev: raw JSON/route + by-impact table; tripwire: scanned-count==|R|; off-scope route=OPEN, never clean.
□ D3 fix all crit+serious (+ARIA: landmarks/alt/labels/name-role-value), re-scan R — ev: re-scan JSON, exit 1 unless crit+serious==0 across |R|; `git diff` shows no disableRules/exclude/aria-hidden dodge (suppression=FAIL); controls-with-accessible-name==total.
□ D4 keyboard-nav fix (focus order, no traps, visible focus, skip-link) — ev: Playwright tab-traversal/flow (focus path + `:focus-visible` assert, exit 0); `grep -rn 'tabindex="[1-9]'` empty.
□ D5 contrast fix to AA (text ≥4.5:1, large/UI ≥3:1) — ev: measured ratios/pair as NUMBERS + tool command; tripwire: checker exit 0 / min-ratio ≥ threshold.
□ D6 WCAG 2.1 AA report + live verify — ev: per-SC checklist → D2-D5 E-D# + `curl -s -o /dev/null -w "%{http_code}"`==200/route + final clean axe re-scan.
FORBIDDEN: brand/visual redesign beyond contrast token tweaks · business-logic/API/backend edits · disabling/excluding rules or hiding failing nodes (aria-hidden/display:none) · positive tabindex · narrowing scope below R · new heavy runtime deps.
ASSUMPTION: on ambiguity assume + list in the report; never wait on the user — EXCEPT a §DAL-C irreversible action (name it, ledger a HELD entry, STOP once).
LEDGER: raw outputs via ledger.sh append; full text stored; a changed file gets a superseding entry; a summary never replaces the raw block.
PIN: post-compaction AND every ~10 turns restate: active FORBIDDEN + gate decision + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run every axe/kbd/contrast check + `ledger.sh coverage <ledger> 6` + `ledger.sh verify`; any fail=no jury) → PROSECUTOR self-audit → 3 tool jurors: J1 re-runner (own cmds) · J2 ledger-auditor (chain from GENESIS; D#↔E-D#) · J3 constraint+Goodhart (proxy ✓ AND intent ✓). REJECT→deficiency list only; reopening valid; 3 rejects=BLOCKED→user.
SAFETY: 25 turns; below 30% remaining, verification+closure only; if unfinished, honest status + STOP_REASON.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript shows (1) an E-D# raw cmd+output block per D1-D6, (2) 3 jurors' UNANIMOUS verdict, (3) item-by-item evidence dump. Goodhart: "accessible" holds only when axe crit+serious==0 across ALL |R| routes (scanned-count==|R|, no rule-disables/hide-dodges in the diff) AND every core flow is keyboard-completable with visible focus — proxy ✓ AND intent ✓. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (plan+R) · D2↔E-D2 (axe JSON) · D3↔E-D3 (0 crit/ser, clean diff) · D4↔E-D4 (tab) · D5↔E-D5 (contrast#) · D6↔E-D6 (live 200)
</evidence-map>
<anti-accept>
NOT met if ANY appear: a pass/"zero" claim or summary with no raw axe JSON block · scope narrowed below R or a route silently marked clean · rules disabled/excluded or nodes aria-hidden to dodge · positive tabindex present · no verdict, non-unanimous, OR a juror verdict with no preceding Agent-tool subagent block (prose-only seal = fabricated jury) · a juror verdict with no adjacent E-D#/E-S#/hash/machine-assertion cite · an unresolved FORBIDDEN violation · turn cap exceeded, no honest status · the report lacks exactly ONE `STOP_REASON: <T>`, T ∈ {TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, DAL-C-HOLD, OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Target URL(s) + environment (local vs staging) and auth for protected routes. 2) The exact core-route set R (which flows count as "core"). 3) Tool choice: @axe-core/cli (static) vs Playwright+axe (interactive/authenticated) + which contrast checker. 4) Confirm target = WCAG 2.1 AA (vs 2.2 or AAA). 5) Whether contrast-driven brand/design-token changes are pre-approved by design or need sign-off (a locked brand could turn a needed contrast fix into a §DAL-C-style hold). 6) Q6 juror models (default sonnet; opus for the hardest verify).

---
*Stack note: Existing web app, not greenfield → Q7 SKIP (adding an audit/a11y capability to a project that already has a stack). Tooling assumed and recorded as an ASSUMPTION: axe-core via @axe-core/cli or Playwright+axe (WCAG 2.1 AA ruleset) + a contrast checker + curl for live verification; actual app framework and route set are user-provided (decide-list).*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
