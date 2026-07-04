# Case Study 2 — Promo Video (the REJECT that proved the protocol)

**Context.** A 40-second brand video (HTML-rendered composition, 8 existing
food clips, RU text + EN subtitle layers, CC-BY music) to be rendered at
1080p, embedded in a pitch page and verified live. 5 deliverables, 20-turn
cap, standard tribunal. Compile-time score: 97/100, 2,903 chars.

**What happened.**
- Build phase hit real obstacles (fonts not auto-embedding → local woff2
  @font-face; music providers unavailable → CC-BY track with attribution;
  a browser-environment failure blocked in-page playback verification). Each
  workaround was logged with raw outputs.
- **J2 Ledger-style audit REJECTED the first dossier** — correctly: the
  evidence was summarized ("ffprobe says 1080p") rather than pasted as raw
  blocks, and the juror's own (mistaken-path) search couldn't find the render
  file. Verdict: "summaries are claims, not evidence."
- The deficiency list — and ONLY that list — was closed: raw `ls -la`,
  `md5`, full `ffprobe -of json`, raw CDN headers (HTTP 206 + ETag matching
  the local MD5), frame extractions assessed in writing.
- Reconvened J2: independently re-ran everything, **reversed to APPROVE** —
  and the *original* J2 instance later revised its own verdict unprompted:
  "faced with physical evidence I cannot defend the old ruling."
- Final: unanimous, with the browser-playback gap honestly declared and
  covered by compensating evidence (bit-identical CDN download + codec probe).

**Lessons that shaped v3.**
1. Narrative summaries are the #1 false-REJECT source → v3's Evidence Ledger:
   raw blocks with a sha256 chain, jurors audit the ledger not the story.
2. A juror revising a verdict on new evidence is *desired behavior* → v3's
   reopen clause makes it protocol ("revision is not failure").
3. Honest-gap + compensating-evidence is a legitimate pattern when the
   environment (not the artifact) fails — jurors accepted it unanimously.
4. Turn usage: ~12 of 20 (60%) — second data point for the estimate formula.
