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
| **Research** | ≥N independent source URLs (N from goal, default 3) + findings summary in the report + one-line reliability note per source; conflicting sources surfaced, not hidden |
| **Refactor** | Behavior-parity evidence: same test output before/after + diff stat; "no functional change" claims need both |
| **Documentation** | File list + section headings quoted + a reader-task check ("following §X reproduces Y" — actually reproduced) |
| **Config/infra** | Applied state queried back from the system (not the config file): `vercel env ls`, `kubectl get`, raw provider response |
| **Document rewrite/overwrite** | Before overwriting, `grep`/`diff` OLD↔NEW for a preserve-inventory of valuable sections (tables, quotes, examples) and paste it; silent loss of a valuable section is a FORBIDDEN pattern (1.5-D3: a from-scratch README rewrite silently dropped a comparison table + a quote — the user caught it) |
| **Git-history / privacy purge** | A "history clean / private data removed" claim is evidenced ONLY by a platform-API scan (e.g. GitHub activity-API SHA now returns 404/422), NEVER by a force-push — force-push leaves dangling commits anonymously reachable (1.5-S1); the only real remediation is repo delete+recreate or a Support purge (both irreversible → §DAL-C terminal HOLD, user runs it) |
| **ML model evaluation** | Held-out `classification_report`-equivalent (per-class precision/recall/F1/support, computed only on the held-out split) + `confusion_matrix.ravel()`→(tn,fp,fn,tp) raw counts + an inline fixed seed threading BOTH the split and the estimator (change it and every number moves) + a `DummyClassifier`(most_frequent)-style baseline the model's held-out accuracy must exceed, enforced by the fixture's own process exit code (0 = beats baseline, 1 = does not) rather than a printed sentence; a lone accuracy scalar, or a green exit with no confusion-matrix/baseline block printed, is NOT sufficient evidence |
| **Security scan** | Named CLI scanner per artifact class actually present, ALL applicable ones required (not "any one"): SAST → `bandit -r <path> -f json` (exit 0=clean/1=issues; severity×confidence + plugin/ruleset IDs pasted); secrets → `gitleaks detect --source . -f json` (exit 0=clean/1=leaks/126=bad-flag; --report-format json/csv/junit/sarif); dependency CVEs → `osv-scanner scan source -r --offline --local-db=<pinned-snapshot>` or `pip-audit -r --offline` (exit 0=clean/1=vulns/127-128=error; pinned-DB snapshot-id+date recorded in the ledger — live network query is FORBIDDEN, must run offline against a pinned DB for J1 reproducibility). Scanned-file count/list is diffed against the full deliverable file list (`git ls-files`/`find`); any file outside scanner scope is marked OPEN, never assumed clean — a scan of a narrowed/near-empty path is not evidence. Tool-gated: if a scanner is absent locally, cite its official exit-code/ruleset table verbatim and mark the evidence PENDING-INSTALL; fabricating a run, or substituting a hand-rolled scanner for the real named tool, is a FORBIDDEN pattern. |
| **Data pipeline** | Row counts before/after (`wc -l` or query count, in vs out) + checksum of a fixed-size output sample (`sha256sum`) + rerun-determinism check: run the pipeline twice on identical input, diff the two runs' sample checksums — non-identical = FAIL + N sample output rows pasted and assessed in writing against the expected transformation (row-count/checksum recording alone does not prove correct content — a no-op or same-count-but-corrupted pipeline must be caught here) |
| **Mobile app (native)** | `./gradlew test` (unit) **and** `./gradlew connectedAndroidTest` (instrumented, run on a NAMED emulator/device with OS/API level recorded) — raw stdout + exit code pasted; report artifact hashed (`shasum` of the XML at `build/outputs/androidTest-results/connected/` or HTML at `build/reports/androidTests/connected/`); iOS analog `xcodebuild test -scheme <S> -destination '<device>'` with the `.xcresult` bundle hashed. A "the app works" claim requires a PASSING **instrumented/UI-level** run (unit tests alone are insufficient — they prove nothing about real device behavior) + the report artifact + device/emulator fingerprint; a screenshot alone is FORBIDDEN as sole evidence. When the exact emulator/device can't be reproduced, J1 verifies the artifact + fingerprint instead of demanding a byte-identical re-run. Tool-gated: requires a local JVM+Android SDK+emulator or Xcode+simulator — if unavailable, state so honestly rather than fabricating a "live" transcript. |
| **Web scraper** | Contract check: `scrapy check` output (per-callback OK/FAIL against `@url`/`@returns`/`@scrapes` directives declared BEFORE the crawl); if scrapy isn't installed, a pure-python3 mirror is acceptable ONLY when the pasted output says so inline (e.g. "scrapy absent -> pure-python mirror") -- never silently pretend the real tool ran. Parse a CACHED copy of the fetched HTML (saved once at fetch-time, re-parsed OFFLINE on every J1 re-run so the bytes are identical -- never re-fetch live to "verify"). Evidence = per-field non-null completeness across every row AND `rowcount == expected` from the pre-registered `@returns` bound (fixed BEFORE scraping, not fitted to the sample after) -- either mismatch flips the process exit code to 1. Paste the crawl's actual `ROBOTSTXT_OBEY`/`DOWNLOAD_DELAY`/User-Agent from `settings.py` or the crawl log, not an unconditional claim. Anti-Goodhart: "N rows scraped" is never sufficient evidence -- padding, duplicating, or nulling a required field fails the schema gate regardless of row count. Sources: docs.scrapy.org/en/latest/topics/contracts.html, docs.scrapy.org/en/latest/topics/settings.html. |
| **Go project** | `go test -race -coverprofile=cover.out ./...` (raw stdout + exit code) + total coverage from `go tool cover -func=cover.out` (cover.out hashed) + `go vet ./...` + `govulncheck ./...` run OFFLINE against a pinned vuln-DB snapshot (id+date ledgered — live query FORBIDDEN, for J1 reproducibility). Machine tripwire: exit flips to 1 if the tested set != `go list ./...` (scope-narrowing), ANY package reports `[no test files]` in scope, the `-race` detector fires, or coverage is below a PRE-REGISTERED floor (fixed before the run, not fitted after). Anti-Goodhart: a green `go test` on a narrowed package set, or `ok` with `[no test files]`, is NOT sufficient evidence. |
| **Rust project** | `cargo test` (or `cargo nextest run`) raw stdout + exit code + `cargo clippy -- -D warnings` (exit 1 on any lint) + coverage via `cargo llvm-cov --summary-only` against a PRE-REGISTERED floor + `cargo audit`/`cargo deny check` run OFFLINE against a pinned advisory-DB (or `osv-scanner --offline` on `Cargo.lock`; snapshot id+date ledgered). Machine tripwire: exit≠0 on any failing/ignored-but-required test, clippy warning, coverage below the floor, or `#[ignore]`d tests in the required set. Anti-Goodhart: compiling + a green subset is NOT evidence — ignored tests, a narrowed `--package`, or coverage under the floor fail the gate regardless. |

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

## §Notation standard (skeleton v2)
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
