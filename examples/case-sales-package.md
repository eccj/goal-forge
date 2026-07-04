# Case Study 1 — Sales Package (unanimous first-pass verdict)

**Context.** A restaurant video-menu demo (static site + Vercel functions)
needed to become a sellable demo package: pitch page, table-QR card
generator, analytics, admin CRUD with media upload, and a performance
guarantee — compiled into one goal (5 deliverables, 25-turn cap, standard
3-lens tribunal). Goal Quality Score at compile time: 96/100, 2,321 chars.

**What the goal looked like (structure).**
Mission (one sentence) → 5 deliverables each with an explicit evidence method
("live curl 200 + screenshot assessment", "3 test events → counter increase
shown in the admin report", "cold-load DOM < 2s and 0 MB media at first
paint — measured") → MUST-NOTs (no payment/POS integrations, no new AI
content, no touching existing videos) → assumption authority → tribunal →
25-turn safety valve.

**What happened.**
- Real bugs surfaced *because* evidence was mandatory: a CDN stale-read bug
  and an event-loss race would have hidden behind "works on my machine" — the
  "show the counter increasing live" evidence clause forced architecture fixes
  (versioned blobs, append-only event files) before the jury ever convened.
- Prosecutor self-audit caught a weak spot (admin UI flow proven only via its
  API) and closed it with live DOM grep evidence pre-jury.
- Tribunal: **J1 approved 5/5**, **J2 found "no unproven claims"**, **J3
  independently re-ran git diff / repo grep / live curl** and confirmed zero
  constraint violations. Unanimous on the first pass.

**Lessons that shaped v3.**
1. Jurors who re-run commands produce dramatically more trustworthy verdicts
   → v3's J1 Re-runner lens and tools-on juror default.
2. Evidence clauses are not bureaucracy — they found two production bugs
   before any human tester touched the system.
3. Turn usage: ~14 of 25 (56%) — data point behind the v3 estimate formula.
