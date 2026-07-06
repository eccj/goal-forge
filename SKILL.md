---
name: goal-forge
description: Compiles evidence-based /goal contracts (and /loop recipes) with a tamper-evident Ledger and an adversarial Tribunal as the completion condition. Use when the user says "goal yaz", "goal-forge", "loop-forge", "loop yaz", "write a goal", "prepare a /goal", asks goal-vs-loop, or wants a campaign split.
---

# Goal Forge 3.1 — a compiler for autonomous goals

The /goal evaluator (small, fast) reads ONLY the transcript, runs no tools.
Invariants: **(a) every deliverable carries transcript-visible evidence, (b)
raw evidence accumulates in a tamper-evident Ledger, (c) the stop condition
is a Tribunal verdict the evaluator can trivially check.**
THIS FILE's budget: ≤8000 chars (`ledger.sh measure` — the canonical metric)
AND an honest summary of every load-bearing TEMPLATE mechanism.
This file SUMMARIZES and POINTS; canonical text: TEMPLATE.md / LINT.md /
RECIPES.md — on conflict TEMPLATE.md wins.
Pipeline: intent → interview → contract → lint → compiled /goal (+archive)

## 0. Mode selection (goal vs loop vs campaign)
Definable "done" → **single goal**; recurring/monitoring → **loop recipe**;
8+ items → **campaign** ([CAMPAIGN.md](CAMPAIGN.md)). State choice+why;
USER OVERRIDE: a named mode wins (note a poor fit in one line).

## 1. Scan the project (fuel for the interview)
Read README, manifests, dir tree, last ~10 commits, TODOs, test/deploy state,
conversation history. Build a lifecycle checklist (research → implement →
test → perf → security → docs → deploy → live verification).
KNOWLEDGE-GAP: staleness-prone ground? → RESEARCH deliverable, ≥N live URLs
+ findings ([RECIPES.md](RECIPES.md)).
COLD START: empty scan → open with "Describe the project and the finish line
in 2-3 sentences". Never present empty/generic options.

## 2. Interview (MANDATORY in EVERY case — user's language)
PRECONDITION (mechanical): `cat goals/GUARDRAILS.md` +
`scripts/retro.sh check goals/RETRO-LOG.md .` (v3.1 seal-range revert/amend
scan; warning→lesson-candidate; SEAL tarafı: TEMPLATE §Post-mortem);
delivery must carry a "GUARDRAILS uygulandı: <dersler|hiçbiri+neden>" line
(TEMPLATE §Post-mortem) — no line = invalid delivery.
The interview fires in EVERY condition; ONLY skip: the user's explicit
"röportajsız" — the enumerated-params exception is REVOKED (drifted 3×).
ROUND 1 (AskUserQuestion, pre-filled from scan): 1 **Mission** · 2 **Scope**
(multi-select; add research item on §1 gap) · 3 **MUST-NOTs** · 4 **Evidence
level** (live+measurements/live/local) · 5 **Turn budget** (LINT #5) ·
6 **Tribunal** — strictness AND models PER-ROLE, asked INDIVIDUALLY:
prosecutor (Fable/Opus), then J1, J2, J3 each (Opus/Sonnet; Haiku only on the
user's explicit pick) · 7 **Tech/Approach** ([STACKS.md](STACKS.md) §Firing;
"research decides" → stack-bakeoff + roadmap PLAN).
ADAPTIVE DEPTH: if round-1 answers leave design-driving unknowns (new
product / broad domain — "mobil app" → platform/offline/data/auth), run
answer-derived follow-up rounds, ≤3, one theme per round, until the remaining
unknowns are assumption-safe; simple goals stay SINGLE-round (bureaucracy ban).
Consequential goals declare KILL-CRITERIA + 1-line PREMORTEM (light may skip).
Future-user-input items: EXCLUDED → decide-list.

## 3. Compile from template
Fill the v2 two-layer skeleton in [TEMPLATE.md](TEMPLATE.md): metadata line +
short DONE-MEANS pointer → WORKER layer (MISSION · □ D# tasks with inline
evidence from [RECIPES.md](RECIPES.md) · FORBIDDEN · ASSUMPTION · LEDGER ·
PROCESS · SAFETY (**regime band**: last 30% = verification+closure only))
→ EVALUATOR layer (<condition> — Goodhart inequality inside,
only when not derivable from D-items · <evidence-map> D#↔E-D# ·
<anti-accept> behavior patterns).
TYPE each □ D#: **[M]achine** (closes on exit-code/hash/diff/count) or
**[J]udgment** (semantic) — drives effort routing (§5) and the G=1 fast path.
An irreversible agent-unauthorized action → **§RED-HOLD**: ledger names the
action + exact user command, agent STOPS once (legitimate terminal state).
Machine-greppable keys are ASCII-canon (RECIPES §Notation).

## 4. Evidence Ledger (during execution)
The compiled goal appends every load-bearing raw output (command + stdout) to an
append-only ledger via `scripts/ledger.sh append/verify` — sha256 chain, FULL
entry text stored so jurors recompute from GENESIS.
A changed file gets a superseding entry — stale data never poses as current.
Summaries never replace raw blocks — the Tribunal audits the ledger, not the
narrative. `ledger.sh coverage <ledger> <n>` is the COMPLETION GATE's presence
check: every D1..D# ledgered before any jury. Format: [TEMPLATE.md](TEMPLATE.md)
§Ledger. `state.sh update` regenerates goals/STATE.md at every milestone (live
progress: items-done/ledger-count/last-evidence; script-made, not hand-edited).

## 5. Tribunal (the stop condition)
Three jurors diversified by VERIFICATION METHOD, not count (correlated
panels collapse — literature-backed): **J1 Re-runner** ·
**J2 Ledger Auditor** (recomputes the chain from GENESIS; broken chain or
unproven claim = REJECT) · **J3 Constraint Warden** (MUST-NOTs + **Goodhart
dual sign-off**: proxy ✓ AND intent ✓). Briefs/verdict format:
[TEMPLATE.md](TEMPLATE.md) (canonical).
EFFORT ROUTING (§3 types): J1/J2 take the haiku checklist lane on [M] items;
prosecutor+J3 spend sonnet/opus only on the [J] surface. Routing changes COST,
NEVER method count — the 3-method invariant is untouchable.
**G=1:** ALL-[M] goals may use TEMPLATE §Light (one auditor, 3 methods)
up to 5 items & ≤15 turns; evidence/ledger/gate never lighten.
Order: COMPLETION GATE (mechanical checks re-run +
`ledger.sh coverage` + `verify` + xref-test (skill-dev); failure = no jury) → prosecutor
(self-audit; heavy adds an independent subagent; S#↔E-S# closures) → jurors.
ANTI-FABRICATION (TEMPLATE <anti-accept>): verdict without a preceding
Agent-tool block = **fabricated jury**; without an adjacent E-D#/hash citation
= **unanchored**; re-spawning a REJECTing juror without a ledgered closure =
**jury-shopping** — each voids DONE.
Verdicts carry anchored-discrete CONFIDENCE 0/25/50/75/100 (APPROVE≥75,
REJECT≤50 — TEMPLATE §Juror).
On REJECT: reasoned deficiency list; close ONLY that list. **Reopen clause:**
no juror may defend a prior verdict against irrefutable new evidence.
A 2nd consecutive REJECT on the SAME item forces a ledgered ROOT-CAUSE entry
before retry (TEMPLATE §Root-cause); 3 consecutive → BLOCKED, handed to
the user. Crashed juror →
relaunch ONCE, then report; the worker NEVER simulates its own jury
(TEMPLATE §Fallback).
The final report carries exactly ONE `STOP_REASON: <T>` token (closed set, TEMPLATE
§SAFETY); **TRIBUNAL-UNANIMOUS is the sole done-token**.
Stop sentence: "Do not stop until the Tribunal's UNANIMOUS verdict and the
per-item evidence ledger appear in the final report."

## 6. Lint, archive, deliver
Score with `scripts/lint.sh <draft>` (script-made NUMBER — mechanical subset
of [LINT.md](LINT.md), /100, threshold 80, placeholder→cap-79; semantics stay
a manual overlay; turn estimate LINT #5).
**HARD FLOORS (veto):** LINT #2/#10 each ≥8 AND none <5.
Char band (lint.sh A): hard 4000, ideal 3000-4000 — never cut Tribunal/valve.
TOKEN-RAPORU: at arming run `tokens.sh mark`; the final report ENDS
with raw `tokens.sh report` output — TOTAL then per-model $ (subagents incl.;
TEMPLATE §Plain-report).
Archive contract+goal+score to `goals/goal-<date>-<slug>.md` (TEMPLATE
§Archive) INCLUDING the **human-mirror** (plain-language twin).
Deliver ready-to-paste ` /goal ... ` + scorecard + decide-before-launch list
+ a ≤5-line plain summary AND a term legend (§Plain-delivery); report opens with a plain Result (§Plain-report). Present finished.

Anti-patterns (never emit): subjective finish lines · future-user-input
items (except a §RED-HOLD) · off-transcript evidence ·
summaries-as-evidence · no turn cap · one giant item · Goodhart traps ·
8+ items (→campaign) · jury growth · jury-shopping.
