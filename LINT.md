# Goal Quality Score — 10-criteria lint rubric

Score each criterion 0-10. Report as a scorecard table. **Threshold: 80.**
Below 80 → fix and re-lint before delivering. Never deliver a goal scoring <80.

**HARD FLOORS (veto, override the sum):** #2 (Evidence-in-transcript) and #10 (Tribunal + Ledger) must EACH be ≥8, AND no criterion may be <5 — regardless of total. Any floor breach → the goal FAILS lint independent of the sum: a ≥80 total with a gutted #2 or #10 is a FALSE PASS. Fix the floored criterion and re-lint; the 80 threshold applies only AFTER all floors are met.

| # | Criterion | 10 points looks like | 0 points looks like |
|---|---|---|---|
| 1 | **Measurable end state** | Mission describes an observable finished state; goal opens with the metadata line + a SHORT DONE-MEANS pointer (full definition lives in <condition>) | "make it great/production-ready", or done-definition duplicated in full at top and bottom |
| 2 | **Evidence-in-transcript** | Every deliverable is a □ D# line carrying its evidence method INLINE (D#↔E-D# ledger-label match); <evidence-map> mirrors the pairs in one line + MACHINE TRIPWIRE: each deliverable's evidence includes ≥1 falsifiable machine assertion (exit code / diff / hash / count) that no model opinion can override — a deliverable resting only on prose/opinion scores DOWN | "tests pass" with no paste instruction; evidence separated from its task; no D#/E-D# IDs |
| 3 | **Constraint clarity** | MUST-NOTs list concrete files/areas/integrations; a KILL-CRITERIA line (what evidence disqualifies the goal) + a one-line PREMORTEM strengthen it (decision hygiene, TEMPLATE) | no constraints, or vague "don't break things"; no kill-criteria on a consequential goal |
| 4 | **Assumption authority** | Explicit "make reasonable assumptions, list them in the report; nothing waits on the user" — EXCEPTION: a §DAL-C terminal HOLD on an irreversible agent-unauthorized action is an ALLOWED terminal state, not a wait | items that require future user input (a genuine §DAL-C hold does NOT count against this) |
| 5 | **Turn cap + estimate** | Cap present AND N suggested by the formula: `N = ceil(deliverable_count × 2.5) + 8 (tribunal reserve; +5 MORE when jury:heavy — an independent prosecutor plus 10+ findings eats ~80% of budget, GUARDRAILS 2026-07-03)`, rounded UP to the nearest of {20, 25, 30, 40, 50}; deliverable_count = numbered □ D# task items (TASKS/DELIVERABLES). The formula SUGGESTS — the user may tighten (note the risk in one line). LIGHT-MODE exception: light goals (≤3 items — or ≤5 when G=1: every D# [M]-typed — TEMPLATE §Light) use FIXED N=15 — the 20-floor is waived by design; this is the documented tighten case, no extra note needed. CALIBRATION: prefer median usage of the last 5 comparable runs × 1.3 (computed at compile from goals/METRICS.md rows, never hardcoded here); no data → the formula above. Budget regime band included ("below 30% remaining: no new exploration") | no cap, or N guessed with no formula |
| 6 | **Goodhart conversions** | Each subjective wish converted to a measurable inequality ("feels fast" → "cold-load DOM < 2s, 0 MB media at load — measured in report") | subjective wishes left unmeasured |
| 7 | **Independence from user** | Zero items blocked on user decisions; leftovers moved to "decide before launching"; EXCEPTION: a §DAL-C terminal HOLD is a legitimate terminal state, not a blocking dependency | "user will explain X later" inside the goal |
| 8 | **Single-topic focus** | ≤7 major deliverables, one coherent mission | grab-bag of unrelated work (→ campaign) |
| 9 | **Char budget** | Measured in CHARACTERS, not bytes — `wc -c` counts bytes and overstates UTF-8 text (Turkish/Cyrillic ≈ +8-10%). Write the goal draft to a scratch file, then measure with THE canonical tool: `scripts/ledger.sh measure <draft-file>` (UTF-8-locale-enforced wc -m, trailing newlines stripped, method-labeled output; guards the C-locale byte trap). Cross-check (MUST agree — trailing-newline-only scope): `python3 -c "import sys; print(len(sys.stdin.read().rstrip('\n')))" < <file>` (rstrip, NOT strip: leading newlines are content). Ideal band 3000-4000 chars (hard limit 4000); report the goal text's own count, never the surrounding explanation's. MIRROR: the archive MUST carry the §Archive human-mirror (plain-language twin) and delivery a ≤5-line plain summary — density is for the machine, the twin is for the operator; a compressed goal with no mirror scores DOWN. BUDGETED-COMPOSE (TEMPLATE): allocate per-section char budgets (Σ≤3800) BEFORE writing and write TO them — the first draft must land in the 3000-4000 band; >1 compression pass = process defect, scores DOWN | >4000 chars, unverified, or byte-count presented as char-count |
| 10 | **Tribunal + Ledger integrity** | CONFORMANCE to TEMPLATE.md — the CANONICAL protocol text (this cell scores presence, it does not restate the rules). Must-haves, each defined in TEMPLATE: COMPLETION GATE before any jury (one-pass re-run + `ledger.sh coverage` + `verify`) · GUARDRAILS read at compile · PLAN-first for ≥25-turn budgets · 3 METHOD-diverse ISOLATED tool-equipped jurors + ANCHORED-VERDICT (every verdict cites ≥1 ground-truth anchor; J2 from-GENESIS mismatch = auto-REJECT) · prosecutor (heavy = independent subagent; S#↔E-S#) · Evidence-Ledger clause · Goodhart dual sign-off · reopen + deficiency-list-only + 3-strikes BLOCKED + unanimity · EFFORT ROUTING: D# typed [M]/[J] at compile, J1/J2 haiku-checklist on [M], J3+prosecutor sonnet/opus only on [J] (routing changes cost, never method count) · LIGHT carve-out: ≤3 items — or ≤5 when G=1 (all-[M]) — AND ≤15 turns → §Light single auditor; ledger/gate/archive NEVER lightened; forbidden ≥25 turns · skeleton v2 two-layer with <condition>/<evidence-map>/<anti-accept> (behavior patterns, range tokens D1-D<n>). Any conflict between this cell and TEMPLATE.md → TEMPLATE wins; fix this cell | missing/weakened protocol, identical or text-only jurors, no ledger, no reopen clause, single-layer skeleton on a new compile |

## Scorecard format (show to user)

```
Goal Quality Score: 94/100
1 End state 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10
6 Goodhart 8 · 7 Independence 10 · 8 Focus 9 · 9 Budget 10 · 10 Tribunal 8
Weakest: #6 — "premium feel" left partially unmeasured → converted to contrast/spacing checks.
```

## Auto-fix guide
- #2 fails → append "— evidence: paste the command output / verify live URL and
  record the result" to each deliverable.
- #6 fails → ask yourself "what inequality would convince a skeptic?" and write it.
- #8 fails → split into a campaign (CAMPAIGN.md) instead of shipping a mega-goal.
- #10 fails → re-paste the Tribunal block from TEMPLATE.md verbatim; do not
  hand-shorten it below its invariants.
