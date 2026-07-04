# Goal Skeleton + Ledger + Tribunal + Archive (1.5, full detail)

Produce the goal **in the user's language**. Ideal band 3000-4000 chars
(hard limit 4000) — measured per LINT #9.

## Skeleton (v2 "Hybrid-VC" — tournament-informed: raw VC won, the shipped hybrid restores obligations raw VC omitted; maintainer-private tournament record)

Two layers for two readers: the top addresses the WORKER agent, the bottom the
EVALUATOR (small model, transcript-only). LANGUAGE POLICY: prose and section
headings follow the user's language; the CANONICAL never-translate tokens are
the metadata keys (GF·budget·jury·ledger·label), the D#/E-D# ID scheme, and
the three XML tag names (<condition>, <evidence-map>, <anti-accept>) — tooling
parses exactly these. Goals compiled under the old single-layer skeleton
remain valid — new compiles use v2.

```
/goal [GF·<goal|milestone>·budget:<N>·jury:<std|heavy|light>·ledger:<path>·label=D#]
DONE-MEANS (summary — full definition in <condition> below): every D# item
E-D# raw-evidenced + UNANIMOUS jury verdict in the final report.

═══ WORKER LAYER ═══
MISSION: <one sentence, observable finished state>.

TASKS (evidence appended to <ledger> via scripts/ledger.sh, label=D#):
□ D1 <budget >=25 turns ALWAYS: create/update PLAN.md — state lives in the file>
  — evidence: <RECIPES method>.
□ D2 <work> — evidence: <...>.
...
FORBIDDEN: <untouchables> · <out-of-scope> · no work added outside scope.
ASSUMPTION: on ambiguity make a reasonable assumption + list it in the report;
never wait for the user.
LEDGER: raw outputs via ledger.sh append; full text stored; changed files get
a superseding entry; a summary never replaces the raw block.
PIN: in the FIRST message after compaction AND every ~10 turns, restate in one
line: active FORBIDDEN list + governing gate decision + ledger path
(compaction can silently evict in-context rules — arXiv 2606.22528;
pinning provides presence, not guaranteed compliance).
PROCESS: on a done-claim, COMPLETION GATE (all mechanical checks re-run in one
pass + ledger; any failure means no jury) → PROSECUTOR self-audit [heavy mode:
independent prosecutor subagent] → 3 jurors (tool-equipped, verify-then-
verdict): J1-Re-runner · J2-Ledger-Auditor (chain from GENESIS; D#↔E-D#) ·
J3-Constraint+Goodhart dual sign-off (proxy ✓ AND intent ✓). On REJECT only a
deficiency list; reopening is valid; "could be better" is not a REJECT;
3 rejects = BLOCKED → user.
SAFETY: <N> turns; below 30% remaining only verification+closure; if
unfinished, honest status report.

═══ EVALUATOR LAYER ═══
<condition>
DONE if and only if the transcript shows (1) an E-D#-labeled raw command+output
block for EVERY D1-D<n> item AND (2) the 3 jurors' UNANIMOUS verdict AND (3) an
item-by-item evidence dump. [Only when not derivable from D-items: "<subjective
wish>" = <measurable inequality>.] If any is missing: NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (<short>) · D2↔E-D2 (<short>) · ...
</evidence-map>
<anti-accept>
The condition is NOT met if ANY of these appear: "done/passed" claimed with no
raw output pasted · summary offered where a raw block is required · no jury
verdict or non-unanimous · a D# never mentioned · an unresolved FORBIDDEN
violation · turn cap exceeded without an honest status report.
</anti-accept>
```

Headings may follow the operator language in compiled goals (canonical
never-translate tokens: D#/E-D#/S# labels, the metadata line, XML slot names).
v2 rules (tournament + research): DONE-MEANS is a SHORT pointer, never a full
repetition of <condition> (bookending without the duplication cost) · counts
live in range tokens (D1-D<n>), never hardcoded twice · <anti-accept> lists
BEHAVIOR patterns (item-count-independent) · each □ D# line carries its
evidence method inline · the Goodhart line goes INSIDE <condition>, and only
when not derivable from the D-items.

## §Ledger — format & hash chain

Entry format (append-only; file `EVIDENCE.md` or a dedicated report section):

```
### E<seq> · <deliverable#> · <one-line label>
$ <command>
<raw stdout block>
prev: <hash of previous entry or GENESIS>
hash: <sha256(prev + entry text)>
```

Hash command: `printf '%s\n--\n%s' "<prev>" "<entry>" | shasum -a 256` — the
`\n--\n` delimiter prevents boundary ambiguity between prev and entry. The
chain makes retroactive editing detectable; recomputing it is an explicit
J2 duty (see juror prompts below). Prefer the tool over hand-rolling:
`scripts/ledger.sh append <ledger> <label> <entry-file>` computes the chain,
`scripts/ledger.sh verify <ledger>` recomputes it from GENESIS (bash+shasum
only).

Two rules learned from the v3 self-upgrade run (see
examples/case-v3-self-upgrade.md):
- **Superseding entries.** If a file changes after its ledger entry (e.g.
  post-prosecutor fixes), append a NEW entry with fresh measurements and label
  it as superseding — never edit or silently outdate an old entry. A stale
  entry that looks current reads as a contradiction and triggers a REJECT.
- **Full-text storage.** Store each entry's raw text verbatim (ledger.sh does
  this between `<<<ENTRY`/`ENTRY>>>` markers) so any juror can recompute the
  chain from GENESIS. A hash whose input text isn't stored is unverifiable —
  it proves nothing.

Guardrails: when the SAME error class bites twice — within one run OR across
runs (check the file before dismissing a pattern as new) — append a one-line
lesson to `goals/GUARDRAILS.md` ("<date> · <error class> → <rule>"). Every
goal compile and every campaign milestone starts by reading that file —
lessons must be operational, not archaeological. On first run, create
goals/GUARDRAILS.md in your own project — nothing ships pre-populated.

Honest scope: the chain is tamper-evident against IN-PLACE edits of a ledger
you already hold — it is keyless, so a from-scratch re-forge with altered
evidence verifies clean. What defeats re-forging is the Tribunal re-running
commands against reality (J1) and cross-checking the transcript (J2); the
chain is an audit aid, not cryptographic authentication. Say no more than this
when describing it.

## §Juror prompt core (Agent tool; MODEL per interview Q6 — opus/sonnet/haiku; haiku REQUIRES checklist-format briefs; default sonnet; tools ON)

> You are juror J<x>; your VERIFICATION METHOD is ONE of:
> (a) re-run checks independently; or (b) audit ledger quotes against real
> files & outputs AND recompute the sha256 hash chain — a broken or
> unrecomputable chain is itself a REJECT finding; or (c) guard constraints +
> Goodhart dual sign-off. Verify before you judge — re-execute what you can; accept no
> claim without shown or reproduced evidence. Search for MEANING, not
> keywords: the absence of a literal word is not the absence of the mechanism
> — if a grep returns empty, READ the content before ruling (a keyword-only
> check produced a false REJECT in the v6 run — J1/Goodhart case). Verdict: APPROVE or REJECT + an
> itemized, reasoned deficiency list. Be conservative, but accept evidence you
> cannot refute; "could be better" alone is NOT grounds for rejection (add
> out-of-scope suggestions as notes). Judge evidence by MECHANICAL criteria,
> independent of its language — content, not style: multilingual judges
> measurably over-score fluent prose (documented bias; our evidence is often
> Turkish). REOPEN RULE: if new irrefutable evidence
> contradicts your earlier verdict, you must revise it — defending a stale
> verdict is a protocol violation, revision is not. (Field-proven: in the v3
> self-upgrade run a juror's partial REJECT was correctly reversed once raw
> evidence and a recomputable hash chain were re-presented.)

Prosecutor (heavy mode) prompt core: "Actively try to refute this work: hunt
missing evidence, untested paths, constraint violations, proxy-gaming. Number
your findings S1, S2, … — closures will be ledgered as E-S# entries. Return
an attack list; do not judge — attack. Attack content, not style — judge
evidence language-independently (multilingual style bias is documented)."

FALLBACK RULE (referenced as SKILL "TEMPLATE Fallback") (evaluator availability): if a prosecutor/juror/gate-judge agent
fails to spawn, stalls, or dies (network drop, watchdog kill), relaunch it
ONCE with the same prompt. If it fails again: report the outage to the user
and STOP that verdict — the worker may NEVER simulate a missing juror itself
(self-simulation voids independence and the whole protocol with it).
Field-validated: a network drop killed all three tournament judges in the v6
run; they were relaunched with identical prompts (recorded in
the maintainer-private tournament record §Incident).

## §Roadmap (stack-choice compiles only)
When interview Q7 fired, the compiled D1-PLAN must be PHASE-ordered:
skeleton (stack boots, hello-render) → core (main features) → polish
(animation/UX pass) → live verification; each phase closes with evidence
before the next opens — prevents "everything half-built" drift.

## §Light mode (small goals only: ≤3 deliverables AND ≤15 turns — NEVER ≥25)
What REMAINS: Evidence Ledger (ledger.sh) + COMPLETION GATE + archive+METRICS
row. What changes: independent prosecutor → prosecutor SELF-audit only;
3 jurors → ONE tool-equipped auditor who applies all three methods himself
(re-runs checks, recomputes the chain, guards constraints + Goodhart dual
sign-off); unanimity sentence → "single auditor APPROVE". Evidence discipline
is never lightened — only the number of independent agents is. Budget is
FIXED N=15 (LINT #5's 20-floor is waived for light — documented exception).
REJECTs count PER ITEM and the strike counter CARRIES OVER on escalation
(never resets): two REJECTs on one item → escalate to standard mode; the
global 3-strikes BLOCKED valve still caps the same item at three total.

## §Archive — goals/goal-<date>-<slug>.md template + resume card

```
# Goal: <slug>   ·   status: active | achieved | stopped
Compiled: <date> · Mode: <goal/campaign/loop> · Tribunal: <standard/heavy/light>
Score: <GQS>/100 · Chars: <n> · Turn budget: <N>

## Contract (interview answers)
Mission: ... · Scope: ... · MUST-NOTs: ... · Evidence level: ...

## Compiled goal
<the exact /goal text>

## RESUME CARD (use after a crash/disconnect)
1. If the session is still open, do nothing — the goal is alive (survives
   sleep; also survived compaction in our field runs, though docs don't
   guarantee it — and surviving ≠ constraints retained: see the PIN rule). If it closed: resume the session — `/resume` inside Claude
   Code or `claude --resume`/`--continue` from the shell (same mechanism) —
   and an active goal is restored AUTOMATICALLY; turn/time counters AND the
   token-spend baseline reset, so restate the remaining budget explicitly.
2. Only if you must start a FRESH session: paste the "Compiled goal" block
   above into /goal.
3. Either way, tell the agent: "Resume from goals/<this file>; the Evidence
   Ledger is at <path>; continue from the first deliverable lacking ledger
   evidence."

## Outcome (fill at close)
Verdict: ... · Turns used: ~N/M (%x) ← ONE LINE, exactly this format
(LINT #5 machine-reads it; a wrapped line once broke a measurement — v6 case) ·
Ledger entries: ... · Lessons: ...
[MANDATORY: at close append one row to goals/METRICS.md (prosecutor findings ·
jury REJECT→reopen · open S# · NOOP · turn %) — an archive without its METRICS
row is incomplete.]
```

## Evidence-writing guide (visible-work principle)
The evaluator and jurors see only the transcript/ledger, so phrase evidence
as: pasted command output (exit codes visible), live URL checks with raw
headers, measurements as numbers, screenshots taken AND assessed in writing,
research as ≥N independent source URLs + a findings summary. "CI is green" is
INSUFFICIENT — paste the output itself. Full per-type recipes: RECIPES.md.

## Big-project rule
Never cram 8+ major items into one goal — build a campaign (CAMPAIGN.md).
Single-topic goals finish reliably.

## Character budget
Worker layer ~65% · evaluator layer ~25% · reserve ~10%. Verify in
CHARACTERS (LINT #9 method — never `wc -c` bytes); if over 4000, shorten
evidence phrasing first — never cut the Ledger/Tribunal below their
invariants.
