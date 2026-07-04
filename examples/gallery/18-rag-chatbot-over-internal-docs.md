# RAG chatbot over internal docs — goal-forge gallery example

**Domain:** AI / RAG · **Mode:** goal — definable "done" (chatbot + reproducible eval harness), 6 deliverables (<8) on one coherent mission; not recurring (rules out loop), not 8+ items (rules out campaign)
**Lint self-score:** 98/100 · **3998 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 10 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #3 Constraints (9) — "corpus dir" and every floor/ceiling are placeholders; exact corpus path + numeric bars are user-specific, so they're moved to decide-before-launch rather than invented. (#10 also 9: reopen clause is terse but present.)

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:EVIDENCE.md·label=D#]
DONE-MEANS (full in <condition>): every D1-D6 E-D# raw-evidenced + UNANIMOUS 3-juror verdict + per-item evidence dump.

═══ WORKER LAYER ═══
MISSION: a RAG chatbot over internal docs answering grounded in retrieved passages, plus an OFFLINE eval of recall@5, grounded-answer rate and hallucination on a pre-registered held-out set.

TASKS (evidence→EVIDENCE.md via ledger.sh, label=D#):
□ D1 PLAN.md — PRE-REGISTER before any run: held-out split, one SEED threading split+retriever+gen(temp=0), thresholds (recall@5, groundedness, hallucination, answerable-acc) + BM25 baseline. ev: ls -la + grep threshold/seed lines.
□ D2 pipeline: docs→chunk→embed→FAISS→retrieve top-k→grounded gen w/ inline [chunk-id] cites. ev: doc+chunk counts (wc); one LIVE query raw req+JSON (retrieved ids+scores + cited answer) + error probe (empty→4xx).
□ D3 held-out eval.jsonl: N answerable (gold chunk-id(s)+answer) + M unanswerable/out-of-corpus, seed-split, NEVER in any prompt/few-shot. ev: wc -l + shasum + 3 rows read in writing.
□ D4 retrieval eval, held-out ONLY: recall@1/@5 + MRR@10 vs BM25; EXIT 0 iff recall@5 ≥ floor AND > baseline else 1. ev: raw metric+baseline block + exit.
□ D5 grounded check on CACHED gens (offline): per Q, cited ids ⊆ retrieved ids AND support ≥ floor AND ≤K cites; rate ≥ floor → EXIT 0 else 1. ev: raw grounded/ungrounded counts + rate + exit.
□ D6 hallucination probe on M unanswerable (cached): expected=ABSTAIN; confusion_matrix.ravel()→(tn,fp,fn,tp); rate=answered/should-abstain; EXIT 0 iff rate ≤ ceiling AND abstain-recall ≥ floor else 1. ev: raw (tn,fp,fn,tp) + rates + exit.

FORBIDDEN: writing prod docs or indexing outside the corpus dir · any network call during eval (offline only) · fitting thresholds AFTER results · leaking eval.jsonl into any prompt/few-shot · deploy/publish (→§DAL-C) · scope creep.
ASSUMPTION: stack = local embeddings + FAISS + temp=0 seeded gen, eval offline vs cached outputs; on ambiguity choose+list, never wait — EXCEPT §DAL-C irreversible (prod deploy / hosted-index upload): name it, ledger a HELD entry, STOP once.
LEDGER: raw command+stdout via ledger.sh append; full text stored; a re-run changing any number → superseding entry; summary never replaces the raw block.
PIN: post-compaction + ~every 10 turns restate FORBIDDEN + thresholds/seed + ledger path.
PROCESS: on done-claim → COMPLETION GATE (re-run every D2-D6 fixture + ledger.sh coverage EVIDENCE.md 6 + verify; any fail=no jury) → PROSECUTOR self-audit → 3 tool jurors verify-then-verdict: J1 Re-runner (own cmds) · J2 Ledger-Auditor (GENESIS chain; D#↔E-D#) · J3 Constraint+Goodhart dual sign-off. REJECT→deficiency list; reopen valid; 3 rejects=BLOCKED→user.
SAFETY: 25 turns; below 30% remaining → verification+closure only; else honest status report.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript shows (1) an E-D#-labeled raw command+output block for EVERY D1-D6 (D4-D6 each print an EXIT code), (2) 3-juror UNANIMOUS APPROVE, (3) a per-item evidence dump. GOODHART (proxy ✓ AND intent ✓): "low hallucination" NOT met by blanket abstention — D6 needs rate ≤ ceiling AND answerable-accuracy ≥ floor. Missing any → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 · D2↔E-D2 · D3↔E-D3 · D4↔E-D4 · D5↔E-D5 · D6↔E-D6
</evidence-map>
<anti-accept>
NOT met if ANY: a pass with no raw block/exit code · a summary for a raw block · thresholds/seed changed AFTER a run · eval.jsonl in any prompt/few-shot · no/non-unanimous jury OR a juror verdict with no preceding Agent-tool subagent (prose seal=fabricated jury) · a verdict lacking an adjacent E-D#/E-S#, hash or exit anchor · a D# never mentioned · unresolved FORBIDDEN violation · turn cap exceeded w/o status report · report lacks exactly ONE STOP_REASON ∈ {TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, DAL-C-HOLD, OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Exact internal-docs corpus (repo/dir/wiki path + access) that defines the "corpus dir" boundary. 2) Numeric bars: recall@5 floor, groundedness floor, hallucination ceiling, answerable-accuracy floor, K (max cites/answer), k (retrieval top-k). 3) Eval-set sizes N (answerable) / M (unanswerable) and who authors the gold chunk-ids + gold answers (SME vs synthetic). 4) Generation LLM + whether local or a hosted API — a hosted call breaks the offline/cached-reproducibility assumption and makes any hosted-index upload a §DAL-C hold. 5) Groundedness scoring method (NLI model vs lexical overlap); note an LLM-judge would violate the offline-eval constraint. 6) Confirm the assumed stack (embeddings/vector store/generation) or run the bakeoff. 7) Is a chat UI/endpoint in scope or is CLI-only acceptable for D2's live query? 8) Tribunal juror models (assumed sonnet default, opus for the hardest numeric re-run).

---
*Stack note: Assumed (Q7 headless default would be a "research decides" bakeoff): local sentence-transformers embeddings + FAISS index + temp=0 seeded generation, with all eval scored OFFLINE against cached generations so J1 gets byte-identical re-runs. Flagged for confirmation in decide-before-launch.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
