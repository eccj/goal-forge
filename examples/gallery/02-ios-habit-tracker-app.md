# iOS habit-tracker app — goal-forge gallery example

**Domain:** mobile / native (SwiftUI + HealthKit) · **Mode:** goal — one bounded, definable "done" (ship the app, proven by an instrumented run). Not recurring (→loop), and 4 deliverables sit well under the 8+ campaign threshold.
**Lint self-score:** 96/100 · **3995 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 9 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #5 Turn cap — N=20 is the formula's exact output (ceil(4×2.5)+8 → round-up 20), but a from-scratch SwiftUI+HealthKit+WidgetKit build PLUS a 3-juror tribunal is genuinely tight; a real user should weigh bumping to 30 (which re-adds a required D0 PLAN.md and pushes chars back up). Secondary residual (#6): the notification evidence proves a reminder is SCHEDULED with the correct trigger, not DELIVERED — that is the honest simulator-only ceiling (real delivery needs a device + foreground/background run, out of scope here).

## Compiled `/goal`

```text
/goal [GF·goal·budget:20·jury:std·ledger:EVIDENCE.md·label=D#]
DONE-MEANS (full def <condition>): every D1-D4 E-D# raw-evidenced in EVIDENCE.md + a UNANIMOUS 3-juror verdict in the report.

WORKER
MISSION: A SwiftUI iOS habit-tracker "HabitForge" — HealthKit, per-habit local reminders, a WidgetKit progress widget — proven by an instrumented test on a named simulator.

TASKS (ev → EVIDENCE.md via ledger.sh, label=D#):
□ D1 Xcode project + SwiftData (Habit, Completion) + create/log/streak UI persisting across relaunch — ev: `xcodebuild -scheme HabitForge -destination '<sim>' build` exit 0 + an XCUITest create→log→relaunch→assert green; `.xcresult` shasum'd.
□ D2 HealthKit read+write + Info.plist usage strings for EXACTLY the used types — ev: `xcodebuild test` HealthKitTests exit 0 + `plutil -p */Info.plist|grep NSHealth` lists only used types (any unused-type request FAILS D2).
□ D3 Per-habit local reminders — ev: unit test asserts `pendingNotificationRequests` holds the seeded habit's UNCalendarNotificationTrigger; `xcodebuild test` exit 0.
□ D4 WidgetKit progress widget + FULL suite green on a NAMED simulator (device+OS logged) — ev: `xcodebuild test -scheme HabitForge -destination 'name=<dev>,OS=<v>'` stdout exit 0 + a TimelineProvider snapshot test asserting entry.done/total==fixture + `.xcresult` shasum; scheme≠HabitForge or a skipped target ⇒ exit 1.

FORBIDDEN: real Health data in the repo; hardcoded secrets/team-id; HealthKit types the app never uses (App-Store-reject); editing tests/scheme/ledger.sh to fake green; out of scope.
ASSUMPTION: on ambiguity assume + list it; never wait on the user. Defaults: SwiftData/iOS 17; sim-only (no paid account/device HealthKit); write mindfulSession, read stepCount; reminder 09:00. No Xcode/Simulator ⇒ SAY SO, mark PENDING-INSTALL, never fabricate a run.
LEDGER: raw outputs via `ledger.sh append`; full text stored; a changed file gets a superseding entry; a summary never replaces a raw block.
PIN: post-compaction + every ~10 turns, one line: active FORBIDDEN + gate decision + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run all xcodebuild checks + `ledger.sh coverage EVIDENCE.md 4` + `ledger.sh verify`; any fail ⇒ no jury) → PROSECUTOR self-audit → 3 isolated tool-jurors, verify-then-verdict (sonnet/sonnet/opus): J1 re-runs each xcodebuild by its OWN command (undeclared edit to test/scheme/ledger ⇒ REJECT) · J2 recomputes the chain from GENESIS, D#↔E-D#, `.xcresult` shasum==transcript echo · J3 Constraint+Goodhart, proxy ✓ AND intent ✓. REJECT ⇒ deficiency list only; reopening valid; 3/item ⇒ BLOCKED→user.
SAFETY: 20 turns; below 30% remaining (≤6) verification+closure only; unfinished ⇒ honest status. Crashed juror relaunches ONCE then reports; the worker NEVER simulates a juror.

EVALUATOR
<condition>
DONE iff the transcript shows (1) an E-D#-labeled raw command+output block for EVERY D1-D4, (2) the 3 jurors' UNANIMOUS APPROVE, and (3) a per-item evidence dump. Goodhart: "app works" ⇒ ≥1 UI-level XCUITest (not unit-only) GREEN on a named-simulator `xcodebuild test`, its `.xcresult` shasum matching its transcript echo; a unit-only pass or a screenshot is NOT "works." Any missing ⇒ NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 (build+CRUD XCUITest)·D2↔E-D2 (HealthKit+plist)·D3↔E-D3 (notif)·D4↔E-D4 (widget+suite+xcresult+fingerprint)
</evidence-map>
<anti-accept>
NOT met if ANY: a "works/passed" claim with no raw xcodebuild block · no/non-unanimous jury, OR a verdict with NO preceding Agent-tool subagent block (prose seal = fabricated jury) · any verdict lacking an adjacent E-D#/E-S#, hash, or exit-code line · a `.xcresult` hash absent from the transcript echo · an unresolved FORBIDDEN violation · turn cap exceeded with no honest status · the report lacking exactly ONE `STOP_REASON: <T>`, T∈{TRIBUNAL-UNANIMOUS,TURN-CAP-STATUS,BLOCKED-3REJECT,RED-HOLD,OUTAGE-FALLBACK,CRASH-RESUME,NO-PROGRESS,AWAITING-USER} · DONE with STOP_REASON≠TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
1. Budget vs greenfield scope: keep N=20 (formula) or bump to 30 for a from-scratch native build (30 makes a D0 PLAN.md mandatory again).
2. Min iOS target + persistence: assumed iOS 17 + SwiftData — pick Core Data / lower target if pre-17 support is needed.
3. Exact HealthKit types: assumed write mindfulSession + read stepCount as the reference habit — confirm the real habit→HKType map (MUST match the Info.plist NSHealthShare/UpdateUsageDescription strings 1:1, or D2 fails).
4. Device vs simulator: build/test loop is simulator-only (no paid Apple Developer account). On-device HealthKit authorization and actual notification DELIVERY need a paid account + provisioning — excluded from this goal.
5. App name / bundle id / scheme: goal uses "HabitForge" + a placeholder scheme/team-id — set real values.
6. Reminder cadence default: assumed 09:00 local with per-habit override — confirm.
7. App Store submission is explicitly OUT of scope (an irreversible §RED-HOLD action; would be a terminal HOLD handed to you).

---
*Stack note: Stack NAMED by the brief (SwiftUI + HealthKit), so STACKS §Firing = confirm-not-ask → no stack-bakeoff deliverable. Sub-choices taken as in-scope ASSUMPTIONs: SwiftData persistence + iOS 17 min target + WidgetKit + local UserNotifications. Toolchain verified present on this host: Xcode 26.4.1 (build 17E202); available sims include iPhone 17 Pro / iPhone Air (OS 26.x) — so the mobile RECIPES row (instrumented `xcodebuild test` + `.xcresult` hash + device/OS fingerprint; screenshot forbidden as sole proof; tool-gated honesty clause) is fully applicable and included.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
