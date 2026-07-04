# Goal Quality Score — 10-criteria lint rubric

Score each criterion 0-10. Report as a scorecard table. **Threshold: 80.**
Below 80 → fix and re-lint before delivering. Never deliver a goal scoring <80.

| # | Criterion | 10 points looks like | 0 points looks like |
|---|---|---|---|
| 1 | **Measurable end state** | Mission describes an observable finished state; goal opens with the metadata line + a SHORT DONE-MEANS pointer (full definition lives in <condition>) | "make it great/production-ready", or done-definition duplicated in full at top and bottom |
| 2 | **Evidence-in-transcript** | Every deliverable is a □ D# line carrying its evidence method INLINE (D#↔E-D# ledger-label match); <evidence-map> mirrors the pairs in one line | "tests pass" with no paste instruction; evidence separated from its task; no D#/E-D# IDs |
| 3 | **Constraint clarity** | MUST-NOTs list concrete files/areas/integrations | no constraints, or vague "don't break things" |
| 4 | **Assumption authority** | Explicit "make reasonable assumptions, list them in the report; nothing waits on the user" — EXCEPTION: a §DAL-C terminal HOLD on an irreversible agent-unauthorized action is an ALLOWED terminal state, not a wait | items that require future user input (a genuine §DAL-C hold does NOT count against this) |
| 5 | **Turn cap + estimate** | Cap present AND N suggested by the formula: `N = ceil(deliverable_count × 2.5) + 8 (tribunal reserve; +5 MORE when jury:heavy — an independent prosecutor plus 10+ findings eats ~80% of budget, GUARDRAILS 2026-07-03)`, rounded UP to the nearest of {20, 25, 30, 40, 50}; deliverable_count = numbered □ D# task items (TASKS/DELIVERABLES). The formula SUGGESTS — the user may tighten (note the risk in one line). LIGHT-MODE exception: light goals (≤3 items, TEMPLATE §Light) use FIXED N=15 — the 20-floor is waived by design; this is the documented tighten case, no extra note needed. RECALIBRATION RULE: at COMPILE TIME compute the usage band from BOTH sources — `goals/*` Outcome lines (`Turns used: ~N/M (%x)`, single line) AND `examples/case-*.md` (`Turn usage: ~N of M (x%)`); never hardcode run data or band snapshots in this file (a hardcoded list rotted once). Coefficient rule: midpoint <50% across 5+ runs → drop 2.5 → 2.0, else keep 2.5. Budget regime band included ("below 30% remaining: no new exploration") | no cap, or N guessed with no formula |
| 6 | **Goodhart conversions** | Each subjective wish converted to a measurable inequality ("feels fast" → "cold-load DOM < 2s, 0 MB media at load — measured in report") | subjective wishes left unmeasured |
| 7 | **Independence from user** | Zero items blocked on user decisions; leftovers moved to "decide before launching"; EXCEPTION: a §DAL-C terminal HOLD is a legitimate terminal state, not a blocking dependency | "user will explain X later" inside the goal |
| 8 | **Single-topic focus** | ≤7 major deliverables, one coherent mission | grab-bag of unrelated work (→ campaign) |
| 9 | **Char budget** | Measured in CHARACTERS, not bytes — `wc -c` counts bytes and overstates UTF-8 text (Turkish/Cyrillic ≈ +8-10%). Write the goal draft to a scratch file, then measure with THE canonical tool: `scripts/ledger.sh measure <draft-file>` (UTF-8-locale-enforced wc -m, trailing newlines stripped, method-labeled output; guards the C-locale byte trap). Cross-check (MUST agree — trailing-newline-only scope): `python3 -c "import sys; print(len(sys.stdin.read().rstrip('\n')))" < <file>` (rstrip, NOT strip: leading newlines are content). Ideal band 3000-4000 chars (hard limit 4000); report the goal text's own count, never the surrounding explanation's | >4000 chars, unverified, or byte-count presented as char-count |
| 10 | **Tribunal + Ledger integrity** | Full v5 protocol: COMPLETION GATE before any jury (done-claim → all mechanical checks re-run in one pass, raw outputs to ledger) + GUARDRAILS.md read at compile + PLAN.md-first rule for ≥25-turn budgets + 3 METHOD-diverse jurors (re-runner / ledger-auditor / constraint-warden) with tool access + prosecutor (self-audit; heavy adds independent subagent) + Evidence Ledger clause (raw blocks, hash chain) + Goodhart dual sign-off (proxy ✓ AND intent ✓) + reopen clause + deficiency-list-only fixes + 3-strikes BLOCKED valve + unanimity sentence (LIGHT-MODE carve-out: goals ≤3 deliverables AND ≤15 turns may use TEMPLATE §Light mode — one tool-equipped auditor covering all three methods + self-audit prosecutor; ledger/gate/archive NEVER lightened; forbidden for ≥25-turn budgets) + skeleton v2 structure: two layers (worker/evaluator) with <condition>, <evidence-map>, <anti-accept> slots — anti-accept lists BEHAVIOR patterns, counts use range tokens (D1-D<n>) | missing/weakened protocol, identical or text-only jurors, no ledger, no reopen clause, single-layer skeleton on a new compile |

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
