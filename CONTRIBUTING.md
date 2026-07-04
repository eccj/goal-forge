# Contributing to Goal Forge

Contributions welcome — the highest-value ones, in order:

## 1. New evidence recipes (RECIPES.md)
Add a row: deliverable type → what raw output lands in the ledger. Rules:
the recipe must end in a *pasteable raw block* (command + stdout), never a
narrative; include the command itself; state what a juror should re-run.

## 2. New juror lenses (TEMPLATE.md §Juror)
We keep **three** jurors (correlated panels collapse — see README research
refs); a new lens must REPLACE one of the three for a specific domain, not
extend the panel. Submit: lens name, verification METHOD (what it re-executes
or audits), one failure mode it catches that the current three miss.

## 3. Domain goal presets (examples/)
A filled skeleton for a recurring shape (webapp feature, data pipeline,
refactor, research report…). Must pass LINT ≥90 and sit in the 3000-4000 char ideal band (hard limit 4000); include
the scorecard in the PR.

## 4. Case studies (examples/)
Real runs only: the compiled goal + what the Tribunal did (including REJECTs —
they're the interesting part) + lessons. Anonymize freely; keep verdicts real.

## Ground rules
- SKILL.md stays ≤100 lines; references stay one level deep.
- Every behavioral claim in docs needs a source: a real run or a citation.
- Backward compatibility: never break the scan → interview → compile → lint
  pipeline or existing triggers.
- Bug reports: use the "low-quality goal" issue template — attach the compiled
  goal, its scorecard, and what the evaluator/jury actually did.
