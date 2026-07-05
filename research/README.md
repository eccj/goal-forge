# goal-forge · Development Intelligence Archive

Durable home for the research, audits, and multi-agent sweeps that drove goal-forge
1.6 → 1.7 → 1.8 and scoped v1.9. Everything here is either command-verified against
the skill or cited to a fetched source; honest limits are stated, not hidden.

## The roadmap artifacts (the readable synthesis)

Two self-contained HTML pages synthesize **every sweep below** into one visual brief
(guarantee audit · gap register · v1.8 patch set · language decision · v1.9 backlog ·
prior art · R&D convergence). Open the local files directly, or the live versions:

| | Local file | Published (claude.ai) |
|---|---|---|
| 🇬🇧 English | [`roadmap-en.html`](roadmap-en.html) | https://claude.ai/code/artifact/ec3a3dc0-3e4f-4a06-bb13-7e5697d66ff0 |
| 🇹🇷 Türkçe | [`roadmap-tr.html`](roadmap-tr.html) | https://claude.ai/code/artifact/a978fe88-24e4-491b-917c-b9434e9be73f |

## The sweeps (11 swarms, ~185 opus/sonnet agents)

Each was an independent fan-out of agents (mostly opus for reasoning, sonnet for
mechanical checks). Findings that survived adversarial verification fed the roadmap.

| Sweep | Agents | Key finding |
|---|--:|---|
| **Gap-hunt** | 10 | 117 findings → 3 real *blockers*: worker self-reports the jury · LINT had no hard floor · anchored-verdict lacked teeth. **All 3 fixed in 1.8.** |
| **Guarantee-audit** | 10 | The tightest honest claim: *a non-strategic worker can't cheaply over-claim a mechanically-decidable deliverable, and all fakery is tamper-evident to a later external re-runner.* Prevention is over-claim → README tightened. |
| **Ideation** | 10 | Forward features: compile-time framing lock, verifier-artifact hash-pinning, reversibility-tiered human gate, proof-capsule export, deterministic stall tripwire. |
| **Prior-art** | 10 | 58 projects scanned. Only real core competitor: **Loki Mode** (blind review council, but external-API + no hash-chain). Differentiation holds: evidence-ledger + unanimous method-diverse jury + keyless tamper-evidence + zero deps. |
| **v1.9–2.0 research** | 10 | LLM-as-judge literature: in-family panels barely decorrelate (Apple 2605.29800, n_eff 9→2.18); the real fix is **ground-truth anchoring**, not model diversity. |
| **Go evaluation** | 10 | Core/trust path stays bash+shasum — a compiled binary is un-auditable-without-a-toolchain and detonates "the artifact you run *is* the source you read." Go barred from the trust path; added as a *deliverable recipe* only. |
| **Rust evaluation** | 10 | Worse than Go for this skill (no stdlib crypto = dependency creep, 1–1.5 GB toolchain). Added as a deliverable recipe only. |
| **Test-suite** | 10 | Authored a 10-module regression suite (each green-on-real / red-on-mutation). Shipped in `tests/` — runs 10/10 on a fresh clone. |
| **v1.8 patch-set** | 10 | Turned the convergent agenda into 10 exact, minimal patches (anchor text + safety check + green/red rationale). **All 10 shipped in 1.8.** |
| **30-opus R&D** | 34 | 3 groups (capability · research · red-team) converged on the v1.9 direction — see [`v1.9-2.0-rnd.md`](v1.9-2.0-rnd.md) and below. |
| **20-theme gallery** | 21 | 20 domain-diverse compiled `/goal` contracts (lint 95–98, all ≤4000 chars) proving the compiler generalizes. Shipped in [`../examples/gallery/`](../examples/gallery/). |

## The v1.9 direction — "bind the seams"

The 30-opus R&D ([`v1.9-2.0-rnd.md`](v1.9-2.0-rnd.md)) had three independent groups
arrive at one diagnosis: **1.8 secured the interior of a single chain, but every place
trust must cross a boundary is still authored by the worker — the protocol's own
adversary.**

- **Live core hole (capability):** the ledger chains from a literal `GENESIS` with no
  session/identity binding — a resumed or compaction-amnesiac session reloads from disk
  and a full re-forge still prints `CHAIN INTACT`. J2's from-GENESIS recompute can't
  catch it (a re-forged chain is internally consistent). → **session-seam braid to a
  git-content witness.**
- **Research consensus:** verification over evaluation — shrink the LLM-judgment surface
  to deterministic, ledger-anchored oracle checks; push the completion gate toward a
  harness Stop-hook, not the worker's own turn.
- **Red-team consensus:** every 1.8 anchor is written/resolved/invoked *by the worker*
  (oracle-poisoning, near-free re-forge, jury-shopping). Fix = **attestation**: bind each
  anchor to something the worker can't quietly control, and ship an executable attack
  fixture that flips red pre-fix / green on HEAD.

All keep the invariants: keyless · bash + shasum + git · zero external-API · SKILL ≤ 97.
This is the first real structural answer to the honest ceiling 1.8 could not close — the
worker convening its own jury.

## Provenance

- Per-milestone prosecutor + juror transcripts and the tamper-evident evidence ledgers
  live in the (gitignored, internal) `goals/` tree: `goals/EVIDENCE-1.*.md`,
  `goals/1.*-prosecutor.md`, `goals/*-redteam-verdicts.md`, `goals/METRICS.md`.
- Raw multi-agent workflow journals (one line per agent, full return value) persist under
  `~/.claude/projects/<project>/subagents/workflows/*/journal.jsonl`.
- Milestone research source lists: [`sources/`](sources/).
- Every quantitative claim in the artifacts is reproducible via `scripts/ledger.sh verify`
  and `bash tests/run.sh`.
