---
name: goal-forge
description: Compiles evidence-based /goal contracts (and /loop recipes) with a tamper-evident Ledger and an adversarial Tribunal as the completion condition. Use when the user says "goal yaz", "goal-forge", "loop-forge", "loop yaz", "write a goal", "prepare a /goal", asks goal-vs-loop, or wants a campaign split.
---

# Goal Forge 2.1 — a compiler for autonomous goals

The /goal evaluator (small, fast) reads ONLY the transcript, runs no tools.
Invariants: **(a) every deliverable carries transcript-visible evidence, (b)
raw evidence accumulates in a tamper-evident Ledger, (c) the stop condition
is a Tribunal verdict the evaluator can trivially check.**
THIS FILE's own budget: ≤8000 chars by `scripts/ledger.sh measure SKILL.md`,
AND it must remain an honest summary of every load-bearing TEMPLATE mechanism.
Chars — not lines — are the metric (a 97-line freeze once Goodharted itself:
lines held, density and cost grew).
This file SUMMARIZES and POINTS; the canonical normative text lives in
TEMPLATE.md / LINT.md / RECIPES.md — on any conflict, TEMPLATE.md wins.
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
scan:
1 **Mission** (scanned default) · 2 **Scope** (multi-select from lifecycle;
add a research item when §1 flagged a gap) · 3 **MUST-NOTs** ·
4 **Evidence level** (live+measurements / live / local) ·
5 **Turn budget** (formula: [LINT.md](LINT.md) #5) ·
6 **Tribunal** — strictness (standard / heavy +prosecutor / light) AND
models: prosecutor **Fable or Opus**; jurors **Opus/Sonnet/Haiku** mix
(haiku=checklist-proven cheap-lane; opus for hardest verify; default sonnet) ·
7 **Tech/Approach** — fires per the CAPABILITY rule in
[STACKS.md](STACKS.md) §Firing; "research decides" → stack-bakeoff (RECIPES)
+ roadmap PLAN (TEMPLATE §Roadmap).
Consequential goals declare KILL-CRITERIA + 1-line PREMORTEM at compile (TEMPLATE; light-mode may skip). Future-user-input items: EXCLUDED → decide-list. A pre-filled confirm is
required EVEN WHEN answers are derivable from context; sole exception: the
user explicitly enumerated the params in-session AND you say so in the report.

## 3. Compile from template
Fill the v2 two-layer skeleton in [TEMPLATE.md](TEMPLATE.md): metadata line +
short DONE-MEANS pointer → WORKER layer (MISSION · □ D# tasks with inline
evidence from [RECIPES.md](RECIPES.md) · FORBIDDEN · ASSUMPTION · LEDGER ·
PROCESS · SAFETY with the **regime band**: below 30% of budget, verification+
closure only) → EVALUATOR layer (<condition> — Goodhart inequality inside,
only when not derivable from D-items · <evidence-map> D#↔E-D# ·
<anti-accept> behavior patterns).
TYPE each □ D# at compile: **[M]achine** (evidence closes on exit-code /
hash / diff / count alone) or **[J]udgment** (needs semantic assessment) —
the type drives Tribunal effort routing (§5) and the G=1 fast path.
An irreversible agent-unauthorized action → **§RED-HOLD**: ledger names the action + exact user command, agent STOPS once (legitimate terminal state, not a waiting defect).
Machine-greppable keys are ASCII-canon (RECIPES §Notation).

## 4. Evidence Ledger (during execution)
The compiled goal appends every load-bearing raw output (command + stdout) to an
append-only ledger via `scripts/ledger.sh append/verify` — sha256 chain, FULL
entry text stored so jurors recompute from GENESIS.
If a file changes after its entry, append a superseding entry with fresh
measurements — never let a stale entry pose as current. Summaries never
replace raw blocks — the Tribunal audits the ledger, not the narrative.
`ledger.sh coverage <ledger> <n>` is the COMPLETION GATE's presence check:
every D1..D# must be ledgered before any jury convenes (partial coverage
cannot reach the jury). Format + hash + rules: [TEMPLATE.md](TEMPLATE.md)
§Ledger.

## 5. Tribunal (the stop condition)
Three jurors diversified by VERIFICATION METHOD, not count (correlated panels
collapse to ~2 effective votes — literature-backed): **J1 Re-runner** ·
**J2 Ledger Auditor** (recomputes the chain from GENESIS; broken chain or
unproven claim = REJECT) · **J3 Constraint Warden** (MUST-NOTs + **Goodhart
dual sign-off**: proxy ✓ AND intent ✓). Full briefs, isolation and verdict
format: [TEMPLATE.md](TEMPLATE.md) (canonical).
EFFORT ROUTING by D# type (§3): J1/J2 default to the **haiku checklist lane**
on [M]-typed items (numbered-command brief); prosecutor +
J3 spend sonnet/opus ONLY on the [J]udgment surface. Routing changes cost,
NEVER method count — the 3-method invariant is untouchable.
**G=1 fast path:** a goal whose D# are ALL [M]-typed may use TEMPLATE §Light
(one tool-equipped auditor covering all three methods) up to 5 items and
≤15 turns; evidence/ledger/gate are never lightened.
Order: COMPLETION GATE (all mechanical checks re-run in one pass +
`ledger.sh coverage` + `verify`; any failure = no jury) → prosecutor
(self-audit; heavy adds an independent subagent; S#↔E-S# closures) → jurors.
ANTI-FABRICATION TEETH (TEMPLATE <anti-accept>): a juror verdict with no
preceding Agent-tool subagent block = **fabricated jury**; a verdict lacking
an adjacent cited E-D#/hash/machine-assertion = **unanchored verdict**;
re-spawning a juror role that REJECTED, without a ledgered deficiency-closure
entry in between = **jury-shopping** — each alone voids DONE.
On REJECT: reasoned deficiency list; close ONLY that list. **Reopen clause:**
no juror may defend a prior verdict against irrefutable new evidence.
3 consecutive rejections → BLOCKED, handed to the user. Crashed juror →
relaunch ONCE, then report; the worker NEVER simulates its own jury
(TEMPLATE §Fallback).
The final report carries exactly ONE `STOP_REASON: <T>` token (closed set, TEMPLATE
§SAFETY); **TRIBUNAL-UNANIMOUS is the sole done-token**.
Stop sentence: "Do not stop until the Tribunal's UNANIMOUS verdict and the
per-item evidence ledger appear in the final report."

## 6. Lint, archive, deliver
Score against [LINT.md](LINT.md) (/100, threshold 80; turn estimate #5).
**HARD FLOORS (veto):** #2 and #10 each ≥8 AND no criterion <5 — a ≥80 total
with a gutted floor is a FALSE PASS (LINT header).
Char check in CHARACTERS (LINT #9; `ledger.sh measure`): hard 4000, ideal
3000-4000; report the goal text's own count — never cut Tribunal/valve.
Archive contract+goal+score to `goals/goal-<date>-<slug>.md` (TEMPLATE
§Archive) INCLUDING the **human-mirror**: a plain-language twin
so the operator can review what they paste.
Deliver ready-to-paste ` /goal ... ` + scorecard + decide-before-launch list
+ a ≤5-line plain summary AND a term legend (§Plain-delivery); report opens with a plain Result (§Plain-report). Present finished.

Anti-patterns (never emit): subjective finish lines · future-user-input
items (except a §RED-HOLD) · off-transcript evidence ·
summaries-as-evidence · no turn cap · one giant item · Goodhart traps ·
8+ items (→campaign) · jury growth · jury-shopping.
