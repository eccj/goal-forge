# Goal Forge — 5-Minute Quickstart

Goal Forge compiles your task into a `/goal` contract that CANNOT be silently
"done": every deliverable needs raw evidence in a hash-chained ledger, and an
adversarial tribunal (prosecutor + 3 method-diverse jurors) must unanimously
approve before the agent may stop.

## Install
Copy this folder to `~/.claude/skills/goal-forge/`. No dependencies beyond
bash + shasum (built into macOS/Linux). Verify: `bash scripts/ledger.sh` →
usage line.

## Your first goal (5 minutes)
1. In Claude Code, describe your task and say **"write a goal"** (any language works).
2. Answer up to 7 interview questions (greenfield builds also get the tech-stack question) (mission, scope, must-nots, evidence
   level, turn budget, tribunal strictness). Defaults are pre-filled from a
   project scan — accepting them is fine.
3. You get a ready-to-paste `/goal ...` block (always ≤4000 chars, measured
   by `scripts/ledger.sh measure`). Paste it. Done — the agent now works
   under the contract and cannot stop without the tribunal's verdict.

## What you'll see during a run
- `goals/EVIDENCE-*.md` fills with hash-chained raw command outputs.
- On "done": completion gate → prosecutor findings (S1..Sn) → each closed
  with evidence → 3 jurors re-run checks themselves → unanimous verdict →
  archive + one telemetry row in `goals/METRICS.md`.

## Small task? Light mode
≤3 deliverables (or ≤5 when every deliverable is machine-decidable) AND ≤15 turns → one tool-equipped auditor replaces the
3-juror panel. Ledger, gate and archive are never lightened.

## Worked example
> "write a goal: add OG share-preview tags to the pitch page, live-verified"
Pick evidence level "live" in the interview; paste the compiled block into
`/goal`. The run produces a hash-chained mini-ledger + one auditor verdict.

## Where things live
See the file map in [README.md](README.md). Rules the compiler enforces:
[LINT.md](LINT.md) · skeleton: [TEMPLATE.md](TEMPLATE.md) · evidence recipes:
[RECIPES.md](RECIPES.md) · multi-goal chains: [CAMPAIGN.md](CAMPAIGN.md).
