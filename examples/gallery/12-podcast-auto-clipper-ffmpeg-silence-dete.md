# Podcast auto-clipper (ffmpeg silence-detect → cut → caption, ffprobe-verified) — goal-forge gallery example

**Domain:** video / media · **Mode:** goal | single definable done, 6 deliverables, non-recurring
**Lint self-score:** 95/100 · **3998 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 9 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 8 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #6 Goodhart — caption "legible" rests on a written frame assessment, not a hard machine inequality. The ffprobe re-encoded-video-stream check (D5) is the machine anchor and the RECIPES video row explicitly sanctions "extracted frame assessed in writing," so it is compliant, but an OCR/pixel-diff gate on the burned caption would convert the last soft check into a falsifiable one. All other clip-quality wishes are already hard inequalities (±50ms boundary match, |dur−seg|≤0.1s, ≥2 streams, clip_count==expected).

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/EVIDENCE.md·label=D#]
DONE-MEANS (full def in <condition>): every D# E-D# raw-evidenced + UNANIMOUS 3-juror verdict.

═══ WORKER LAYER ═══
MISSION: a Python CLI that silence-detects podcast A/V cut points, cuts clips, burns captions, and emits only ffprobe-valid clips — proven end-to-end on a fixture.

TASKS (evidence → EVIDENCE.md via ledger.sh, label=D#):
□ D1 PLAN.md — phase-ordered (skeleton→core→captions→verify) — evidence: ls -la + wc -l + headings pasted.
□ D2 Fixture: synth via `ffmpeg lavfi` (tone segments split by KNOWN-length silence gaps) — evidence: gen cmd + `ffprobe -of json` (duration/streams) + sha256; ground-truth boundaries FROZEN in ledger BEFORE D3.
□ D3 Silence-detect: parse `ffmpeg silencedetect` stderr → segments; assert == frozen truth (count exact, ±50ms) — evidence: raw silencedetect stdout + parsed segments + assert exit (0=match/1=drift).
□ D4 Clip cutter: cut at boundaries → N clips — evidence: per-clip `ffprobe -of json` (v+a streams, codec, dur); assert exit=1 if any clip <2 streams OR |dur−seg|>0.1s; ls -la of clip dir.
□ D5 Caption burn-in: transcript→SRT→burn per clip — evidence: `ffprobe -of json` (re-encoded video) + ONE frame/clip assessed IN WRITING (caption legible) + SRT.
□ D6 End-to-end: `python -m clipper run <fixture>` — evidence: full `pytest -q` (exit visible) + determinism: run pipeline TWICE, diff sha256 of a fixed clip → identical or FAIL + clip_count == expected (padding/dropping fails).
FORBIDDEN: editing fixture/frozen truth after D2 · re-fetch/re-transcribe live to verify (parse cached outputs only) · network calls in tests (models pinned local) · shipping an ffprobe-invalid clip · "N clips" as success without per-clip ffprobe+dur proof · work outside this pipeline.
ASSUMPTION: on ambiguity, assume reasonably + list it in the report; never wait on the user. Stack = Python3 + system ffmpeg/ffprobe, offline. No §DAL-C action in scope; if one arises, ledger a HELD entry + exact user command, STOP once.
LEDGER: raw outputs via `ledger.sh append` (full text stored); changed files get a superseding entry; a summary never replaces the raw block.
PIN: after compaction AND every ~10 turns, restate in one line: FORBIDDEN + gate decision + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run all ffprobe/silencedetect/pytest + `ledger.sh coverage EVIDENCE.md 6` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool-equipped jurors: J1 Re-runner (re-runs checks by its OWN commands) · J2 Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart (proxy ✓ AND intent ✓). REJECT → deficiency list only; reopening valid; "could be better" ≠ REJECT; 3 rejects = BLOCKED → user.
SAFETY: 25 turns; below 30% remaining, verification+closure only; if unfinished, honest status report.

═══ EVALUATOR LAYER ═══
<condition>
DONE iff the transcript shows (1) an E-D# raw cmd+output block for EVERY D1-D6, (2) the 3 jurors' UNANIMOUS APPROVE, (3) item-by-item evidence dump. Goodhart: "good clips" is FALSE unless the per-clip ffprobe/dur asserts (D4), silence-boundary match (D3), and clip_count==expected (D6) ALL pass — a bare clip count never suffices. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1(PLAN) · D2↔E-D2(fixture) · D3↔E-D3(silence) · D4↔E-D4(cut) · D5↔E-D5(caption) · D6↔E-D6(e2e)
</evidence-map>
<anti-accept>
NOT met if ANY: "done/valid" with no raw ffprobe/exit block · summary where a raw block is required · no jury verdict / non-unanimous / a juror verdict with NO preceding Agent-tool subagent block (prose-only = fabricated jury) · a juror verdict with no adjacent E-D#/E-S#, hash, or machine-assertion anchor · a D# never mentioned · turn cap exceeded with no honest status · final report lacks exactly ONE STOP_REASON ∈ {TRIBUNAL-UNANIMOUS,TURN-CAP-STATUS,BLOCKED-3REJECT,DAL-C-HOLD,OUTAGE-FALLBACK,CRASH-RESUME,NO-PROGRESS,AWAITING-USER} · DONE with STOP_REASON ≠ TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1) Real input: which podcast file(s) and format (mp4/mp3/wav, audio-only vs A/V) — D2 uses a synthetic ffmpeg-lavfi fixture with frozen ground truth so silence-detect is deterministically checkable; confirm you also want a real sample run. 2) Caption source: local Whisper (which model size) vs a supplied transcript — assumed pinned-local/offline (tests forbid network). 3) silencedetect thresholds (assumed -30dB / 0.5s) + min/max clip length — tune to your content. 4) Output target: keep source aspect/codec (assumed) vs re-frame to 9:16 for Shorts/Reels + chosen encode. 5) Tribunal: standard assumed; juror models default J1 sonnet · J2 sonnet · J3 opus (bump J3→opus already; go heavy + independent prosecutor if you want an adversarial pass). 6) Harden caption check with an OCR/pixel-diff machine gate (see weakest) vs written frame assessment. 7) Confirm Python stack or request a stack-bakeoff. 8) Turn budget 25 is the LINT-#5 formula output (ceil(6×2.5)+8→25); tighten only knowing it eats the tribunal reserve.

---
*Stack note: Assumed Python3 orchestrating system ffmpeg/ffprobe (both present at /opt/homebrew/bin), fully offline. No live user, so STACKS §Firing headless default would be a stack-bakeoff; folded it into a single ASSUMPTION line instead to keep the goal at 6 focused deliverables. A real user could confirm Python, pick bash/Go, or request the bakeoff (see decide-before-launch).*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
