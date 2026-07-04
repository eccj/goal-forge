# Security audit of a Node.js API — goal-forge gallery example

**Domain:** security · **Mode:** goal — a definable "done" (SAST + secrets + dependency CVEs across the whole service, each D# E-D#-evidenced + unanimous jury); not recurring/monitoring (would be loop), and 6 deliverables (<8, so not a campaign)
**Lint self-score:** 97/100 · **3993 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #10 Tribunal (9): to fit under 4000 chars the STOP_REASON 8-token enum was compressed to "the closed terminal set" and the isolated-juror/disjoint-context clause is not spelled out in-goal — but both anti-accept triggers (missing/illegal STOP_REASON; DONE⇒TRIBUNAL-UNANIMOUS) and every protocol invariant survive: COMPLETION GATE before jury, 3 method-diverse tool jurors (re-runner/ledger-auditor/constraint-warden), independent prosecutor, anchored verdicts, from-GENESIS hash chain, Goodhart dual sign-off, reopen clause, 3-strikes BLOCKED, two-layer v2 skeleton. Runner-up #6/#3 (9): severity triage is report-only, not gated on a numeric threshold (appropriate for an audit), and constraints name categories rather than specific files (correct for a whole-service scope).

## Compiled `/goal`

```text
/goal [GF·goal·budget:30·jury:heavy·ledger:goals/EVIDENCE.md·label=D#]
DONE-MEANS (full def in <condition>): every D# E-D# raw-evidenced + UNANIMOUS 3-juror verdict in the report.

WORKER LAYER
MISSION: Complete security audit of the Node.js API — SAST + secrets + dependency CVEs across the WHOLE service; whole-tree coverage, every finding scanner-anchored.

TASKS (evidence → <ledger> via ledger.sh append, label=D#):
□ D1 goals/PLAN.md: toolchain+versions, pinned CVE-DB snapshot, file inventory — ev: `ls -la`+`wc -l` PLAN.md + `git ls-files|wc -l` pasted.
□ D2 SAST all JS/TS — ev: `semgrep scan --config p/nodejs --config p/javascript --json` (exit; ruleset IDs) AND `njsscan --json .`; tripwire rule-count>0.
□ D3 Secrets — ev: `gitleaks detect --source . -f json --report-path gl.json`; leak count + rule-id·file:commit per leak. REDACT: masked fingerprint only, never plaintext.
□ D4 Dependency CVEs — ev: `osv-scanner scan source -r --offline --local-db=<snap> ./package-lock.json`; vuln count + pinned snapshot id+date. Live query FORBIDDEN — offline pinned DB only.
□ D5 Coverage — ev: diff each scanner's scanned list vs `git ls-files` (paste BOTH counts); tripwire uncovered==0 OR each uncovered path OPEN + reason.
□ D6 Triaged report goals/AUDIT.md — ev: headings quoted + every row={scanner·rule-id·severity·file:line}; `grep -c` rows==D2+D3+D4 total; one HIGH finding's §Repro reproduced+pasted.
TOOL-GATE: scanner absent → cite exit-code table + PENDING-INSTALL; no substitute.

FORBIDDEN: editing app source (read-only)·auto-remediation/PRs·pasting a plaintext secret·live-network CVE query·rewriting/force-pushing git history·work outside scope.
ASSUMPTION: on ambiguity assume + list in report; never wait on the user — EXCEPT §DAL-C (irreversible unauthorized action, e.g. key rotation): name it, ledger a HELD entry, STOP once. Baseline = semgrep+njsscan / gitleaks / osv-scanner; swaps → decide-list.
LEDGER: raw outputs via ledger.sh append; full text between ENTRY markers; a changed file gets a SUPERSEDING entry; a summary never replaces the raw block.
PIN: after compaction + every ~10 turns restate one line: FORBIDDEN + coverage-gate + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run all scanners + `ledger.sh coverage goals/EVIDENCE.md 6` + `ledger.sh verify`; any failure = no jury) → independent PROSECUTOR subagent (attacks coverage gaps, empty rulesets, redaction leaks; S1..Sn→E-S#) → 3 tool jurors: J1-Re-runner (own commands) · J2-Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3-Constraint+Goodhart (proxy ✓ AND intent ✓). REJECT → deficiency list only; reopening valid; 3 rejects/item = BLOCKED → user.
SAFETY: 30 turns; below 30% remaining verification+closure only; if unfinished, an honest status report.

EVALUATOR LAYER
<condition>
DONE iff the transcript shows (1) an E-D#-labeled raw command+output block for EVERY D1-D6 AND (2) the 3 jurors' UNANIMOUS verdict AND (3) an item-by-item evidence dump AND (4) D5 coverage + D2/D4 non-empty-scan tripwires pass (proxy ✓ AND intent ✓; a green exit over a narrowed scope is NOT DONE). Any missing: NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (plan+scope)·D2↔E-D2 (semgrep/njsscan)·D3↔E-D3 (gitleaks)·D4↔E-D4 (osv)·D5↔E-D5 (coverage)·D6↔E-D6 (report)
</evidence-map>
<anti-accept>
NOT met if ANY appear: "clean/no findings" with no exit+count pasted · scanned-file count < `git ls-files` with no OPEN list · a plaintext secret in the ledger · a live-query CVE result (no pinned snapshot) · a summary where a raw block is required · no jury verdict, non-unanimous, OR a juror verdict with NO preceding Agent-tool subagent block · a juror verdict lacking a cited E-D#/E-S#, recomputed-hash, or machine-assertion line · a D# unmentioned · an unresolved FORBIDDEN violation · turn cap exceeded, no status report · the report lacks exactly ONE `STOP_REASON: <T>` from the closed terminal set, or a DONE finish whose STOP_REASON ≠ TRIBUNAL-UNANIMOUS (the sole done-token).
</anti-accept>
```

## Decide before launching
1) Target path: assumed the current repo root containing package-lock.json; confirm if the API is one package inside a monorepo (then siblings' in-scope status). 2) Scanner swaps: baseline is semgrep+njsscan/gitleaks/osv-scanner — user may substitute ESLint-security, Snyk, Trivy, or npm audit (note: npm audit is network-bound and breaks J1 offline reproducibility). 3) Pinned CVE-DB snapshot id+date to use for osv-scanner --offline (reproducibility anchor). 4) Severity policy: assumed report-only (findings triaged, none gate the run) — decide if HIGH/CRITICAL should hard-fail. 5) Tribunal models (Q6): assumed prosecutor=Opus, jurors default Sonnet with J3=Opus for the semantic Goodhart call; J1/J2 can drop to the Haiku cheap lane (checklist briefs) for the mechanical re-runs. 6) Live-secret handling: assumed masked-fingerprint-only in the ledger and key rotation deferred to a §DAL-C HOLD the user executes — confirm the rotation owner/runbook.

---
*Stack note: Q7 does NOT fire a stack-bakeoff: this is an audit of an existing service, not a capability build, and the security-scan RECIPES row prescribes the named toolchain — so the scanner set is folded in as an in-scope ASSUMPTION with swaps routed to the decide-list (STACKS §Firing SKIP case). Baseline: semgrep + njsscan (JS/TS SAST, adapting the RECIPES bandit-for-Python row to Node), gitleaks (secrets), osv-scanner run OFFLINE against a pinned advisory-DB snapshot (CVEs). All scanners are tool-gated: if absent locally, evidence is marked PENDING-INSTALL with the official exit-code table cited rather than fabricated.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
