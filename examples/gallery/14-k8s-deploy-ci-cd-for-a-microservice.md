# K8s deploy + CI/CD for a microservice — goal-forge gallery example

**Domain:** devops / infra · **Mode:** goal — a definable finish line (service live on a local kind cluster, applied state queried back, endpoint answering); not recurring/monitoring (→loop) and only 6 deliverables (<8, so not a campaign).
**Lint self-score:** 96/100 · **3991 chars** (canonical, ≤4000)

`1 End 10 · 2 Evidence 10 · 3 Constraints 9 · 4 Assumptions 10 · 5 Turn cap 10 · 6 Goodhart 9 · 7 Independence 10 · 8 Focus 10 · 9 Budget 10 · 10 Tribunal 9 = 97 (floors #2/#10 ≥8, none <5 → PASS; reported 96 conservative)`
**Weakest:** #6 Goodhart — "endpoint responds" asserts curl==200 and RECORDS latency (time_total) but sets no latency SLO inequality, so a slow-but-200 endpoint still passes. The other subjective wish ("deployed & working") is fully converted to a triple machine gate (rollout-status string == "successfully rolled out" AND cluster-reported imageID == D2's built digest Δ AND curl == 200 — not a bare helm-upgrade exit 0), which is the theme's core anti-Goodhart. A real user should set a p95/latency threshold (in decide-before-launch) to close the last gap.

## Compiled `/goal`

```text
/goal [GF·goal·budget:25·jury:std·ledger:goals/k8s-deploy.ledger·label=D#]
DONE-MEANS (full def in <condition>): every D1-D6 E-D# raw-evidenced + UNANIMOUS 3-juror verdict in the report.

WORKER
MISSION: a minimal microservice ships to a local kind cluster via a Helm chart + a validated GitHub Actions CI/CD workflow, its live state queried back from the API server and the endpoint responding.

TASKS (evidence → ledger via scripts/ledger.sh, label=D#):
□ D1 PLAN.md — phase-ordered (service→chart→CI→deploy→verify→security) — ev: `cat`+`sha256sum PLAN.md`.
□ D2 microservice + Dockerfile → tests + image — ev: `<test>;echo exit=$?` (0) + `docker build` + `docker images --digests <img>`; RECORD digest Δ.
□ D3 Helm chart → `helm lint <chart>` (0) + `helm template <chart> >r.yaml` + `sha256sum r.yaml` + `grep <Δ> r.yaml` (DIGEST-pinned, not `:latest`).
□ D4 GitHub Actions (.github/workflows/; build+test+`helm template`+deploy) → `actionlint` exit 0 + local `act -j <job>` log + exit 0.
□ D5 deploy + QUERY BACK: `kind create cluster` · `kind load docker-image <img>` · `helm upgrade --install` → `kubectl rollout status deploy/<n>` = "successfully rolled out" + `kubectl get deploy,svc,pods` + `kubectl get pod <p> -o jsonpath='{..imageID}'` == Δ (cluster-reported, NOT the yaml) + port-forward `curl -s -w "%{http_code} %{time_total}"` = 200 + err probe (404/400).
□ D6 security → `trivy image --offline-scan <img>` (offline, pinned-DB id+date, exit code) HIGH/CRIT triaged + `gitleaks detect --source . -f json` exit 0 (no committed secrets).

FORBIDDEN: deploy to a REMOTE/prod cluster or push a public registry (local kind + `kind load` only; =§DAL-C) · commit secrets/kubeconfig/tokens · `:latest` deployed ref · other kube-contexts · edit lint/CI/helm scripts to force green.
ASSUMPTION: on ambiguity assume + list it; never wait on the user. Prefilled: service = minimal Go HTTP `/healthz`+`/`; CI validated locally (actionlint+act, no `git push`). EXCEPT §DAL-C (prod deploy / external push): name it, ledger a HELD entry + the exact user command, STOP once.
LEDGER: raw cmd+stdout via `ledger.sh append` (full text stored); a changed file gets a SUPERSEDING entry; summaries never replace raw blocks.
PIN: after compaction + every ~10 turns restate FORBIDDEN + kind-only/digest-pin gate + ledger path.
PROCESS: on a done-claim → COMPLETION GATE (re-run all D2-D6 checks in ONE pass + `ledger.sh coverage <ledger> 6` + `ledger.sh verify`; any fail = no jury) → PROSECUTOR self-audit → 3 tool-equipped jurors: J1 Re-runner (own kubectl/curl/lint) · J2 Ledger-Auditor (chain from GENESIS; D#↔E-D#) · J3 Constraint+Goodhart (proxy✓ AND intent✓). REJECT → deficiency list only; reopening valid; 3 rejects = BLOCKED → user.
SAFETY: 25 turns; below 30% remaining (~7) verification+closure only; unfinished → honest status report.

EVALUATOR
<condition>
DONE iff the transcript shows (1) an E-D#-labeled raw cmd+output block for EVERY D1-D6, (2) a UNANIMOUS 3-juror verdict, (3) an item-by-item dump. Goodhart: "deployed & working" = `kubectl rollout status` = "successfully rolled out" AND cluster-reported imageID == Δ AND live `curl` = 200 — NOT merely a `helm upgrade` exit 0. Any missing → NOT DONE.
</condition>
<evidence-map>
D1↔E-D1 · D2↔E-D2 · D3↔E-D3 · D4↔E-D4 · D5↔E-D5 · D6↔E-D6
</evidence-map>
<anti-accept>
NOT met if ANY: "deployed/green" with no raw kubectl/curl block · applied state read from yaml, not queried via `kubectl get` · a scan/lint "clean" with no pasted exit code · no jury verdict / non-unanimous / a verdict with NO preceding Agent-tool subagent block (fabricated jury) · a verdict with no adjacent E-D#/E-S#, hash, or machine-assertion · an unresolved FORBIDDEN violation · turn cap exceeded with no status report · the report lacks exactly ONE `STOP_REASON: <T>`, T∈{TRIBUNAL-UNANIMOUS, TURN-CAP-STATUS, BLOCKED-3REJECT, DAL-C-HOLD, OUTAGE-FALLBACK, CRASH-RESUME, NO-PROGRESS, AWAITING-USER} · DONE with STOP_REASON≠TRIBUNAL-UNANIMOUS.
</anti-accept>
```

## Decide before launching
—

---
*Stack note: Core stack is theme-named → CONFIRMED, not bakeoff'd (STACKS §Firing: named-tech→confirm-not-ask): Helm chart + GitHub Actions + Kubernetes. Sub-choices assumed and moved to decide-list: microservice language = minimal Go HTTP (`/healthz`+`/`); local cluster = kind; image published via `kind load` (NO external registry); CI validated locally with actionlint + nektos/act (NO real `git push`). Q7 did not fire a full stack-bakeoff because the primary capabilities' stacks are named by the theme and this is a headless compile; the open sub-choices are recorded as reversible ASSUMPTIONs, not blocking items. decide_before_launch (real user should confirm): (1) microservice language/framework + actual business logic — Go trivial service is a placeholder; (2) run CI on GitHub's real runners via a real repo + `git push` (branch protection, required checks) — currently local-only; (3) target image registry (GHCR/ECR/Docker Hub) — external push is §DAL-C; (4) whether to graduate to a managed cluster (EKS/GKE/AKS) — prod deploy is §DAL-C; (5) latency/SLO threshold for "responds"; (6) trivy severity policy (HIGH/CRITICAL = hard-fail vs triaged); (7) juror model assignment for Q6 (default sonnet jurors, opus for hardest verify).*
*One of 20 domain-diverse stress-test examples — compiled by goal-forge 1.8 with **assumed** interview answers (no live user).*
