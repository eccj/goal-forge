# Glossary — the terms you'll meet, in one line each

New here? Read this once and the compiled `/goal` blocks stop looking like code.
Everything below is plain-English; you don't need to be a developer. (This covers
the terms you'll actually run into; a goal can always coin a one-off, which its
own delivery legend explains.)

| Term | What it means (plain) |
|---|---|
| **/goal** | A finish line you write once. The AI works on its own until that line is crossed, then stops. |
| **/loop** | A job that repeats on a schedule (every morning, every new commit…) until you turn it off. |
| **goal-forge** | The tool that *writes* those /goal and /loop instructions for you, so they actually hold. |
| **D1, D2, D3… (deliverable)** | One job to finish. A goal is a short numbered list of them. |
| **E-D# (evidence)** | The proof a job is really done — a real command's output, pasted, not a "trust me". |
| **Tribunal / jury** | An AI panel that independently re-checks the work is truly finished before it's allowed to stop. It's the *checker*, never the *doer* — the model that did the work isn't the one that declares it done. |
| **Prosecutor** | An AI whose only job is to attack the work and try to prove it's NOT done. If it can't, that's a good sign. |
| **Ledger** | The proof file. Every result is recorded and chained with a fingerprint (hash), so if someone edits the past, it shows. |
| **Hash / hash-chain / sha256** | A digital fingerprint of some text ("sha256" is just the standard recipe for making one). Chaining them means you can't quietly rewrite an earlier step without breaking the chain. |
| **STOP_REASON** | One word for *why* it stopped: `TRIBUNAL-UNANIMOUS` (done & verified), `BLOCKED`, `out of turns`, etc. |
| **FORBIDDEN** | The hard "never do this" list baked into the goal (e.g. "don't touch production", "no schema changes"). |
| **§RED-HOLD** | A dangerous action — spend money, deploy to production, delete data, publish — that the AI will **not** do on its own. It stops and hands you the exact command to run. (The "red" tier of the traffic-light below. Earlier versions called this same safety-hold by a different codename.) |
| **Green / Yellow / Red (loops)** | How much a loop is allowed to do alone. **Green** = only reads. **Yellow** = drafts something *you* send. **Red** = money/production/messages — never alone, always handed to you. |
| **Turn budget** | A hard cap on how many steps (and therefore how much it can cost) the AI is allowed before it must stop. |
| **PLAN.md** | A little text file the AI keeps of what's done and what's left, so a paused run can pick up where it left off. |
| **Light / Standard / Heavy** | How strict the checking is. Small jobs get light (one checker); big ones get heavy (a prosecutor + three jurors). |
| **Campaign** | A big project split into a chain of smaller goals, done in order with a checkpoint between each. |
| **GUARDRAILS** | A running list of lessons ("we made this mistake, here's the rule") the tool applies to every new goal. |

## Words you'll see in reports and version steps

Some goals save their work with **git** (a standard tool for versioning files).
You don't operate it, but the words show up in reports:

| Term | What it means (plain) |
|---|---|
| **branch** | A separate copy of the project to work on safely, without touching the main one. New work goes on a branch first. |
| **push** | Upload that branch to the shared online copy (e.g. GitHub) so you can review it. |
| **merge** | Fold a branch's changes back into the main copy. "No merge to master" = the AI is NOT allowed to touch the main copy — it leaves the work on a branch for **you** to accept. |
| **origin / remote** | The shared online copy of the project (the "official" one), as opposed to the copy on your machine. |
| **commit** | One saved checkpoint of changes, with a note describing them. |
| **fresh clone** | Downloading a brand-new copy from scratch to prove the work isn't secretly relying on something only on this machine. |

| Internal shorthand | What it means (plain) |
|---|---|
| **[M] / [J]** | Each job is tagged: **[M]** = machine-checkable (a command's pass/fail settles it), **[J]** = needs judgment. Cheaper checkers handle [M]. |
| **PIN** | The AI re-states the key rules to itself every so often, so a long run doesn't "forget" them. |
| **GENESIS** | The very first entry in the proof file — the chain of fingerprints is recomputed from here to prove nothing was altered. |
| **S# / E-S#** | A prosecutor's finding (**S#**) and the entry that fixes it (**E-S#**) — same numbering idea as D#/E-D#. |
| **appeal-law** | In a multi-goal campaign, the rule that lets a "not worth doing" verdict be re-argued once if there's a real counter-argument. |
| **compaction** | When a long conversation is auto-summarized to save space — which is why the AI re-PINs its rules afterward. |
| **GOODHART** | The trap of hitting the number while missing the point. The checkers require *both* "metric passed" AND "intent actually met." |
| **`<condition>` / `<evidence-map>` / `<anti-accept>`** | The checklist the checker-AI reads (the code-looking tags are just labels): what counts as truly done, which proof belongs to which job, and which patterns mean the work is *faking* done. You don't write these — the compiler does. |

**The one idea behind all of it:** an AI saying "done" doesn't make it true. goal-forge
turns "done" into *proof you can read* — and a second, independent AI confirms it
before the work is allowed to stop.
