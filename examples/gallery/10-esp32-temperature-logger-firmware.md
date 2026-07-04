# ESP32 temperature-logger firmware — goal-forge gallery example

**Domain:** embedded / IoT (C firmware) · **Mode:** goal — a definable "done" (ring-buffer + deep-sleep power budget + on-device/host unit tests), one coherent 6-deliverable mission; not recurring (so not loop), not 8+ items (so not campaign). Standard tribunal.
**Lint self-score:** 96/100 · **3985 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 8 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9`
**Weakest:** #6 Goodhart (8) — the inequality STRUCTURE is fully machine-encoded (D5 check_power exits 0/1 on avg_mA≤BUDGET AND battery-life≥target; D4 gcov≥floor tripwire), but the numeric constants (BUDGET µA, battery-life target, coverage floor) are pre-registered at run start via decide-before-launch rather than hardcoded in the goal, so the thresholds float until the operator fixes them. This is the correct pre-registration pattern (prevents fitting the floor to results), but it means the goal text alone doesn't pin the numbers.

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:EVIDENCE.md·label=D#]
DONE-MEANS (full def in <condition>): every D# E-D# raw-evidenced + 3-juror UNANIMOUS verdict in the report.

— WORKER —
MISSION: a pure-C ESP32 temperature logger — timer-woken samples into a fixed-size static ring buffer surviving deep-sleep, meeting a pre-registered average-current budget.

TASKS (evidence → EVIDENCE.md via scripts/ledger.sh, label=D#):
□ D1 PLAN.md, phases skeleton→core→tests→power→verify; state in file — ev: ls -la + headings quoted, per phase.
□ D2 framework bakeoff (Q7): ESP-IDF·Arduino-ESP32·PlatformIO on ≥4 criteria (sleep control, C-purity, repro, ecosystem) + ≥4 live sources; ALSO log ESP32 active/deep-sleep current (mA/µA) from datasheet — ev: criteria table + source URLs+reliability note; winner+why-not→roadmap.
□ D3 ring_buffer.c/.h (static, NO malloc, overwrite-oldest, pow2 mask) + deep-sleep scheduler (RTC-backed state survives sleep/wake, timer wake) — ev: gcc build (exit) + Unity tests (empty/full/wrap/overflow + N RTC save/restore cycles asserting survival) + cppcheck clean.
□ D4 `make test` FULL stdout+exit + gcov ≥ a PRE-REGISTERED floor over core modules; tripwire exits 1 on any fail / coverage<floor / a module [no tests] — ev: raw output + gcov -f; cover file shasum.
□ D5 check_power: avg_mA=(t_act·I_act+t_slp·I_slp)/period from D2 figures, asserts avg≤BUDGET AND life≥target, exit 0/1 — ev: raw output+exit; each current traced to a D2 source.
□ D6 build (idf.py/docker)→.bin + xtensa-esp32-elf-size + shasum; flash+serial-log on a NAMED board OR QEMU (no hw→honest PENDING, never faked); README reproduces build+flash — ev: build exit+size+hash; log OR PENDING.

FORBIDDEN: malloc/dynamic alloc in the sample→store→sleep path · busy-wait/delay in the sleep window · C++/Arduino-heavy if ESP-IDF chosen · fabricated power/serial numbers (cite datasheet; on-device needs a real log or PENDING) · out-of-scope work.
ASSUMPTION: on ambiguity assume + list in report; never wait on the user — EXCEPT §DAL-C (flashing/erasing the user's device, not self-authorizable): name it, ledger a HELD entry, STOP once.
LEDGER: raw outputs via ledger.sh append; full text stored; a changed file → superseding entry; a summary never replaces the raw block.
PIN: post-compaction first message + every ~10 turns restate FORBIDDEN + gate + ledger path.
PROCESS: on done → COMPLETION GATE (re-run all builds/tests/power-check + `ledger.sh coverage EVIDENCE.md 6` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool jurors (separate context, ground-truth-cited): J1-Re-runner(sonnet) · J2-Ledger-Auditor(haiku; GENESIS chain; D#↔E-D#) · J3-Constraint+Goodhart(opus; proxy✓ AND intent✓). REJECT→deficiency list; reopen valid; 3 REJECT=BLOCKED→user.
SAFETY: 25 turns; below 30% remaining, verification+closure only; unfinished→honest status.

— EVALUATOR —
<condition>
DONE ⟺ transcript: (1) an E-D# raw command+output block for EVERY D1-D6, (2) the 3 jurors' UNANIMOUS verdict (each ground-truth-cited), (3) item-by-item evidence dump. Goodhart is in the D-items: D4 gcov≥floor exit + D5 check_power exit 0 (avg_mA≤BUDGET from D2 currents); a bare "meets budget" sentence never counts. A §DAL-C HOLD meets (1) via an E-D# HELD entry naming the action + user command. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1(plan)·D2↔E-D2(bakeoff+currents)·D3↔E-D3(modules+tests)·D4↔E-D4(suite+cov)·D5↔E-D5(power exit)·D6↔E-D6(build)
</evidence-map>
<anti-accept>
ANY of these voids DONE: "passed/meets budget" with no raw block or exit code · a summary replacing a raw block · no jury / non-unanimous / a juror verdict with no preceding Agent-tool subagent block (prose-only seal = fabricated jury) · a juror verdict with no adjacent E-D#/E-S#, hash, or machine-assertion cite · a D# never mentioned · an unresolved FORBIDDEN violation · turn cap exceeded with no honest status · no single legal STOP_REASON (DONE only if TRIBUNAL-UNANIMOUS).
</anti-accept>
```

## Decide before launching
Deferred to the operator (all EXCLUDED from the goal per interview Q7 future-input rule; none blocks execution — the worker assumes + lists if unanswered): (1) Target ESP32 variant (classic / C3 / S3 / S2) — sets the deep-sleep µA and active mA figures D2 records and D5 consumes. (2) Sensor part (DS18B20 / DHT22 / SHT31 / on-die) — sets the active-window duration and current. (3) The three pre-registered constants: average-current BUDGET (e.g. ≤120 µA), battery-life target + capacity (e.g. ≥1 yr on 2×AA / 3000 mAh), and the gcov coverage floor (e.g. 85%) — fixed BEFORE D4/D5 run. (4) Sample period (e.g. 60 s), ring-buffer capacity, and record size. (5) Hardware reality: is a physical board + power meter (INA219 / uCurrent) available for the D6 on-device serial log, or does D6 legitimately close via QEMU / honest PENDING-HARDWARE? Absent an answer, the worker assumes ESP32-classic + DS18B20 + 60 s period + 85% floor + a documented battery budget, and D6 runs QEMU-or-PENDING — all recorded in the report.

---
*Stack note: Q7 FIRED — capability greenfield (no firmware stack present) + off-map domain (IoT, not in STACKS.md seed map) + headless compile (no live user) → STACKS §Firing routes to "research decides". So D2 is a compiled stack-bakeoff (RECIPES §Stack-bakeoff): ESP-IDF vs Arduino-ESP32 vs PlatformIO on ≥4 criteria with ≥4 live-checked sources, winner + one-line why-not, and the winner rewrites the D1 roadmap skeleton phase. D2 also folds in the domain KNOWLEDGE-GAP (staleness-prone ESP32 deep-sleep/active current figures) as sourced datasheet numbers, since D5's power model depends on them. Working assumption baked into FORBIDDEN: pure-C, ESP-IDF-leaning (bans C++/Arduino-heavy if ESP-IDF wins) — but the bakeoff, not the compiler, makes the call. Off-map candidates labeled curator-unverified.*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
