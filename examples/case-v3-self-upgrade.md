# Case Study 3 — The v3 Self-Upgrade (goal-forge judging its own upgrade)

**Context.** goal-forge v3 was built under a goal compiled by v2 — the skill
managing its own development. 7 deliverables (protocol hardening, research
integration, archive/resume, README/CONTRIBUTING/LICENSE, case studies,
dogfood run, integrity), 30-turn cap, heavy tribunal (+independent
prosecutor). Compile-time score: 98/100, 3,168 chars.

**What happened — every v3 mechanism got its first live test.**

- **The prosecutor earned its keep**: 8 real findings, the sharpest being
  self-referential — the freshly-written archive violated its own template
  (the "Compiled goal" section held a placeholder instead of the exact goal
  text, making the resume card mechanically unusable). The system caught
  itself not practicing what it preached. All 8 findings were closed with raw
  evidence — including live `curl` checks proving the three arXiv citations
  resolve (HTTP 200), and a formula recalibration when the prosecutor showed
  the turn-estimate contradicted its own field data.
- **J2 issued a correct partial REJECT**: two ledger measurements had gone
  stale (files legitimately changed *after* their entries, during prosecutor
  fixes) and the hash-chain mechanics had been described but never
  demonstrated. Neither was fabrication — but the ledger couldn't prove it.
- **The reopen clause fired for real**: the deficiency list was closed with
  superseding measurements and two hash-chained entries (E6→E7). J2 then
  recomputed E7's hash independently with the protocol command — **bit-for-bit
  identical** — and reversed to APPROVE, noting one gap: E6's full entry text
  hadn't been shared, so its GENESIS link couldn't be recomputed.
- **Unanimous verdict**, ~16/30 turns (53%), regime band never reached.

**Lessons → v4 changes.**
1. *Superseding entries*: a file that changes after its ledger entry needs a
   fresh entry — stale-but-honest data still (rightly) triggers REJECT.
   → TEMPLATE §Ledger rule.
2. *Full-text storage*: a hash whose input text isn't stored proves nothing —
   jurors must be able to recompute from GENESIS. → `scripts/ledger.sh`
   stores entries verbatim and `verify` recomputes the whole chain.
3. *Reopen works*: juror revision on irrefutable evidence is now field-proven
   protocol, not theory. → noted in the juror prompt core.
Turn usage: ~16 of 30 (53%)
