# Track Record

> **Honest caveat, read first.** The raw run artifacts behind these numbers
> (ledgers, verdicts, prosecutor findings) are kept **private** — they are in
> the operator's language and contain business context. The numbers below are
> therefore the maintainer's claims, not independently clickable evidence.
> They are reproducible in kind by running the protocol yourself: every run
> regenerates the same artifact classes on your own machine.

Goal Forge was built **with itself**: from v0.3 on, every version was
developed under a contract compiled by the previous version, judged by its
own prosecutor and jury. Development history in numbers (from the internal
METRICS telemetry file, as of 2026-07-04):

- **18 telemetry rows covering ~20 runs** (one row aggregates three light field runs; the file's own cumulative header still says 16 from its last full recount — we publish the discrepancy rather than pick the prettier number)
- **113+ prosecutor findings as raw totals** (the raw sum includes a few findings that were themselves refuted; later runs add ~24 more) — every standing one closed
  with evidence or an honest correction; **0 left open** at any run's close
- **First-ballot jury rejections occurred and were resolved in 100% of
  cases** — no rejection was ever buried; several were the most valuable
  events of their runs (one caught fabricated evidence planted as a blind
  red-team test; one caught the maintainer's own arithmetic inflation in a
  self-score)
- **A shutdown valve that actually fired**: one campaign milestone was
  NOOP-ed by its own sufficiency gate; the prosecutor then *overturned* that
  NOOP on evidence — the appeal mechanic born there is now codified law in
  [CAMPAIGN.md](CAMPAIGN.md). A later campaign ended itself with an honest
  BLOCKED report rather than grind toward an unreachable score.
- **Small-model jurors are real**: a Haiku juror served in 3 consecutive
  tribunals (checklist-format briefs), including one justified REJECT it
  later revised itself when evidence arrived — the reopen clause working
  as designed.
- **Honest self-score: ~7.3-7.6 / 10** on a pessimist rubric (design strong;
  external validity still limited: one operator, one week, few external
  projects). An external cross-family model reviewed the same claims and
  scored 7.0, calling the self-score "accurate, slightly optimistic" — we
  publish that agreement rather than a bigger number.

What this record does **not** prove: generality across operators and
codebases. That evidence can only accumulate the way it should — through
your runs, not our claims.
