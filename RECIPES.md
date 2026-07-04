# Evidence Recipes — deliverable type → proof method

Pick the recipe when compiling the □ D# task list (TASKS/DELIVERABLES). Every recipe ends in the ledger
as a raw block (command + stdout), never a summary.

| Deliverable type | Recipe (what lands in the ledger) |
|---|---|
| **Web page / frontend** | `curl -s -o /dev/null -w "%{http_code} %{size_download} %{time_total}"` on the live URL + screenshot taken AND assessed in writing (what is visible, matching the spec) |
| **API endpoint** | Raw request + raw JSON response pasted; error-path probe (401/400) included |
| **Video / media** | `ffprobe -of json` (codec/resolution/duration/streams) + extracted frame(s) assessed in writing + file delivered to user |
| **Test suite** | Full `npm test` / `pytest` output pasted (exit code visible), not the tail |
| **Performance** | Numbers in the report: ms / MB / request count, with the measuring command |
| **File/CLI artifact** | `ls -la` + `wc -l/-c` + `md5`/`shasum` of the artifact; for deploys: local hash == remote hash |
| **Data pipeline** | Row counts before/after + checksum of output sample + rerun determinism check |
| **Research** | ≥N independent source URLs (N from goal, default 3) + findings summary in the report + one-line reliability note per source; conflicting sources surfaced, not hidden |
| **Refactor** | Behavior-parity evidence: same test output before/after + diff stat; "no functional change" claims need both |
| **Documentation** | File list + section headings quoted + a reader-task check ("following §X reproduces Y" — actually reproduced) |
| **Config/infra** | Applied state queried back from the system (not the config file): `vercel env ls`, `kubectl get`, raw provider response |
| **Document rewrite/overwrite** | Before overwriting, `grep`/`diff` OLD↔NEW for a preserve-inventory of valuable sections (tables, quotes, examples) and paste it; silent loss of a valuable section is a FORBIDDEN pattern (1.5-D3: a from-scratch README rewrite silently dropped a comparison table + a quote — the user caught it) |
| **Git-history / privacy purge** | A "history clean / private data removed" claim is evidenced ONLY by a platform-API scan (e.g. GitHub activity-API SHA now returns 404/422), NEVER by a force-push — force-push leaves dangling commits anonymously reachable (1.5-S1); the only real remediation is repo delete+recreate or a Support purge (both irreversible → §DAL-C terminal HOLD, user runs it) |

## Research deliverable — full recipe
When §1 knowledge-gap detection fires (staleness-prone: prices, APIs, best
practices, market/competitor facts), compile a research deliverable as:
`"<question> to be researched — evidence: >=N independent source URLs + a
findings summary + source-reliability notes in the report; conflicting
sources presented, never hidden."`
Jurors treat missing URLs or a single-source claim as unproven.

## Choosing N (sources) and measurement thresholds
- Research N: 3 default; 5+ for pricing/market claims; 2 acceptable for API
  syntax verified by an official doc.
- Perf thresholds: copy the user's words into an inequality; if the user gave
  none, propose one in the interview (never leave "fast" unmeasured).

## Notation standard (skeleton v2)
- Metadata line: `[GF·<mode>·budget:<N>·jury:<mode>·ledger:<path>·label=D#]` —
  machine-readable header; tooling and resumed sessions parse it first.
- IDs: deliverables are `D1..Dn` ↔ ledger `E-D#`; prosecutor findings are
  `S1..Sn` ↔ closure entries `E-S#` (J2 checks both mappings mechanically —
  an S# without an E-S# closure is an open finding). One scheme, everywhere —
  jurors and the evaluator match IDs mechanically (cf. 97-99%
  traceability with ID-matching in automotive requirements research — RAG
  setting, analogous not identical to our case; arXiv 2504.15427).
- `□` marks an open item; separators are `·` (compact, language-neutral).
- Range tokens: write `D1-D<n>`, never a count spelled out in two places.
- XML slots (`<condition>`, `<evidence-map>`, `<anti-accept>`) are the
  evaluator's contract — official Anthropic guidance: "XML tags help Claude
  parse complex prompts unambiguously" (docs.anthropic.com, use-xml-tags);
  keep tag names EXACTLY these three, never translated.

## Stack-bakeoff (Q7 "let research decide")
Deliverable shape: compare 2-3 candidates from STACKS.md on ≥4 criteria
(fit-to-mission, learning/setup cost, bundle/perf, ecosystem/longevity) with
≥4 live-checked sources; verdict = one winner + one-line why-not for losers;
evidence: criteria table + source URLs+status. The chosen stack then rewrites
the roadmap skeleton phase.
