---
name: goal-forge
description: Compiles bulletproof /goal prompts (and /loop recipes) for finishing any project A-to-Z — interviews the user, lints against 10 quality criteria, and installs an evidence-based jury ("Tribunal") with a tamper-evident Evidence Ledger as the completion condition, within the 4000-char limit. Use when user says "goal yaz", "goal-forge", "loop-forge", "prepare a /goal", "loop yaz", "write a goal", "make this a goal/loop", wants a completion condition for /goal, an engineered /loop recipe, asks goal-vs-loop, or wants a big project split into sequential goals (campaign).
---

# Goal Forge 1.6 — a compiler for autonomous goals

The /goal evaluator (small, fast) reads ONLY the transcript, runs no tools.
Invariants: **(a) every deliverable carries transcript-visible evidence, (b)
raw evidence accumulates in a tamper-evident Ledger, (c) the stop condition
is a Tribunal verdict the evaluator can trivially check.**
Pipeline: intent → interview → contract → lint → compiled /goal (+archive)

## 0. Mode selection (goal vs loop vs campaign)
Definable "done" → **single goal**; recurring/monitoring → **loop recipe**;
8+ items → **campaign** ([CAMPAIGN.md](CAMPAIGN.md)). State choice + why.
USER OVERRIDE: an explicitly named mode wins; note a poor fit in one line.

## 1. Scan the project (fuel for the interview)
Read README, manifests, dir tree, last ~10 commits, TODOs, test/deploy state,
conversation history, and `goals/GUARDRAILS.md` (living lessons — APPLY them,
don't just archive them). Build a lifecycle checklist (research → implement →
test → perf → security basics → docs → deploy → live verification).
KNOWLEDGE-GAP: staleness-prone ground? → RESEARCH deliverable, ≥N live URLs
+ findings ([RECIPES.md](RECIPES.md)).
COLD START: fresh session → scan is the only context; if empty, open with
"Describe the project and the finish line in 2-3 sentences" (replaces scan).
Never present empty/generic options; at most ONE clarifying sentence.

## 2. Interview (MANDATORY — in the user's language)
Ask all at once (AskUserQuestion if available), options pre-filled from the
scan: 1 **Mission** (scanned default) · 2 **Scope** (multi-select from
lifecycle; add a research item when §1 flagged a gap) · 3 **MUST-NOTs** ·
4 **Evidence level** (live+measurements / live / local) · 5 **Turn budget**
(formula: [LINT.md](LINT.md) #5) · 6 **Tribunal** — strictness (standard /
heavy +prosecutor / light) AND models: prosecutor **Fable or Opus** (Fable is
not always available/affordable); jurors **Opus/Sonnet/Haiku** mix (haiku is
checklist-proven n=3 — cheap lane; opus for the hardest verify; default
sonnet) · 7 **Tech/Approach** — fires per the
CAPABILITY-level rule in [STACKS.md](STACKS.md) §Firing (capability/project
greenfield or migration-core; named-tech→confirm-not-ask; headless→research-
default); "research decides"→stack-bakeoff (RECIPES) + roadmap PLAN
(TEMPLATE §Roadmap). Future-user-input items: EXCLUDED → decide-list. A pre-filled confirm is required EVEN WHEN answers are derivable from context; sole exception: the user explicitly enumerated the params in-session AND you say so in the report.

## 3. Compile from template
Fill the v2 two-layer skeleton in [TEMPLATE.md](TEMPLATE.md): metadata line +
short DONE-MEANS pointer → WORKER layer (MISSION · □ D# tasks with inline
evidence from [RECIPES.md](RECIPES.md) · FORBIDDEN · ASSUMPTION · LEDGER · PROCESS ·
SAFETY with the **regime band**: below 30% of budget, verification+closure
only) → EVALUATOR layer (<condition> — Goodhart inequality inside, only when
not derivable from D-items · <evidence-map> D#↔E-D# · <anti-accept> behavior
patterns). Notation rules: [RECIPES.md](RECIPES.md) §Notation.

## 4. Evidence Ledger (during execution)
The compiled goal instructs the executing agent to append every load-bearing
raw output (command + stdout block) to an append-only ledger as it happens —
preferably via `scripts/ledger.sh append/verify`, which computes the sha256
chain and stores each entry's FULL text so jurors can recompute from GENESIS.
If a file changes after its entry, append a superseding entry with fresh
measurements — never let a stale entry pose as current. Summaries never
replace raw blocks — the Tribunal audits the ledger, not the narrative
(format + hash command + both rules: [TEMPLATE.md](TEMPLATE.md) §Ledger).

## 5. Tribunal (the stop condition)
Three jurors diversified by VERIFICATION METHOD, not count (panels of
correlated jurors collapse to ~2 effective votes — literature-backed):
**J1 Re-runner** (independently re-executes checks: wc/lint/curl/tests) ·
**J2 Ledger Auditor** (quoted evidence must match actual files/outputs
verbatim; recomputes the hash chain — broken chain or unproven claim =
REJECT) · **J3 Constraint Warden** (MUST-NOTs intact; **Goodhart dual
sign-off**: "proxy ✓" AND "intent ✓" both required). Jurors are subagents
(model per Q6: opus/sonnet/haiku) — verify-then-verdict, never text-only.
Order: COMPLETION GATE (worker re-runs all mechanical checks — cheap
breakage-catch) → prosecutor self-audit (heavy mode adds an independent
subagent) → jurors; J1 re-runs the same checks INDEPENDENTLY (deception-
catch — different purpose, not redundancy). On REJECT: reasoned deficiency
list; close ONLY that list. **Reopen clause: no juror
may defend a prior verdict against irrefutable new evidence — revision is
protocol, not failure.** An item rejected 3 consecutive times is reported
BLOCKED and handed to the user — deadlock is impossible. Crashed juror →
relaunch ONCE, then report; the worker NEVER simulates its own jury
(TEMPLATE §Fallback). Small goals (≤3 items AND ≤15 turns): TEMPLATE
§Light mode — one auditor, evidence never lightened. Stop sentence: "Do
not stop until the Tribunal's UNANIMOUS verdict and the per-item evidence
ledger appear in the final report." Juror prompts: [TEMPLATE.md](TEMPLATE.md).

## 6. Lint, archive, deliver
Score against [LINT.md](LINT.md) (/100, threshold 80; turn estimate #5).
Char check in CHARACTERS (LINT #9; `ledger.sh measure`): hard 4000, ideal
3000-4000; report the goal text's own count — never cut Tribunal/valve.
Archive contract+goal+score to `goals/goal-<date>-<slug>.md` (TEMPLATE
§Archive, resume card included). Deliver ready-to-paste ` /goal ... ` +
scorecard + decide-before-launch list. Present finished; don't ask.

Anti-patterns (never emit): subjective finish lines · future-user-input
items (except a §DAL-C terminal HOLD) · off-transcript evidence · summaries-as-evidence · no turn cap · one
giant item · Goodhart traps · 8+ items (→campaign) · jury growth.
