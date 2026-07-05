# Glossary — every goal-forge term in one line

New here? Read this once and the compiled `/goal` blocks stop looking like code.
Everything below is plain-English; you don't need to be a developer.

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
| **Hash / hash-chain** | A digital fingerprint. Chaining them means you can't quietly rewrite an earlier step without breaking the chain. |
| **STOP_REASON** | One word for *why* it stopped: `TRIBUNAL-UNANIMOUS` (done & verified), `BLOCKED`, `out of turns`, etc. |
| **FORBIDDEN** | The hard "never do this" list baked into the goal (e.g. "don't touch production", "no schema changes"). |
| **§RED-HOLD** | A dangerous action — spend money, deploy to production, delete data, publish — that the AI will **not** do on its own. It stops and hands you the exact command to run. (The "red" tier of the traffic-light below.) |
| **Green / Yellow / Red (loops)** | How much a loop is allowed to do alone. **Green** = only reads. **Yellow** = drafts something *you* send. **Red** = money/production/messages — never alone, always handed to you. |
| **Turn budget** | A hard cap on how many steps (and therefore how much it can cost) the AI is allowed before it must stop. |
| **PLAN.md** | A little text file the AI keeps of what's done and what's left, so a paused run can pick up where it left off. |
| **Light / Standard / Heavy** | How strict the checking is. Small jobs get light (one checker); big ones get heavy (a prosecutor + three jurors). |
| **Campaign** | A big project split into a chain of smaller goals, done in order with a checkpoint between each. |
| **GUARDRAILS** | A running list of lessons ("we made this mistake, here's the rule") the tool applies to every new goal. |

**The one idea behind all of it:** an AI saying "done" doesn't make it true. goal-forge
turns "done" into *proof you can read* — and a second, independent AI confirms it
before the work is allowed to stop.
