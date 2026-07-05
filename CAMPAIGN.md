# Campaign Mode & Loop Bridge

## When a single goal is not the right tool

| Signal | Tool |
|---|---|
| Finite work, definable "done", ≤7 major items | **single /goal** |
| Finite but 8+ major items or multiple phases | **campaign** (chain of goals) |
| Recurring / no natural end (watch CI, babysit PRs, nightly triage) | **/loop recipe** |
| Recurring AND each iteration has a completion bar | **loop with embedded evidence checklist** |

/goal is condition-driven ("stop when proven done"); /loop is cadence-driven
("run again on schedule"). Goal Forge engineers both.

## Campaign mode (sequential goal chain)

One /goal can be active per session, so a campaign is an ORDERED chain:
milestone N's goal ends by *staging* milestone N+1.

1. Split the mission into 2-5 milestones, each independently verifiable and
   ≤7 deliverables. Natural cut lines: core implementation → hardening →
   deploy+verification → docs+handoff.
2. Compile EACH milestone with the full pipeline (interview once; contract,
   lint, Tribunal per milestone).
3. Write the chain to `goals/campaign-<slug>.md`:
   - campaign mission + milestone table (status column: pending/active/achieved)
   - each compiled `/goal` block, ready to paste
4. Every milestone goal's final deliverable is: "update goals/campaign-<slug>.md
   status and print the NEXT milestone's /goal block in the final report" —
   so the user (or the next session) just pastes the next goal. The chain is
   self-advancing with a human click between milestones: autonomy with a
   checkpoint, by design.
5. Campaign lint extras: no milestone depends on a later one; milestone 1 is
   startable today; each Tribunal is independent. Small stones (≤3 items AND
   ≤15 turns) may run TEMPLATE §Light mode; big stones stay standard/heavy.
6. **SUFFICIENCY GATE (anti-forced-versioning)**: each milestone's research
   output is scored by an independent gate judge with the RUBRIC —
   novelty/30 + real contribution/30 + implementability/20 + testability/10
   + risk-complexity/10 (low risk = high score) — per candidate AND as a
   total list score; below the threshold (default 60) the milestone is NOOP
   — but NOOP is NOT automatically final: in the sunset branch the
   prosecutor attacks the sunset rationale; if the refutation stands, the
   gate verdict REOPENS and is revised on evidence (field precedent: v9,
   52-NOOP → appeal → 66-CONTINUE). The mandatory DAL-B prosecutor
   attack is PROCEDURE, not the appeal — the appeal right is consumed ONLY
   when a standing refutation triggers a REOPEN; a failed refutation leaves
   the NOOP final immediately. The SAME gate judge writes the revision
   (evidence-based, consistent-ruler, no candidate-bundling — v9 precedent);
   a second NOOP after a consumed appeal is final WITHIN the campaign
   (TEMPLATE's juror REOPEN RULE governs tribunal verdicts, not gate
   finality — genuinely new evidence goes to the resurrection registry, not
   a second appeal). The campaign
   status table records the full path ("52→reopen 66"). Single unstructured
   0-100 scores are not valid.
7. **v3 mechanics apply per milestone**: each milestone keeps its own Evidence
   Ledger (one `scripts/ledger.sh` file per milestone — chains don't span
   milestones), its Tribunal uses the method-diverse jurors + reopen clause
   from TEMPLATE.md, and its safety valve carries the budget regime band
   ("below 30% remaining: no new exploration"). The campaign file records each
   milestone's ledger path + final verdict in the status table, so a resumed
   session can audit the whole chain milestone by milestone.

## §Multi-day (running a campaign across days)

The continuity ladder — prefer the highest rung that fits:
1. **Same session** (machine stays on): a /goal survives screen sleep and —
   field-observed, not doc-guaranteed — context compaction; constraints can
   still silently erode, so the skeleton's PIN rule applies (TEMPLATE).
   On a Mac run `caffeinate -is` to prevent deep sleep.
   Corporate-VPN laptops: sleep drops the VPN and strands the run — prefer
   rung 2/3.
2. **Resume the session** (`/resume` in-app, or `claude --resume` /
   `--continue` from the shell — same mechanism): an active goal is restored
   automatically after the session closes; turn/time counters reset, so the
   first message back restates the remaining budget (the archive's resume
   card says exactly this).
3. **Cloud Routines (`/schedule`)**: machine-off autonomy via scheduled
   FRESH runs on Anthropic's cloud — stateless (no local files, fresh
   clone), so it fits only milestones whose state lives in the REPO
   (committed PLAN.md/ledger). Local-file campaigns stay on rungs 1-2.
MILESTONE INITIALIZER: each milestone's first message re-anchors the fresh
context — one paragraph: campaign mission, this milestone's goal, ledger
path, GUARDRAILS.md lessons, current PLAN.md state. Never assume the new
session remembers the old one.

## Loop Bridge (loop engineering)

For recurring work, emit a `/loop` recipe instead of a goal:

```
/loop <interval or blank for self-paced> <task prompt>
```

Engineer the task prompt with goal-grade discipline — this is what separates a
"loop" from a "loop that quietly rots":
- **Risk tier (declare one, first line of the recipe)** — every loop is
  classified so autonomy matches blast radius:
  · **GREEN** — reads only + writes to its own state/ledger files. Safe to run
    unattended.
  · **YELLOW** — drafts an artifact a human ships (reply, PR, page edit,
    message). The loop MUST stop at the draft; shipping is a separate human act.
  · **RED** — money, production, outbound-to-a-customer, or any irreversible
    action. A RED action NEVER runs inside the autonomous loop: the loop
    prepares it, writes a `HELD: <action> · run: <exact command>` line to its
    ledger, and STOPS for the operator. **RED ⊇ §DAL-C** — every §DAL-C
    irreversible-action HOLD is a RED action; the tier generalizes DAL-C from
    goals to loops (no contradiction: a RED loop-step is exactly a DAL-C HOLD).
  A recipe with no tier is NOT DONE; a RED action that executed inside the loop
  (not HELD) is a FORBIDDEN breach, caught by the evaluator and the round-ledger.
- **Per-iteration contract**: exactly what one iteration checks/does, with
  transcript evidence ("paste the failing job names", "report queue depth").
- **No-op discipline**: "if nothing needs doing, say NOOP + one-line status" —
  prevents invented work (the loop equivalent of scope creep).
- **Escalation rule**: "on <serious condition>, stop looping and alert the
  user with the evidence" — loops must know when to break glass.
- **Dual-condition exit lock**: exit requires BOTH a completion indicator
  (evidence contract satisfied) AND a separate `EXIT_SIGNAL: <reason>` line.
  Honest scope: both signals come from the same model, so this REDUCES
  self-graded early exits rather than eliminating them — the strong lock is
  a separate evaluator (/goal) or a human reviewing EXIT_SIGNAL. (Pattern
  from frankbria/ralph-claude-code's dual-condition exit gate.)
- **Iteration cap / sunset**: "stop after N iterations or after <date/event>"
  — default sunset 7 days, aligned with the platform's own /loop expiry.
- **Multi-day loops**: a /loop pauses when the session closes and is
  restored by `--resume` within its 7-day window (same as /goal); for
  machine-off cadences or beyond the window, use cloud Routines (§Multi-day).
- **Cadence advice**: match interval to how fast the watched thing changes;
  self-paced (no interval) lets the model choose — recommend it when change
  rate varies.
- **One change per round** (frontier-researcher discipline): each iteration
  fixes the SINGLE highest-priority thing it found, never everything at once —
  change one thing, test it, keep it only if the check improved, write it down,
  repeat. A round that touches many unrelated things is not a loop round, it is
  scope creep; the round-ledger entry names the ONE change.
- **Frozen same-check**: the iteration's success check is pinned by hash at loop
  start (`scripts/ledger.sh` records the check-spec's sha256) and re-verified
  each round. If the check itself drifts (the loop silently changing its own
  metric = Goodhart), the hash mismatches and the round HALTS with a drift
  report — this week's score stays comparable to last week's by construction.
- **Cheap-first escalation (cost routing)**: routine rounds run on the cheap
  model; the flagship is spent ONLY after a cheap-model failure is LOGGED to the
  round-ledger (a `CHEAP-FAIL: <why>` entry gates the escalation). Distinct from
  the human break-glass escalation below — this one controls the bill.
- **Round-ledger (MANDATORY, not v3-optional)**: EVERY iteration — including
  NOOP — appends one entry to the loop's `scripts/ledger.sh` chain (NOOP logs a
  `NOOP · <status>` entry, still hash-chained). The chain is the loop's
  tamper-evident state-file: `ledger.sh verify` proves the history wasn't
  rewritten across sessions (closes the session-seam hole for loops). The
  resuming session runs `verify` before its first round; a broken chain stops
  the loop and alerts the operator.
- **Reopen discipline**: a loop that flagged X as broken and later finds
  contrary evidence must revise its earlier report in the next iteration
  (same rule as the Tribunal's reopen clause — stale claims rot loops too).
- **Regime band**: within each iteration, spend at most ~70% of the effort on
  discovery; reserve the rest for verification + the iteration report.

Mini example:
```
/loop 15m Check CI on main. If red: paste failing job names + first error
lines, attempt fix ONLY for lint/flaky-test classes, push, report diff.
If green: reply NOOP + run id. Escalate & stop if the same job fails 3 runs
in a row. Sunset after 24 iterations.
```

## Hybrid: loop until a goal condition
For "keep working the queue until empty" shapes, prefer /goal with a
queue-empty end state (condition-driven beats cadence-driven when a true
"done" exists). Use a loop only if the queue refills indefinitely.
