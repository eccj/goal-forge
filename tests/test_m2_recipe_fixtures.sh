#!/usr/bin/env bash
# =============================================================================
# test_m2_recipe_fixtures.sh
# Regression test for goal-forge Campaign 1.7 · Milestone 2 (RECIPE FIXTURES).
#
# SUBJECT: the three pure-python3 evidence fixtures that prove the M2 domain
# recipes (RECIPES.md: "ML model evaluation" / "Data pipeline" / "Web scraper")
# are actually implementable as deterministic, dependency-free, anti-Goodhart
# artifacts:  fixture_ml-eval.py  fixture_data-pipeline.py  fixture_scraper.py
#
# CONTRACT ASSERTED (per fixture):
#   A  no forbidden external import  (no sklearn / scrapy / dbt / numpy / ...)
#      -- proven BOTH statically (grep of import statements) AND at RUNTIME
#         (an import blocker bans those modules; the fixture still runs clean)
#   B  byte-reproducible: two independent runs emit identical stdout (non-empty)
#   C  legit run exits 0 and prints its GREEN verdict token
#   E  ANTI-GOODHART TRIPWIRE IS REAL, NOT COSMETIC: a forced negative-control
#      mutation of a COPY flips the gate --
#         ml-eval       : below-baseline model  => process exit 1
#         scraper       : a required field nulled (rowcount still 3/3) => exit 1
#                         (proves "N rows scraped" alone is never sufficient)
#         data-pipeline : broken transform => VERDICT flips GREEN->RED AND
#                         process exit flips 0->1 (the S1-fix cashed this
#                         fixture's verdict out to the exit code, matching the
#                         ML/scraper standard)
#   G  the real source fixtures are byte-identical before and after the run
#      (the test only ever operates on COPIES -- it never mutates the skill)
#
# DEPENDENCIES: bash + shasum + python3 ONLY. No network. Fully deterministic.
#
# FIXTURE SOURCE RESOLUTION (in order):
#   1. $GF_FIXTURE_DIR (if it contains all three fixture_*.py)  -- source=REAL
#   2. the default scratch path below                           -- source=REAL
#   3. byte-exact EMBEDDED base64 copies (this file is self-contained) -- EMBED
#
# EXIT: 0 = all assertions pass (GREEN).  non-zero = a regression (RED).
# =============================================================================
set -u

DEFAULT_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fixtures/m2-synth"
SRC="${GF_FIXTURE_DIR:-$DEFAULT_SRC}"

FIX_ML="fixture_ml-eval.py"
FIX_DP="fixture_data-pipeline.py"
FIX_SC="fixture_scraper.py"

fails=0
pass() { printf '  PASS  %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; fails=$((fails+1)); }
hr()   { printf -- '----------------------------------------------------------------------\n'; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/gf-m2-test.XXXXXX")" || { echo "cannot mktemp"; exit 2; }
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# ---------------------------------------------------------------------------
# EMBEDDED byte-exact fallbacks (base64). Used only when no real source found.
# ---------------------------------------------------------------------------
read -r -d '' B64_ML <<'B64ML' || true
IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMwojIE1MLUVWQUwgZXZpZGVuY2UgZml4dHVyZSDigJQgUFVSRSBweXRob24zLCBOTyBza2xlYXJuLCBOTyBuZXR3b3JrLCBmdWxseSBkZXRlcm1pbmlzdGljLgojIEdyb3VuZGluZzogc2Npa2l0LWxlYXJuIG1vZGVsX2V2YWx1YXRpb24gKGNsYXNzaWZpY2F0aW9uX3JlcG9ydCAvIGNvbmZ1c2lvbl9tYXRyaXgucmF2ZWwoKS0+dG4sZnAsZm4sdHAKIyAgICAgICAgICAgIC8gRHVtbXlDbGFzc2lmaWVyIGJhc2VsaW5lKSArIE1vZGVsIENhcmRzLCBhclhpdjoxODEwLjAzOTkzIChkaXNhZ2dyZWdhdGVkIHBlci1ncm91cCByZXBvcnQpLgojIEFudGktR29vZGhhcnQ6IGEgbG9uZSBhY2N1cmFjeSBzY2FsYXIgaXMgTk9UIHN1ZmZpY2llbnQg4oCUIHdlIGVtaXQgcGVyLWNsYXNzIFAvUi9GMSwgcmF3IFROL0ZQL0ZOL1RQLAojIGEgZGlzYWdncmVnYXRlZCAocGVyLWdyb3VwKSBzbGljZSwgQU5EIGEgbW9zdF9mcmVxdWVudCBiYXNlbGluZSB0aGUgbW9kZWwgbXVzdCBiZWF0LgojIE1BQ0hJTkUgVFJJUFdJUkU6IHRoZSBiYXNlbGluZS1iZWF0IGdhdGUgaXMgZW5mb3JjZWQgYnkgcHJvY2VzcyBleGl0IGNvZGUgKDA9YmVhdHMgYmFzZWxpbmUsCiMgMT1kb2VzIG5vdCkg4oCUIG5vdCBqdXN0IGEgcHJpbnRlZCBzZW50ZW5jZSBhIHN1Ym1pdHRlci9qdXJvciBjb3VsZCBza2ltIHBhc3QuIEEgSjEgcmUtcnVubmVyCiMgY2hlY2tzIGBlY2hvICQ/YCwgbm90IHByb3NlLgppbXBvcnQgc3lzCgpTRUVEID0gNDIgICMgSU5MSU5FIGZpeGVkIHNlZWQg4oCUIHRocmVhZHMgdGhyb3VnaCBCT1RIIHRoZSBzcGxpdCBBTkQgdGhlIGVzdGltYXRvcjsgY2hhbmdlIGl0ID0+IGV2ZXJ5IG51bWJlciBtb3Zlcy4KCmRlZiBsY2coc2VlZCk6CiAgICAjIE51bWVyaWNhbCBSZWNpcGVzIExDRzogZGV0ZXJtaW5pc3RpYyBQUk5HLCB6ZXJvIGltcG9ydHMuCiAgICBzdGF0ZSA9IHNlZWQgJiAweEZGRkZGRkZGCiAgICB3aGlsZSBUcnVlOgogICAgICAgIHN0YXRlID0gKDE2NjQ1MjUgKiBzdGF0ZSArIDEwMTM5MDQyMjMpICYgMHhGRkZGRkZGRgogICAgICAgIHlpZWxkIHN0YXRlIC8gMHgxMDAwMDAwMDAKCmRlZiBtYWtlX2RhdGFzZXQobiwgc2VlZCk6CiAgICBybmcgPSBsY2coc2VlZCkKICAgIFgsIHksIGdyb3VwID0gW10sIFtdLCBbXQogICAgZm9yIF8gaW4gcmFuZ2Uobik6CiAgICAgICAgZiA9IG5leHQocm5nKQogICAgICAgIGxhYmVsID0gMSBpZiBmID4gMC41NSBlbHNlIDAgICAgICAgICAgICAjIGdyb3VuZC10cnV0aCBnZW5lcmF0aXZlIHJ1bGUKICAgICAgICBub2lzZSA9IG5leHQocm5nKQogICAgICAgIGZlYXQgPSBmIGlmIG5vaXNlID4gMC4yMCBlbHNlIDEuMCAtIGYgICAjIGxhYmVsLWNvcnJlbGF0ZWQgYnV0IG5vaXN5IGZlYXR1cmUKICAgICAgICBnID0gJ0EnIGlmIG5leHQocm5nKSA+IDAuNSBlbHNlICdCJyAgICAgICMgYSBwcm90ZWN0ZWQvc3ViZ3JvdXAgYXhpcyAoTW9kZWwgQ2FyZHMpCiAgICAgICAgWC5hcHBlbmQoZmVhdCk7IHkuYXBwZW5kKGxhYmVsKTsgZ3JvdXAuYXBwZW5kKGcpCiAgICByZXR1cm4gWCwgeSwgZ3JvdXAKCmRlZiBzcGxpdChYLCB5LCBncm91cCwgc2VlZCwgdGVzdF9mcmFjPTAuNDApOgogICAgIyBzZWVkZWQgRmlzaGVyLVlhdGVzIHNodWZmbGUtc3BsaXQgPT0gdHJhaW5fdGVzdF9zcGxpdChyYW5kb21fc3RhdGU9U0VFRCkKICAgIHJuZyA9IGxjZyhzZWVkIF4gMHg1REVFQ0U2NikKICAgIGlkeCA9IGxpc3QocmFuZ2UobGVuKFgpKSkKICAgIGZvciBpIGluIHJhbmdlKGxlbihpZHgpIC0gMSwgMCwgLTEpOgogICAgICAgIGogPSBpbnQobmV4dChybmcpICogKGkgKyAxKSkKICAgICAgICBpZHhbaV0sIGlkeFtqXSA9IGlkeFtqXSwgaWR4W2ldCiAgICBjdXQgPSBpbnQobGVuKFgpICogKDEgLSB0ZXN0X2ZyYWMpKQogICAgdHIsIHRlID0gaWR4WzpjdXRdLCBpZHhbY3V0Ol0KICAgIHBhY2sgPSBsYW1iZGEgaXg6IChbWFtpXSBmb3IgaSBpbiBpeF0sIFt5W2ldIGZvciBpIGluIGl4XSwgW2dyb3VwW2ldIGZvciBpIGluIGl4XSkKICAgIHJldHVybiBwYWNrKHRyKSwgcGFjayh0ZSkKCmRlZiBmaXRfdGhyZXNob2xkKFh0ciwgeXRyLCBzZWVkKToKICAgICMgImVzdGltYXRvciI6IHBpY2sgdHJhaW4tYWNjdXJhY3ktbWF4aW1pemluZyB0aHJlc2hvbGQ7IHNlZWRlZCBzY2FuIG9yZGVyLCBzdHJpY3QtaW1wcm92ZW1lbnQgdGllLWJyZWFrLgogICAgcm5nID0gbGNnKHNlZWQgXiAweEFCQ0QpCiAgICBvcmRlciA9IHNvcnRlZChyYW5nZSgxLCAyMCksIGtleT1sYW1iZGEgazogbmV4dChybmcpKSAgIyBzZWVkZWQsIGRldGVybWluaXN0aWMgc2NhbiBvcmRlcgogICAgYmVzdF90LCBiZXN0X2FjYyA9IDAuNSwgLTEuMAogICAgZm9yIGsgaW4gb3JkZXI6CiAgICAgICAgdCA9IGsgLyAyMC4wCiAgICAgICAgYWNjID0gc3VtKDEgZm9yIHgsIHl5IGluIHppcChYdHIsIHl0cikgaWYgKDEgaWYgeCA+PSB0IGVsc2UgMCkgPT0geXkpIC8gbGVuKHl0cikKICAgICAgICBpZiBhY2MgPiBiZXN0X2FjYzogICAgICAgICAgICAgICAgICAgICAgICMgc3RyaWN0ICc+JyA9PiBkZXRlcm1pbmlzdGljIHdpbm5lcgogICAgICAgICAgICBiZXN0X2FjYywgYmVzdF90ID0gYWNjLCB0CiAgICByZXR1cm4gYmVzdF90CgpkZWYgcHJlZGljdChYLCB0KToKICAgIHJldHVybiBbMSBpZiB4ID49IHQgZWxzZSAwIGZvciB4IGluIFhdCgpkZWYgY29uZnVzaW9uKHlfdHJ1ZSwgeV9wcmVkKToKICAgIHRuID0gZnAgPSBmbiA9IHRwID0gMAogICAgZm9yIGEsIHAgaW4gemlwKHlfdHJ1ZSwgeV9wcmVkKToKICAgICAgICBpZiAgIGEgPT0gMCBhbmQgcCA9PSAwOiB0biArPSAxCiAgICAgICAgZWxpZiBhID09IDAgYW5kIHAgPT0gMTogZnAgKz0gMQogICAgICAgIGVsaWYgYSA9PSAxIGFuZCBwID09IDA6IGZuICs9IDEKICAgICAgICBlbHNlOiAgICAgICAgICAgICAgICAgICB0cCArPSAxCiAgICByZXR1cm4gdG4sIGZwLCBmbiwgdHAKCmRlZiBwcmYodHAsIGZwLCBmbik6CiAgICBwID0gdHAgLyAodHAgKyBmcCkgaWYgKHRwICsgZnApIGVsc2UgMC4wCiAgICByID0gdHAgLyAodHAgKyBmbikgaWYgKHRwICsgZm4pIGVsc2UgMC4wCiAgICBmID0gMiAqIHAgKiByIC8gKHAgKyByKSBpZiAocCArIHIpIGVsc2UgMC4wCiAgICByZXR1cm4gcCwgciwgZgoKZGVmIGFjY3VyYWN5KHlfdHJ1ZSwgeV9wcmVkKToKICAgIHJldHVybiBzdW0oMSBmb3IgYSwgcCBpbiB6aXAoeV90cnVlLCB5X3ByZWQpIGlmIGEgPT0gcCkgLyBsZW4oeV90cnVlKQoKIyAtLS0gcGlwZWxpbmUgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KWCwgeSwgZ3JvdXAgPSBtYWtlX2RhdGFzZXQoMjAwLCBTRUVEKQooWHRyLCB5dHIsIF9ndHIpLCAoWHRlLCB5dGUsIGd0ZSkgPSBzcGxpdChYLCB5LCBncm91cCwgU0VFRCkKdCA9IGZpdF90aHJlc2hvbGQoWHRyLCB5dHIsIFNFRUQpCnlwID0gcHJlZGljdChYdGUsIHQpCgp0biwgZnAsIGZuLCB0cCA9IGNvbmZ1c2lvbih5dGUsIHlwKQojIHBlci1jbGFzczogY2xhc3MgMSB1c2VzICh0cCxmcCxmbik7IGNsYXNzIDAgaXMgaXRzIG1pcnJvciAodG4gYXMgaXRzIHRwLCBmbiBhcyBpdHMgZnAsIGZwIGFzIGl0cyBmbikKcDEsIHIxLCBmMSA9IHByZih0cCwgZnAsIGZuKQpwMCwgcjAsIGYwID0gcHJmKHRuLCBmbiwgZnApCnN1cHBvcnQwID0gdG4gKyBmcApzdXBwb3J0MSA9IGZuICsgdHAKYWNjID0gYWNjdXJhY3koeXRlLCB5cCkKbWFjcm9fcCA9IChwMCArIHAxKSAvIDI7IG1hY3JvX3IgPSAocjAgKyByMSkgLyAyOyBtYWNyb19mID0gKGYwICsgZjEpIC8gMgoKIyBiYXNlbGluZTogRHVtbXlDbGFzc2lmaWVyKHN0cmF0ZWd5PSdtb3N0X2ZyZXF1ZW50JykgZml0IG9uIFRSQUlOLCBzY29yZWQgb24gVEVTVAptYWpvcml0eSA9IDEgaWYgc3VtKHl0cikgKiAyID49IGxlbih5dHIpIGVsc2UgMApiYXNlX3ByZWQgPSBbbWFqb3JpdHldICogbGVuKHl0ZSkKYmFzZV9hY2MgPSBhY2N1cmFjeSh5dGUsIGJhc2VfcHJlZCkKCiMgLS0tIGV2aWRlbmNlIGJsb2NrIChwYXN0ZWFibGUsIGlkZW50aWNhbCBldmVyeSBydW4pIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCnByaW50KGYiU0VFRD17U0VFRH0gIHNwbGl0PXRyYWluX3Rlc3Rfc3BsaXQodGVzdD0wLjQwLCByYW5kb21fc3RhdGU9U0VFRCkgIGVzdGltYXRvcj10aHJlc2hvbGRAe3Q6LjJmfSIpCnByaW50KCI9PSBjbGFzc2lmaWNhdGlvbl9yZXBvcnQgKGhlbGQtb3V0IHRlc3QpID09IikKcHJpbnQoIiAgICAgICAgICAgICAgcHJlY2lzaW9uICAgIHJlY2FsbCAgZjEtc2NvcmUgICBzdXBwb3J0IikKcHJpbnQoZiIgICAgIGNsYXNzIDAgICAgICB7cDA6LjJmfSAgICAgIHtyMDouMmZ9ICAgICAge2YwOi4yZn0gICAgICB7c3VwcG9ydDA6PjR9IikKcHJpbnQoZiIgICAgIGNsYXNzIDEgICAgICB7cDE6LjJmfSAgICAgIHtyMTouMmZ9ICAgICAge2YxOi4yZn0gICAgICB7c3VwcG9ydDE6PjR9IikKcHJpbnQoIiIpCnByaW50KGYiICAgIGFjY3VyYWN5ICAgICAgICAgICAgICAgICAgICAgICAgICB7YWNjOi4yZn0gICAgICB7bGVuKHl0ZSk6PjR9IikKcHJpbnQoZiIgICBtYWNybyBhdmcgICAgICB7bWFjcm9fcDouMmZ9ICAgICAge21hY3JvX3I6LjJmfSAgICAgIHttYWNyb19mOi4yZn0gICAgICB7bGVuKHl0ZSk6PjR9IikKcHJpbnQoIj09IGNvbmZ1c2lvbl9tYXRyaXgucmF2ZWwoKSAtPiAodG4sIGZwLCBmbiwgdHApID09IikKcHJpbnQoZiJ0bj17dG59ICBmcD17ZnB9ICBmbj17Zm59ICB0cD17dHB9IikKcHJpbnQoIj09IGRpc2FnZ3JlZ2F0ZWQgYWNjdXJhY3kgKE1vZGVsIENhcmRzIHBlci1ncm91cCBzbGljZSkgPT0iKQpmb3IgZ3ZhbCBpbiAoJ0EnLCAnQicpOgogICAgaWR4ID0gW2kgZm9yIGksIGdnIGluIGVudW1lcmF0ZShndGUpIGlmIGdnID09IGd2YWxdCiAgICBnYSA9IGFjY3VyYWN5KFt5dGVbaV0gZm9yIGkgaW4gaWR4XSwgW3lwW2ldIGZvciBpIGluIGlkeF0pIGlmIGlkeCBlbHNlIDAuMAogICAgcHJpbnQoZiJncm91cCB7Z3ZhbH06IGFjYz17Z2E6LjJmfSAgbj17bGVuKGlkeCl9IikKcHJpbnQoIj09IGJhc2VsaW5lIGdhdGUgKER1bW15Q2xhc3NpZmllciBtb3N0X2ZyZXF1ZW50KSA9PSIpCmJlYXRzX2Jhc2VsaW5lID0gYWNjID4gYmFzZV9hY2MKcHJpbnQoZiJtb2RlbF9hY2M9e2FjYzouMmZ9ICBiYXNlbGluZV9hY2M9e2Jhc2VfYWNjOi4yZn0gIGxpZnQ9e2FjYyAtIGJhc2VfYWNjOisuMmZ9ICAiCiAgICAgIGYiQkVBVFNfQkFTRUxJTkU9e2JlYXRzX2Jhc2VsaW5lfSIpCnN5cy5leGl0KDAgaWYgYmVhdHNfYmFzZWxpbmUgZWxzZSAxKSAgIyBub24temVybyBleGl0ID09IGZhbHNpZmlhYmxlIGFudGktR29vZGhhcnQgdHJpcHdpcmUK
B64ML

read -r -d '' B64_DP <<'B64DP' || true
aW1wb3J0IHN5cwojIS91c3IvYmluL2VudiBweXRob24zCiMgRGF0YS1jb250cmFjdCBldmlkZW5jZSBnZW5lcmF0b3IgKHB1cmUgcHl0aG9uMywgbm8gZGJ0L0dFL25ldHdvcmspLgojIE1pcnJvcnMgZGJ0IGBkYnQgdGVzdGAgcGVyLWFzc2VydGlvbiBwYXNzL2ZhaWwgKyByb3ctY291bnQgZGVsdGEgKyBvdXRwdXQKIyBjaGVja3N1bSArIHJlcnVuLWRldGVybWluaXNtLiBEZXRlcm1pbmlzdGljOiBpZGVudGljYWwgYnl0ZXMgZXZlcnkgcnVuLgppbXBvcnQgaGFzaGxpYgoKIyAtLS0gRml4ZWQgaW4tbWVtb3J5IHNvdXJjZSB0YWJsZTogcmF3X29yZGVycyhvcmRlcl9pZCwgY3VzdG9tZXJfaWQsIHN0YXR1cykgLS0tClJBVyA9IFsKICAgICgxLCAiQzEiLCAic2hpcHBlZCIpLAogICAgKDIsICJDMiIsICJwZW5kaW5nIiksCiAgICAoMiwgIkMyIiwgInBlbmRpbmciKSwgICAgIyBkdXBsaWNhdGUgb3JkZXJfaWQKICAgICgzLCAiQzMiLCAiZGVsaXZlcmVkIiksCiAgICAoNCwgTm9uZSwgInNoaXBwZWQiKSwgICAgIyBudWxsIGN1c3RvbWVyX2lkCiAgICAoNSwgIkM1IiwgImJvZ3VzIiksICAgICAgIyBpbnZhbGlkIHN0YXR1cwpdCkFDQ0VQVEVEX1NUQVRVUyA9ICgic2hpcHBlZCIsICJwZW5kaW5nIiwgImRlbGl2ZXJlZCIpCgojIC0tLSBUcmFuc2Zvcm0gdW5kZXIgdGVzdDogZHJvcCBudWxsIGN1c3RvbWVyLCBkcm9wIGludmFsaWQgc3RhdHVzLCBkZWR1cCBpZCAtLS0KZGVmIHRyYW5zZm9ybShyb3dzKToKICAgIHNlZW4sIG91dCA9IHNldCgpLCBbXQogICAgZm9yIG9pZCwgY3VzdCwgc3RhdHVzIGluIHJvd3M6CiAgICAgICAgaWYgY3VzdCBpcyBOb25lOgogICAgICAgICAgICBjb250aW51ZQogICAgICAgIGlmIHN0YXR1cyBub3QgaW4gQUNDRVBURURfU1RBVFVTOgogICAgICAgICAgICBjb250aW51ZQogICAgICAgIGlmIG9pZCBpbiBzZWVuOgogICAgICAgICAgICBjb250aW51ZQogICAgICAgIHNlZW4uYWRkKG9pZCkKICAgICAgICBvdXQuYXBwZW5kKChvaWQsIGN1c3QsIHN0YXR1cykpCiAgICByZXR1cm4gb3V0CgojIC0tLSBEZWNsYXJhdGl2ZSBkYXRhLWNvbnRyYWN0IHJ1bm5lcjogbmFtZWQgZ2VuZXJpYyBhc3NlcnRpb25zIC0+IGZhaWxpbmcgcm93cyAtLS0KZGVmIG5vdF9udWxsKHJvd3MsIGNvbCk6CiAgICByZXR1cm4gc3VtKDEgZm9yIHIgaW4gcm93cyBpZiByW2NvbF0gaXMgTm9uZSkKCmRlZiB1bmlxdWUocm93cywgY29sKToKICAgIHZhbHMgPSBbcltjb2xdIGZvciByIGluIHJvd3NdCiAgICByZXR1cm4gbGVuKHZhbHMpIC0gbGVuKHNldCh2YWxzKSkKCmRlZiBhY2NlcHRlZF92YWx1ZXMocm93cywgY29sLCBhbGxvd2VkKToKICAgIHJldHVybiBzdW0oMSBmb3IgciBpbiByb3dzIGlmIHJbY29sXSBub3QgaW4gYWxsb3dlZCkKCmRlZiBydW5fY29udHJhY3Qocm93cyk6CiAgICBjaGVja3MgPSBbCiAgICAgICAgKCJub3RfbnVsbChjdXN0b21lcl9pZCkiLCBub3RfbnVsbChyb3dzLCAxKSksCiAgICAgICAgKCJ1bmlxdWUob3JkZXJfaWQpIiwgICAgICB1bmlxdWUocm93cywgMCkpLAogICAgICAgICgiYWNjZXB0ZWRfdmFsdWVzKHN0YXR1cykiLCBhY2NlcHRlZF92YWx1ZXMocm93cywgMiwgQUNDRVBURURfU1RBVFVTKSksCiAgICBdCiAgICByZXR1cm4gY2hlY2tzCgpkZWYgc3VtbWFyaXplKGNoZWNrcyk6CiAgICBwID0gc3VtKDEgZm9yIF8sIGYgaW4gY2hlY2tzIGlmIGYgPT0gMCkKICAgIGZsID0gc3VtKDEgZm9yIF8sIGYgaW4gY2hlY2tzIGlmIGYgIT0gMCkKICAgIHJldHVybiBwLCBmbAoKZGVmIHNhbXBsZV9jaGVja3N1bShyb3dzKToKICAgICMgY2Fub25pY2FsIHNlcmlhbGl6YXRpb24gb2Ygb3V0cHV0IHNhbXBsZSwgb3JkZXItaW5kZXBlbmRlbnQKICAgIGNhbm9uID0gIlxuIi5qb2luKHJlcHIocikgZm9yIHIgaW4gc29ydGVkKHJvd3MpKQogICAgcmV0dXJuIGhhc2hsaWIuc2hhMjU2KGNhbm9uLmVuY29kZSgidXRmLTgiKSkuaGV4ZGlnZXN0KCkKCiMgLS0tIEV2aWRlbmNlIGVtaXNzaW9uIChwYXN0ZWFibGUsIGhhc2gtY2hhaW4tZnJpZW5kbHkpIC0tLQpiZWZvcmUgPSBsZW4oUkFXKQpjbGVhbiA9IHRyYW5zZm9ybShSQVcpCmFmdGVyID0gbGVuKGNsZWFuKQoKdGFyZ2V0X2NoZWNrcyA9IHJ1bl9jb250cmFjdChjbGVhbikKcCwgZmwgPSBzdW1tYXJpemUodGFyZ2V0X2NoZWNrcykKCiMgTkVHQVRJVkUgQ09OVFJPTDogc2FtZSBhc3NlcnRpb25zIG9uIFJBVyBtdXN0IEZBSUwsIHByb3ZpbmcgdGhleSBkaXNjcmltaW5hdGUKcmF3X2NoZWNrcyA9IHJ1bl9jb250cmFjdChSQVcpCnJwLCByZmwgPSBzdW1tYXJpemUocmF3X2NoZWNrcykKCiMgUkVSVU4tREVURVJNSU5JU006IHJlY29tcHV0ZSBjaGVja3N1bSBvbiBhIHNlY29uZCB0cmFuc2Zvcm0gcGFzcwpjaGsxID0gc2FtcGxlX2NoZWNrc3VtKGNsZWFuKQpjaGsyID0gc2FtcGxlX2NoZWNrc3VtKHRyYW5zZm9ybShSQVcpKQoKcHJpbnQoIj09IGRhdGEtY29udHJhY3QgZXZpZGVuY2UgKG1vZGVsOiBzdGdfb3JkZXJzKSA9PSIpCmZvciBuYW1lLCBmYWlsaW5nIGluIHRhcmdldF9jaGVja3M6CiAgICBwcmludCgiICAlLTI0cyAlLTRzIGZhaWxpbmdfcm93cz0lZCIgJSAobmFtZSwgIlBBU1MiIGlmIGZhaWxpbmcgPT0gMCBlbHNlICJGQUlMIiwgZmFpbGluZykpCnByaW50KCJEb25lLiBQQVNTPSVkIEZBSUw9JWQgVE9UQUw9JWQiICUgKHAsIGZsLCBsZW4odGFyZ2V0X2NoZWNrcykpKQpwcmludCgicm93X2NvdW50ICBiZWZvcmU9JWQgIGFmdGVyPSVkICBkZWx0YT0lZCIgJSAoYmVmb3JlLCBhZnRlciwgYWZ0ZXIgLSBiZWZvcmUpKQpwcmludCgib3V0cHV0X3NhbXBsZV9zaGEyNTY9JXMiICUgY2hrMSkKcHJpbnQoInJlcnVuX2RldGVybWluaXNtICBtYXRjaD0lcyIgJSAoInRydWUiIGlmIGNoazEgPT0gY2hrMiBlbHNlICJmYWxzZSIpKQpwcmludCgibmVnYXRpdmVfY29udHJvbChyYXcpICBQQVNTPSVkIEZBSUw9JWQgIChleHBlY3QgRkFJTD4wKSIgJSAocnAsIHJmbCkpCmdyZWVuID0gKGZsID09IDAgYW5kIGNoazEgPT0gY2hrMiBhbmQgcmZsID4gMCkKcHJpbnQoIlZFUkRJQ1Q9JXMiICUgKCJHUkVFTiIgaWYgZ3JlZW4gZWxzZSAiUkVEIikpCnN5cy5leGl0KDAgaWYgZ3JlZW4gZWxzZSAxKSAgIyBTMS1maXg6IHRyaXB3aXJlIGNhc2hlcyBvdXQgdG8gRVhJVCBDT0RFIChNTC9zY3JhcGVyIHN0YW5kYXJkKSDigJQgSjEgY2hlY2tzICQ/LCBub3QgcHJvc2UK
B64DP

read -r -d '' B64_SC <<'B64SC' || true
IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMwojIERldGVybWluaXN0aWMgQ0FDSEVELWZpeHR1cmUgc2NyYXBlIHBhcnNlICsgZmllbGQtY29tcGxldGVuZXNzL3NjaGVtYSBnYXRlLgojIFB1cmUgc3RkbGliIChodG1sLnBhcnNlcikuIE5vIG5ldHdvcmssIG5vIGV4dGVybmFsIGRlcHMsIG5vIHJhbmRvbS9kYXRlLiBCeXRlLXJlcHJvZHVjaWJsZS4KIyBNaXJyb3JzIFNjcmFweSBjb250cmFjdCBzZW1hbnRpY3MgKHNjcmFweSBOT1QgaW5zdGFsbGVkIGluIHRoaXMgZW52IC0+IHB1cmUtcHl0aG9uIG1pcnJvcjsKIyBhIHJlYWwgcnVuIHJlcGxhY2VzIHRoaXMgc2NyaXB0J3MgcGFyc2Ugc3RlcCB3aXRoIGBzY3JhcHkgY2hlY2tgLCB3aGljaCBlbWl0cyB0aGUgc2FtZQojIHBlci1jYWxsYmFjayBPSy9GQUlMIHNoYXBlIGZyb20gdGhlIGlkZW50aWNhbCBAc2NyYXBlcy9AcmV0dXJucyBkaXJlY3RpdmVzIGJlbG93KS4KaW1wb3J0IHN5cwpmcm9tIGh0bWwucGFyc2VyIGltcG9ydCBIVE1MUGFyc2VyCgojIC0tLSBDQUNIRUQgZml4dHVyZTogSFRNTCBzYXZlZCBhdCBmZXRjaC10aW1lLCBwYXJzZWQgT0ZGTElORSBzbyBKMSByZS1ydW4gaXMgYnl0ZS1pZGVudGljYWwgLS0tCkNBQ0hFRF9IVE1MID0gIiIiXAo8dWwgY2xhc3M9ImNhdGFsb2ciPgogIDxsaSBjbGFzcz0iYm9vayI+PGgzIGNsYXNzPSJ0aXRsZSI+QSBMaWdodCBpbiB0aGUgQXR0aWM8L2gzPjxwIGNsYXNzPSJwcmljZSI+NTEuNzc8L3A+PHAgY2xhc3M9ImF2YWlsIj5JbiBzdG9jazwvcD48L2xpPgogIDxsaSBjbGFzcz0iYm9vayI+PGgzIGNsYXNzPSJ0aXRsZSI+VGlwcGluZyB0aGUgVmVsdmV0PC9oMz48cCBjbGFzcz0icHJpY2UiPjUzLjc0PC9wPjxwIGNsYXNzPSJhdmFpbCI+SW4gc3RvY2s8L3A+PC9saT4KICA8bGkgY2xhc3M9ImJvb2siPjxoMyBjbGFzcz0idGl0bGUiPlNvdW1pc3Npb248L2gzPjxwIGNsYXNzPSJwcmljZSI+NTAuMTA8L3A+PHAgY2xhc3M9ImF2YWlsIj5JbiBzdG9jazwvcD48L2xpPgo8L3VsPgoiIiIKCiMgQ29udHJhY3QgUFJFLVJFR0lTVEVSRUQgYmVmb3JlIHRoZSBjcmF3bCAoc3BpZGVyIGRvY3N0cmluZyksIE5PVCBmaXR0ZWQgdG8gdGhpcyBzYW1wbGUgYWZ0ZXIKIyB0aGUgZmFjdCAtLSB0aGlzIGlzIHdoYXQgbWFrZXMgdGhlIGNvdW50L2ZpZWxkIGNoZWNrIGEgcmVhbCB0cmlwd2lyZSBpbnN0ZWFkIG9mIGEgdGF1dG9sb2d5OgojICAgQHNjcmFwZXMgdGl0bGUgcHJpY2UgYXZhaWwgICAoZXZlcnkgcm93IG11c3QgY2FycnkgdGhlc2UgdGhyZWUgZmllbGRzLCBub24tbnVsbCkKIyAgIEByZXR1cm5zIGl0ZW1zIDMgMyAgICAgICAgICAgKGV4YWN0bHkgMyByb3dzIGV4cGVjdGVkIG9uIHRoaXMgVVJMKQpSRVFVSVJFRCA9ICgidGl0bGUiLCAicHJpY2UiLCAiYXZhaWwiKQpFWFBFQ1RFRCA9IDMKCmNsYXNzIEJvb2tQYXJzZXIoSFRNTFBhcnNlcik6CiAgICBkZWYgX19pbml0X18oc2VsZik6CiAgICAgICAgc3VwZXIoKS5fX2luaXRfXygpCiAgICAgICAgc2VsZi5yb3dzID0gW10KICAgICAgICBzZWxmLmZpZWxkID0gTm9uZQogICAgZGVmIGhhbmRsZV9zdGFydHRhZyhzZWxmLCB0YWcsIGF0dHJzKToKICAgICAgICBjbHMgPSBkaWN0KGF0dHJzKS5nZXQoImNsYXNzIiwgIiIpCiAgICAgICAgaWYgdGFnID09ICJsaSIgYW5kIGNscyA9PSAiYm9vayI6CiAgICAgICAgICAgIHNlbGYucm93cy5hcHBlbmQoe30pCiAgICAgICAgZWxpZiBjbHMgaW4gUkVRVUlSRUQgYW5kIHNlbGYucm93czoKICAgICAgICAgICAgc2VsZi5maWVsZCA9IGNscwogICAgZGVmIGhhbmRsZV9kYXRhKHNlbGYsIGRhdGEpOgogICAgICAgIGlmIHNlbGYuZmllbGQgYW5kIHNlbGYucm93czoKICAgICAgICAgICAgdGV4dCA9IGRhdGEuc3RyaXAoKQogICAgICAgICAgICBpZiB0ZXh0OgogICAgICAgICAgICAgICAgc2VsZi5yb3dzWy0xXVtzZWxmLmZpZWxkXSA9IHRleHQKICAgIGRlZiBoYW5kbGVfZW5kdGFnKHNlbGYsIHRhZyk6CiAgICAgICAgaWYgdGFnIGluICgiaDMiLCAicCIpOgogICAgICAgICAgICBzZWxmLmZpZWxkID0gTm9uZQoKcGFyc2VyID0gQm9va1BhcnNlcigpCnBhcnNlci5mZWVkKENBQ0hFRF9IVE1MKQpyb3dzID0gcGFyc2VyLnJvd3MKCnByaW50KCJTQ1JBUEUgU0NIRU1BIENIRUNLIChjYWNoZWQgZml4dHVyZSwgb2ZmbGluZSBwYXJzZTsgc2NyYXB5IGFic2VudCAtPiBwdXJlLXB5dGhvbiBtaXJyb3IpIikKcHJpbnQoImZpeHR1cmU9Ym9va3MtY2F0YWxvZy0zICBjb250cmFjdChwcmUtcmVnaXN0ZXJlZCk9QHNjcmFwZXMgdGl0bGUgcHJpY2UgYXZhaWwgLyBAcmV0dXJucyBpdGVtcyAzIDMiKQoKIyAtLS0gRmllbGQtY29tcGxldGVuZXNzIC8gc2NoZW1hIGNoZWNrOiBwZXItZmllbGQgUEFTUy9GQUlMIGFjcm9zcyBhbGwgcm93cyAtLS0Kb2sgPSBUcnVlCmZvciBmIGluIFJFUVVJUkVEOgogICAgcHJlc2VudCA9IHN1bSgxIGZvciByIGluIHJvd3MgaWYgci5nZXQoZikpCiAgICBzdGF0dXMgPSAiUEFTUyIgaWYgcHJlc2VudCA9PSBFWFBFQ1RFRCBlbHNlICJGQUlMIgogICAgb2sgPSBvayBhbmQgc3RhdHVzID09ICJQQVNTIgogICAgcHJpbnQoIiAgZmllbGQgJS02cyBub24tbnVsbCAlZC8lZCAgJXMiICUgKGYsIHByZXNlbnQsIEVYUEVDVEVELCBzdGF0dXMpKQoKY291bnRfc3RhdHVzID0gIlBBU1MiIGlmIGxlbihyb3dzKSA9PSBFWFBFQ1RFRCBlbHNlICJGQUlMIgpvayA9IG9rIGFuZCBjb3VudF9zdGF0dXMgPT0gIlBBU1MiCnByaW50KCIgIHJvd2NvdW50ICAgJWQvJWQgICVzIiAlIChsZW4ocm93cyksIEVYUEVDVEVELCBjb3VudF9zdGF0dXMpKQoKIyAtLS0gRXRoaWNhbC9sZWdhbCBnYXRlOiB2YWx1ZXMgbXVzdCBiZSBwYXN0ZWQgZnJvbSB0aGUgc3BpZGVyJ3MgYWN0dWFsIHNldHRpbmdzLnB5IC8gY3Jhd2wKIyBsb2cgbGluZSAoIkNyYXdsZWQgTiBwYWdlcyAoYXQgTSBwYWdlcy9taW4pIiksIG5vdCBhc3NlcnRlZCBmcmVlLWZvcm0gLS0gc2hvd24gaGVyZSBhcyB0aGUKIyBkZWNsYXJlZCBzZXR0aW5ncyB0aGlzIGZpeHR1cmUncyAobWlycm9yZWQpIGNyYXdsIHdvdWxkIHJ1biB1bmRlci4KcHJpbnQoInJvYm90cy9yYXRlLWxpbWl0IChkZWNsYXJlZCBzZXR0aW5ncy5weSk6IFJPQk9UU1RYVF9PQkVZPVRydWUgIERPV05MT0FEX0RFTEFZPTFzICAiCiAgICAgICJVQT1TY3JhcHkvMi54ICgraHR0cHM6Ly9zY3JhcHkub3JnKSIpCgp2ZXJkaWN0ID0gIlBBU1MiIGlmIG9rIGVsc2UgIkZBSUwiCnByaW50KCJWRVJESUNUPSVzICAoTi1yb3dzLXNjcmFwZWQgYWxvbmUgaXMgTk9UIGV2aWRlbmNlOiBQQVNTIHJlcXVpcmVzIGV2ZXJ5IFJFUVVJUkVEIGZpZWxkICIKICAgICAgIm5vbi1udWxsIGluIEFMTCByb3dzIEFORCByb3djb3VudCA9PSBwcmUtcmVnaXN0ZXJlZCBFWFBFQ1RFRDsgcGFkZGluZyByb3dzIG9yIG51bGxpbmcgIgogICAgICAiYSBmaWVsZCBjYW5ub3QgZ2FtZSB0aGlzKSIgJSB2ZXJkaWN0KQpzeXMuZXhpdCgwIGlmIG9rIGVsc2UgMSkK
B64SC

# ---------------------------------------------------------------------------
# Materialize fixtures into WORK (COPIES only) + record source-integrity sha
# ---------------------------------------------------------------------------
SRC_SHA_BEFORE=""
if [ -f "$SRC/$FIX_ML" ] && [ -f "$SRC/$FIX_DP" ] && [ -f "$SRC/$FIX_SC" ]; then
  ORIGIN="REAL ($SRC)"
  cp "$SRC/$FIX_ML" "$WORK/$FIX_ML"
  cp "$SRC/$FIX_DP" "$WORK/$FIX_DP"
  cp "$SRC/$FIX_SC" "$WORK/$FIX_SC"
  SRC_SHA_BEFORE="$(shasum -a 256 "$SRC/$FIX_ML" "$SRC/$FIX_DP" "$SRC/$FIX_SC")"
else
  ORIGIN="EMBEDDED (base64 fallback; real source not found at $SRC)"
  printf '%s' "$B64_ML" | python3 -c 'import sys,base64;open(sys.argv[1],"wb").write(base64.b64decode(sys.stdin.read()))' "$WORK/$FIX_ML"
  printf '%s' "$B64_DP" | python3 -c 'import sys,base64;open(sys.argv[1],"wb").write(base64.b64decode(sys.stdin.read()))' "$WORK/$FIX_DP"
  printf '%s' "$B64_SC" | python3 -c 'import sys,base64;open(sys.argv[1],"wb").write(base64.b64decode(sys.stdin.read()))' "$WORK/$FIX_SC"
fi

# ---------------------------------------------------------------------------
# Runtime import blocker: bans external deps, then execs the fixture as __main__.
# SystemExit(N) from the fixture propagates -> the wrapper's exit code is N.
# ---------------------------------------------------------------------------
cat > "$WORK/_blocker.py" <<'PYEOF'
import sys
FORBIDDEN = {"sklearn","scrapy","dbt","numpy","pandas","great_expectations",
             "scipy","requests","torch","tensorflow","polars","matplotlib",
             "sqlalchemy","bs4","lxml","pytest"}
class _Block:
    def find_spec(self, name, path=None, target=None):
        if name.split(".", 1)[0] in FORBIDDEN:
            raise ImportError("BLOCKED-EXTERNAL-DEP:" + name)
        return None
sys.meta_path.insert(0, _Block())
target = sys.argv[1]
with open(target) as fh:
    code = compile(fh.read(), target, "exec")
sys.argv = [target]
exec(code, {"__name__": "__main__", "__file__": target})
PYEOF

# python one-liner: apply a literal string replacement to a file; exit 3 if the
# pattern was absent (so a drifted fixture produces a DISTINCT, honest failure
# rather than silently testing an unmutated file).
mutate() { # $1=file  $2=old  $3=new
  python3 - "$1" "$2" "$3" <<'PYEOF'
import sys
path, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(path).read()
if old not in s:
    sys.stderr.write("MUTATION-PATTERN-ABSENT\n"); sys.exit(3)
open(path, "w").write(s.replace(old, new))
PYEOF
}

# run a python file, capture stdout to $2 and stderr to $3, echo exit code
run_capture() { # $1=pyfile $2=out $3=err  -> prints exit code
  python3 "$1" >"$2" 2>"$3"; echo $?
}

echo "goal-forge M2 RECIPE-FIXTURES regression test"
echo "fixture source: $ORIGIN"
echo "workdir:        $WORK"
hr

# ===========================================================================
# ASSERTION A -- no forbidden external import (static, import statements only)
# ===========================================================================
echo "[A] dependency-free (static grep of import/from statements)"
FORBIDDEN_RE='^[[:space:]]*(import|from)[[:space:]]+(sklearn|scrapy|dbt|numpy|pandas|great_expectations|scipy|requests|torch|tensorflow|polars|matplotlib|sqlalchemy|bs4|lxml)([.[:space:]]|$)'
for f in "$FIX_ML" "$FIX_DP" "$FIX_SC"; do
  n=$(grep -Ec "$FORBIDDEN_RE" "$WORK/$f" || true)
  if [ "$n" = "0" ]; then pass "$f  forbidden-imports=0"
  else fail "$f  forbidden-imports=$n (expected 0)"; fi
done
hr

# ===========================================================================
# ASSERTION B/C -- byte-repro across two runs + legit exit 0 + GREEN verdict
# ===========================================================================
echo "[B/C] byte-reproducible (2 runs) + legit exit 0 + GREEN verdict token"

ml_r1=$(run_capture "$WORK/$FIX_ML" "$WORK/ml.o1" "$WORK/ml.e1")
ml_r2=$(run_capture "$WORK/$FIX_ML" "$WORK/ml.o2" "$WORK/ml.e2")
dp_r1=$(run_capture "$WORK/$FIX_DP" "$WORK/dp.o1" "$WORK/dp.e1")
dp_r2=$(run_capture "$WORK/$FIX_DP" "$WORK/dp.o2" "$WORK/dp.e2")
sc_r1=$(run_capture "$WORK/$FIX_SC" "$WORK/sc.o1" "$WORK/sc.e1")
sc_r2=$(run_capture "$WORK/$FIX_SC" "$WORK/sc.o2" "$WORK/sc.e2")

check_repro() { # $1=label $2=o1 $3=o2
  if [ ! -s "$2" ]; then fail "$1 byte-repro: empty stdout"; return; fi
  if cmp -s "$2" "$3"; then pass "$1 byte-repro: 2 runs identical (sha $(shasum -a256 "$2" | cut -c1-16))"
  else fail "$1 byte-repro: runs DIFFER (non-deterministic)"; fi
}
check_repro "ml-eval      " "$WORK/ml.o1" "$WORK/ml.o2"
check_repro "data-pipeline" "$WORK/dp.o1" "$WORK/dp.o2"
check_repro "scraper      " "$WORK/sc.o1" "$WORK/sc.o2"

check_legit() { # $1=label $2=r1 $3=r2 $4=out $5=needle
  if [ "$2" = "0" ] && [ "$3" = "0" ]; then pass "$1 legit exit 0/0"
  else fail "$1 legit exit $2/$3 (expected 0/0)"; fi
  if grep -qF "$5" "$4"; then pass "$1 GREEN token present: '$5'"
  else fail "$1 GREEN token MISSING: '$5'"; fi
}
check_legit "ml-eval      " "$ml_r1" "$ml_r2" "$WORK/ml.o1" "BEATS_BASELINE=True"
check_legit "data-pipeline" "$dp_r1" "$dp_r2" "$WORK/dp.o1" "VERDICT=GREEN"
check_legit "scraper      " "$sc_r1" "$sc_r2" "$WORK/sc.o1" "VERDICT=PASS"

# data-pipeline's own built-in discriminator: the SAME assertions must FAIL on RAW
if grep -qE 'negative_control\(raw\)  PASS=0 FAIL=[1-9]' "$WORK/dp.o1"; then
  pass "data-pipeline built-in negative_control shows FAIL>0 on raw input"
else fail "data-pipeline built-in negative_control did not show FAIL>0"; fi
hr

# ===========================================================================
# ASSERTION D -- runtime dependency-free proof (import blocker) + output parity
# Running under the blocker (which bans sklearn/scrapy/dbt/...) must produce the
# SAME exit code AND the SAME stdout as the plain run: the fixture never even
# touches a forbidden module. If it did, the blocker would raise ImportError.
# ===========================================================================
echo "[D] runtime dependency-free (external-import blocker) + output parity"
run_blocked() { # $1=label $2=fixture $3=plain_exit $4=plain_out
  python3 "$WORK/_blocker.py" "$WORK/$2" >"$WORK/blk.o" 2>"$WORK/blk.e"; be=$?
  if [ "$be" = "$3" ] && cmp -s "$WORK/blk.o" "$4"; then
    pass "$1 runs clean under import-blocker (exit=$be, stdout parity)"
  else
    fail "$1 blocker mismatch: exit=$be(vs $3); $(head -1 "$WORK/blk.e")"
  fi
}
run_blocked "ml-eval      " "$FIX_ML" "$ml_r1" "$WORK/ml.o1"
run_blocked "data-pipeline" "$FIX_DP" "$dp_r1" "$WORK/dp.o1"
run_blocked "scraper      " "$FIX_SC" "$sc_r1" "$WORK/sc.o1"
hr

# ===========================================================================
# ASSERTION E -- ANTI-GOODHART TRIPWIRE IS REAL, NOT COSMETIC
# Force each fixture's gate to FAIL on a COPY and confirm the machine signal
# flips. legit(pass)->0 vs forced(fail)->1 on the SAME script proves the exit
# code is a FUNCTION of the gate condition, not a hardcoded constant.
# ===========================================================================
echo "[E] anti-Goodhart tripwire is causal (forced negative control flips gate)"

# --- ml-eval: invert the classifier -> below-baseline model -> MUST exit 1 ---
cp "$WORK/$FIX_ML" "$WORK/ml_neg.py"
if mutate "$WORK/ml_neg.py" "return [1 if x >= t else 0 for x in X]" \
                            "return [0 if x >= t else 1 for x in X]" 2>"$WORK/mut.err"; then
  ne=$(run_capture "$WORK/ml_neg.py" "$WORK/ml_neg.o" "$WORK/ml_neg.e")
  if [ "$ne" = "1" ] && grep -qF "BEATS_BASELINE=False" "$WORK/ml_neg.o"; then
    pass "ml-eval exit-code tripwire REAL: below-baseline model exits 1 (legit exited 0)"
  else
    fail "ml-eval tripwire COSMETIC: below-baseline model exit=$ne (expected 1) -- exit code is not wired to the baseline gate"
  fi
else
  fail "ml-eval negative-control mutation could not be applied ($(cat "$WORK/mut.err")) -- fixture drifted"
fi

# --- scraper: null a REQUIRED field, rowcount stays 3/3 -> MUST exit 1 --------
# (directly proves the recipe's claim that "N rows scraped" is never sufficient)
cp "$WORK/$FIX_SC" "$WORK/sc_neg.py"
if mutate "$WORK/sc_neg.py" '<p class="price">51.77</p>' '<p class="price"></p>' 2>"$WORK/mut.err"; then
  ne=$(run_capture "$WORK/sc_neg.py" "$WORK/sc_neg.o" "$WORK/sc_neg.e")
  rowcount_ok=$(grep -qE 'rowcount +3/3 +PASS' "$WORK/sc_neg.o" && echo yes || echo no)
  field_fail=$(grep -qE 'field price +non-null 2/3 +FAIL' "$WORK/sc_neg.o" && echo yes || echo no)
  if [ "$ne" = "1" ] && [ "$rowcount_ok" = yes ] && [ "$field_fail" = yes ] && grep -qF "VERDICT=FAIL" "$WORK/sc_neg.o"; then
    pass "scraper tripwire REAL: rowcount still 3/3 PASS yet nulled field -> exit 1 (N-rows-alone insufficient)"
  else
    fail "scraper tripwire weak: exit=$ne rowcount3/3=$rowcount_ok fieldFAIL=$field_fail -- a padded/nulled row gamed the gate"
  fi
else
  fail "scraper negative-control mutation could not be applied ($(cat "$WORK/mut.err")) -- fixture drifted"
fi

# --- data-pipeline: break the transform -> VERDICT flips GREEN->RED + exit 1 --
# The S1-fix cashed this fixture's verdict out to the process exit code (the
# "ML/scraper standard"), so we require BOTH the VERDICT string flip AND a
# non-zero exit -- proving the anti-Goodhart tripwire is a real exit-code gate,
# not a printed sentence a juror could skim past.
cp "$WORK/$FIX_DP" "$WORK/dp_neg.py"
if mutate "$WORK/dp_neg.py" "        if oid in seen:" "        if False:" 2>"$WORK/mut.err"; then
  ne=$(run_capture "$WORK/dp_neg.py" "$WORK/dp_neg.o" "$WORK/dp_neg.e")
  if [ "$ne" = "1" ] && grep -qF "VERDICT=RED" "$WORK/dp_neg.o" && grep -qE 'unique\(order_id\) +FAIL' "$WORK/dp_neg.o"; then
    pass "data-pipeline exit-code tripwire REAL: broken dedup -> unique() FAIL -> VERDICT=RED + exit 1 (legit exited 0)"
  else
    fail "data-pipeline tripwire COSMETIC: broken transform gave exit=$ne / VERDICT not RED -- verdict/exit not wired to the assertions"
  fi
else
  fail "data-pipeline negative-control mutation could not be applied ($(cat "$WORK/mut.err")) -- fixture drifted"
fi
hr

# ===========================================================================
# ASSERTION G -- the real source fixtures are byte-identical before/after.
# The test only ever operated on COPIES in $WORK; the skill is never mutated.
# ===========================================================================
echo "[G] source-integrity guard (test never mutates the real fixtures)"
if [ -n "$SRC_SHA_BEFORE" ]; then
  SRC_SHA_AFTER="$(shasum -a 256 "$SRC/$FIX_ML" "$SRC/$FIX_DP" "$SRC/$FIX_SC")"
  if [ "$SRC_SHA_BEFORE" = "$SRC_SHA_AFTER" ]; then pass "real source fixtures unchanged (sha256 identical before/after)"
  else fail "real source fixtures were MODIFIED by the test run -- must never happen"; fi
else
  pass "source was EMBEDDED fallback; no on-disk skill files touched (nothing to mutate)"
fi
hr

# ===========================================================================
echo "RESULT: $fails failing assertion(s)"
if [ "$fails" -eq 0 ]; then echo "GREEN -- all M2 fixture-determinism/anti-Goodhart invariants hold"; exit 0
else echo "RED -- regression detected"; exit 1; fi