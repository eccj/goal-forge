# Job-listings web scraper — goal-forge gallery example

**Domain:** scraper · **Mode:** goal | one definable finish line, 6 deliverables, single mission — not recurring (loop) and <8 items (campaign)
**Lint self-score:** 98/100 · **3992 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 10`
**Weakest:** #6 Goodhart 9 — the "N rows scraped" trap is converted to a hard inequality (rowcount==pre-registered @returns bound + non-null-per-field, exit→1) but it lives in D5+FORBIDDEN rather than as a standalone inequality inside <condition>; that is TEMPLATE-correct (the Goodhart line belongs in <condition> ONLY when not derivable from the D-items, and here it is derivable from D4+D5), so it scores 9 not 10 purely for lower visual prominence, not for being absent.

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/EVIDENCE.md·label=D#]
DONE-MEANS (full in <condition>): every D1-D6 E-D# raw-evidenced + UNANIMOUS 3-juror verdict.

— WORKER —
MISSION: ship a Scrapy job-listings scraper: obeys robots.txt, validates each callback via Scrapy contracts, caches HTML for byte-identical offline re-parse, gates every record via a per-field schema check.

TASKS (evidence → goals/EVIDENCE.md via ledger.sh, label=D#):
□ D1 PLAN.md (phases scaffold→spider→contracts→cache→gate→docs; D2-D6 status in-file) — evidence: ls -la + wc -l + headings.
□ D2 RESEARCH target robots.txt + Scrapy-contracts API — evidence: ≥3 independent source URLs + live robots.txt pasted + reliability note each + findings naming the binding Allow/Disallow rules; conflicts surfaced.
□ D3 Scrapy project+spider+settings.py (robots-obey) — evidence: ROBOTSTXT_OBEY=True + DOWNLOAD_DELAY≥1 + custom UA pasted FROM settings.py AND echoed in the crawl log (delay honored).
□ D4 Scrapy contracts on EVERY callback (@url/@returns/@scrapes declared BEFORE the crawl) — evidence: `scrapy check` stdout per-callback OK/FAIL; scrapy absent → labeled pure-python3 mirror, never silent.
□ D5 fetch-once cache + OFFLINE re-parse + schema gate — evidence: shasum of fetch-time HTML; re-parse CACHED bytes OFFLINE twice, identical sample checksums (never re-fetch live); gate stdout+exit: non-null on EVERY field/row AND rowcount==pre-registered @returns bound → either mismatch → exit 1 (anti-pad: pad/null a field → exit 1).
□ D6 README + tests — evidence: full pytest stdout (exit visible) + README headings quoted + a reader runs the documented re-parse-from-cache command and reproduces the row count.
FORBIDDEN: live re-fetch in verification (parse the cache) · ROBOTSTXT_OBEY=False or DOWNLOAD_DELAY removed/<1s · other spiders/projects · row-count as sufficiency (pad/dup/null a required field → gate fails regardless) · scope creep.
ASSUMPTION: on ambiguity assume + list it in the report, never wait on the user — EXCEPT a §DAL-C irreversible action (name it, ledger a HELD entry, STOP once).
LEDGER: raw outputs via ledger.sh append; full text stored; changed file → superseding entry w/ fresh measurements; a summary NEVER replaces the raw block.
PIN: after compaction AND every ~10 turns restate FORBIDDEN + gate decision + ledger path.
PROCESS: done-claim → COMPLETION GATE (re-run all mechanical checks once + `ledger.sh coverage goals/EVIDENCE.md 6` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool jurors (SEPARATE context; ground-truth-anchored verdicts): J1-Re-runner (OWN commands: `scrapy check`/gate + git status/diff over checks) · J2-Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3-Constraint+Goodhart (robots+delay intact; proxy ✓ AND intent ✓). REJECT → deficiency list only; reopening valid; 3 rejects = BLOCKED → user.
SAFETY: 25 turns; below 7 remaining only verification+closure; if unfinished, honest status report.

— EVALUATOR —
<condition>
DONE ⟺ the transcript shows (1) an E-D#-labeled raw command+output block for EVERY D1-D6, (2) the 3 jurors' UNANIMOUS verdict (each ground-truth-anchored), (3) an item-by-item evidence dump. Missing any clause: NOT DONE.
</condition>
<evidence-map>
D1↔E-D1(PLAN)·D2↔E-D2(robots+sources)·D3↔E-D3(settings)·D4↔E-D4(scrapy check)·D5↔E-D5(cache+gate)·D6↔E-D6(tests+README)
</evidence-map>
<anti-accept>
NOT met if ANY appear: a done-claim with no raw output · a summary where a raw block is required · no jury / non-unanimous / a juror verdict with no preceding Agent-tool subagent block (prose-only seal = fabricated jury) · a juror verdict lacking an adjacent cited E-D#/E-S#, recomputed-hash, or machine-assertion line · a D# never mentioned · verification re-fetched live, not the cache · ROBOTSTXT_OBEY≠True or DOWNLOAD_DELAY<1 shipped · turn cap exceeded without an honest status report · no single legal `STOP_REASON`, or DONE whose STOP_REASON ≠ the sole done-token TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Exact target job-board URL + which fields make a listing record (title/company/location/salary/url/posted-date) and which are REQUIRED — this drives @scrapes and the D5 schema gate. 2) The pre-registered @returns rowcount bound for the fixture page (must be fixed BEFORE scraping, not fitted after). 3) DOWNLOAD_DELAY value and the identifying custom User-Agent string — assumed ≥1s + a contactable UA; confirm any rate-limit/politeness agreement. 4) Legal/ToS clearance to scrape the target at all (robots.txt obedience is assumed and enforced; ToS permission is a human call — a §DAL-C-adjacent decision). 5) Output sink/format (assumed JSONlines; confirm if a DB or CSV is wanted). 6) Turn budget 25 came from the coefficient-2.5 formula validated against real-run midpoint ~68.5% (≥50% → keep 2.5); tighten only if you accept less tribunal headroom.

---
*Stack note: Stack is NAMED in the brief (Scrapy / Python) → STACKS §Firing "named-tech → confirm-not-ask": Q7 does NOT fire a stack-bakeoff; Scrapy+Python3 confirmed as the prefilled default. Assumed present locally; if scrapy can't be installed, D4 degrades to the inline-labeled pure-python3 contract mirror (RECIPES web-scraper row), never a silent pretend. Output sink assumed JSONlines feed (no production DB writes).*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
