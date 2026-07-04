# goal-forge Gallery — 20 domain-diverse compiled contracts

# goal-forge Contract Gallery

A skill stress-test across 20 domains. Each entry is a fully compiled `/goal` contract produced by **goal-forge** — an evidence-gated mission spec with a Tribunal jury, a tamper-evident Evidence Ledger completion condition, and Goodhart-resistant hard inequalities, all inside the 4000-character limit. Twenty different problem spaces, one skill: this gallery exists to show the compiler generalizes rather than fitting a single happy-path domain.

| # | Theme | Domain | Mode | Lint /100 | ~Chars |
|---|-------|--------|------|-----------|--------|
| 1 | Real-time collaborative whiteboard | web / realtime | goal | 96 | 3972 |
| 2 | iOS habit-tracker app | mobile / native (SwiftUI + HealthKit) | goal | 96 | 3995 |
| 3 | Fraud-detection ML pipeline | ML / tabular (imbalanced binary) | goal | 97 | 3990 |
| 4 | Security audit of a Node.js API | security | goal | 97 | 3993 |
| 5 | Nightly ETL: CSV → warehouse | data pipeline (ETL) | goal | 96 | 3995 |
| 6 | 2D roguelike browser game | game / web | goal | 97 | 3992 |
| 7 | Fast fuzzy file-finder CLI | CLI / Rust | goal | 96 | 3983 |
| 8 | GraphQL API for a bookstore | API / backend | goal | 97 | 3978 |
| 9 | Chrome extension: reading-time + summarizer | browser extension (MV3) | goal | 97 | 3990 |
| 10 | ESP32 temperature-logger firmware | embedded / IoT (C firmware) | goal | 96 | 3985 |
| 11 | Solidity escrow smart-contract | blockchain | goal | 96 | 3991 |
| 12 | Podcast auto-clipper (ffmpeg silence-detect) | video / media | goal | 95 | 3998 |
| 13 | E-commerce checkout revamp | web / e-commerce (Next.js + Stripe) | goal | 97 | 3992 |
| 14 | K8s deploy + CI/CD for a microservice | devops / infra | goal | 96 | 3991 |
| 15 | Docs site for an OSS library | documentation | goal | 97 | 3984 |
| 16 | Reproduce a research paper result | ML reproduction | goal | 97 | 3992 |
| 17 | Job-listings web scraper | scraper | goal | 98 | 3992 |
| 18 | RAG chatbot over internal docs | AI / RAG | goal | 98 | 3998 |
| 19 | Zero-downtime Postgres table split | database migration (expand-contract) | goal | 96 | 3977 |
| 20 | Accessibility audit + fixes | a11y / web | goal | 96 | 3991 |

## Coverage & scores

The 20 contracts span front-end, mobile, ML/data, security, embedded, blockchain, media, devops, documentation, and database migration — every one compiled as a single-finish-line **goal** (each justified against the loop/campaign alternatives in its `mode` note). Lint scores cluster tightly: **min 95, median 96.5, max 98** across all twenty, with the recurring weakest criterion being **#6 Goodhart** — the honest residue of proxying inherently subjective wishes ("legible caption", "good summary", "endpoint responds") as machine inequalities. No contract scored below 95, and every one clears the hard evidence and tribunal floors.

> **Caveat:** These were compiled with reasonable *assumed* answers, not a live interview — domain-specific thresholds, paths, and targets are placeholders flagged in each contract's `decide-before-launch` list and should be confirmed by a real operator before launch.

## Verified index (canonical char counts, ledger.sh-cross-checked)
| # | Theme | Domain | Mode | Lint | Chars | File |
|--:|---|---|---|--:|--:|---|
| 1 | Real-time collaborative whiteboard | web / realtime | goal | 96 | 3972 | [01-real-time-collaborative-whiteboard.md](01-real-time-collaborative-whiteboard.md) |
| 2 | iOS habit-tracker app | mobile / native (SwiftUI + HealthKit) | goal | 96 | 3995 | [02-ios-habit-tracker-app.md](02-ios-habit-tracker-app.md) |
| 3 | Fraud-detection ML pipeline | ML / tabular (imbalanced binary classification) | goal | 97 | 3990 | [03-fraud-detection-ml-pipeline.md](03-fraud-detection-ml-pipeline.md) |
| 4 | Security audit of a Node.js API | security | goal | 97 | 3993 | [04-security-audit-of-a-node-js-api.md](04-security-audit-of-a-node-js-api.md) |
| 5 | Nightly ETL: CSV → warehouse | data pipeline (ETL) | goal | 96 | 3995 | [05-nightly-etl-csv-warehouse.md](05-nightly-etl-csv-warehouse.md) |
| 6 | 2D roguelike browser game | game / web | goal | 97 | 3992 | [06-2d-roguelike-browser-game.md](06-2d-roguelike-browser-game.md) |
| 7 | Fast fuzzy file-finder CLI | CLI / Rust | goal | 96 | 3983 | [07-fast-fuzzy-file-finder-cli.md](07-fast-fuzzy-file-finder-cli.md) |
| 8 | GraphQL API for a bookstore | API / backend | goal | 97 | 3978 | [08-graphql-api-for-a-bookstore.md](08-graphql-api-for-a-bookstore.md) |
| 9 | Chrome extension: reading-time + summarizer | browser extension (MV3, content-script, offline summarize, store-policy compliance) | goal | 97 | 3990 | [09-chrome-extension-reading-time-summarizer.md](09-chrome-extension-reading-time-summarizer.md) |
| 10 | ESP32 temperature-logger firmware | embedded / IoT (C firmware) | goal | 96 | 3985 | [10-esp32-temperature-logger-firmware.md](10-esp32-temperature-logger-firmware.md) |
| 11 | Solidity escrow smart-contract | blockchain | goal | 96 | 3991 | [11-solidity-escrow-smart-contract.md](11-solidity-escrow-smart-contract.md) |
| 12 | Podcast auto-clipper (ffmpeg silence-detect → cut → caption, ffprobe-verified) | video / media | goal | sin | 95 | 3998 | [12-podcast-auto-clipper-ffmpeg-silence-dete.md](12-podcast-auto-clipper-ffmpeg-silence-dete.md) |
| 13 | E-commerce checkout revamp | web / e-commerce (Next.js + Stripe) | goal | 97 | 3992 | [13-e-commerce-checkout-revamp.md](13-e-commerce-checkout-revamp.md) |
| 14 | K8s deploy + CI/CD for a microservice | devops / infra | goal | 96 | 3991 | [14-k8s-deploy-ci-cd-for-a-microservice.md](14-k8s-deploy-ci-cd-for-a-microservice.md) |
| 15 | Docs site for an OSS library | documentation | goal | 97 | 3984 | [15-docs-site-for-an-oss-library.md](15-docs-site-for-an-oss-library.md) |
| 16 | Reproduce a research paper result | ML reproduction | goal | 97 | 3992 | [16-reproduce-a-research-paper-result.md](16-reproduce-a-research-paper-result.md) |
| 17 | Job-listings web scraper | scraper | goal | one | 98 | 3992 | [17-job-listings-web-scraper.md](17-job-listings-web-scraper.md) |
| 18 | RAG chatbot over internal docs | AI / RAG | goal | 98 | 3998 | [18-rag-chatbot-over-internal-docs.md](18-rag-chatbot-over-internal-docs.md) |
| 19 | Zero-downtime Postgres table split | database migration (expand-contract / online schema change) | goal | 96 | 3977 | [19-zero-downtime-postgres-table-split.md](19-zero-downtime-postgres-table-split.md) |
| 20 | Accessibility audit + fixes | a11y / web | goal | 96 | 3991 | [20-accessibility-audit-fixes.md](20-accessibility-audit-fixes.md) |


**Coverage:** 20 domains · lint self-scores min 95 / max 98 · chars 3972–3998 (all ≤4000).
**Honest caveat:** each was compiled from *assumed* interview answers (no live user), so every example ships a `Decide before launching` list a real operator would resolve. They demonstrate the compiler generalizes across domains; they are not turnkey project plans.
