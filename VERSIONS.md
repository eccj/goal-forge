# Sürüm Eşlemesi — iç-vN → SemVer
İç geliştirme adları (v2..v10) tek günlük evrim dilimleriydi; 1.0'dan itibaren SemVer.
| İç ad | SemVer | Öz |
|---|---|---|
| v2 | 0.2 | röportaj+lint+jüri çekirdeği |
| v3 | 0.3 | ledger+reopen+arşiv |
| v4 | 0.4 | ledger.sh + savcı-sertleştirme |
| v5 | 0.5 | resume/guardrails/gate/PLAN/loop-kilitleri |
| v6 | 0.6 | iskelet v2 (iki-katman, turnuvayla) |
| v7 | 0.7 | fallback+anlam-arama+rubrik-kapı+S#şeması |
| v8 | 0.8 | METRICS+dil-bağımsız+light-mode |
| v9 | 0.9 | PIN kuralı (NOOP→temyiz→reopen koşusu) |
| v10 | **1.0** | measure-aracı + temyiz-hukuku; campaign kapanışı |
| — | **1.1** | dış-domain kanıt + çapraz-model + kırmızı-takım + QUICKSTART |
| — | 1.2 | 3-tür saha koşusu + render-testi + tavan-projeksiyon tetiği |
| — | 1.3 | 9,0-kampanyası dürüst-BLOKE (savcı-teyitli) |
| — | **1.4** | Röportaj-v2: Q7 teknoloji-sorusu (STACKS.md) + stack-bakeoff + Roadmap kuralı |
| — | 1.5 | repo-vitrin: public repo + MIT + mermaid-README/FAQ/TRACK-RECORD; S1 force-push-geçmiş güvenlik-fixi (eski repo private-arşiv) |
| — | **1.6** | §RED-HOLD geri-dönülmez-eylem terminal-hold + §Fallback/§SAFETY terminal-state taksonomisi + 2026-07-04 dersleri kodifiye (haiku-brief, zero-API, rewrite/history reçeteleri) + doc-hygiene |
| — | 1.7 | Kampanya (M1·M2·M3, 3/3 ilk-tur oybirliği): Tribunal ground-truth yeniden-temellendirme + tamper-sertleştirme (M1) · 5 domain kanıt-reçetesi (M2) · Calibration-Anchor öz-skor (M3, İÇ-only) |
| — | **1.8** | Sertleştirme+yayın: gap-hunt 3-blocker (tool-block-jüri + LINT sert-taban-veto + anchored-verdict-dişleri) + ledger.sh coverage/lock-steal/phantom-tail + haiku eval-integrity + Go/Rust reçeteleri + honest-ceiling + tests/ 10-modül test-suite |
| — | 1.9 | Optimal yapı: SKILL 97-satır→≤8000-char-measure + 6-mekanizma-özet · [M]/[J] tipleme + EFFORT-ROUTING (haiku-şerit) + G=1→§Light≤5 · jury-shopping tripwire · §Archive human-mirror + ≤5-satır düz-özet · BUDGETED-COMPOSE (Σ≤3800, >1 sıkıştırma=kusur) · ASCII-kanon · LINT#5 medyan×1.3 · 2 yeni test (skill-budget + invariant-xref) |
| — | **2.0** | Loop/campaign sertleştirme + exm7777 7-desen ADOPT (red-team-doğrulı): risk-rengi green/yellow/red (red⊇§RED-HOLD) · loop-round sözleşmesi (one-change + hash-donmuş-same-check + cheap-first-escalation + ZORUNLU-round-ledger) · scripts/repeat-offender.sh (çapraz-koşu sistem-problemi) · karar-hijyeni (kill-criteria+pre-mortem+§Shadow-test) |
| — | **2.1** | "Herkes için düz-dil" — jargon→sade: eski geri-dönülmez-hold jetonu → §RED-HOLD (2.0 RED-tier'ın goal-tarafı çekirdeği) · kampanya-temyiz jetonu → appeal-law · STOP_REASON RED-HOLD; her teslim düz-özet+terim-legend (TEMPLATE §Plain-delivery); koşu-sonrası rapor düz-dil Result-blok-başlar (§Plain-report); public GLOSSARY.md (18-terim) + README teknik-olmayan-giriş; teknik-olmayan-persona jüri doğrulaması |
| — | **3.0** | telemetri+mekanik-disiplin: tokens.sh TOKEN-RAPORU (model-başına $) · lint.sh script-skoru · STATE.md · GUARDRAILS-OTO · röportaj-her-koşulda+adaptif+Q6-rol-başına · anchored-confidence (ayrıntı: aşağıdaki 3.0 bölümü)
| — | 3.0.1 | rapor-zenginleştirme: süre + kod-değişimi satırları (aşağıdaki bölüm)
| — | **3.1** | optimizasyon: xref-testi GATE-şartı · §Resume taze-oturum-devri (state.sh resume-card) · marker-kalıcılığı · retro.sh seal-sonrası-tarama · TEMPLATE-budama %8 (aşağıdaki 3.1 bölümü)

## 3.1.1 (2026-07-06) — rapor-görünümü (operatör-isteği)
- tokens.sh report --md: TOKEN-RAPORU'nun GFM-tablo çıktısı (terminal+mobil render; sayılar yine %100 script-üretimi); ham mod ledger için birebir korunur

## 3.1 (2026-07-06) — optimizasyon sürümü (tam-yetkili öz-akıl-yürütme)
- D1: tests/test_xref_anchors.py çapraz-dosya numaralı-referans desteği ("SKILL.md §2" marker'ı hedef-dosyayı seçer) → YEŞİL; COMPLETION-GATE'e kalıcı bağlandı (TEMPLATE PROCESS + SKILL §5: skill-.md dokunulduysa xref-testi gate-şartı)
- D2: state.sh resume-card → goals/RESUME.md (misyon+PIN+ledger+sıradaki-D#+devir-talimatı) + TEMPLATE §Resume — bağlam-şişkinliği (>100k/istek) taze-oturum-devriyle çözülür
- D3: tokens.sh marker-kalıcılığı — <marker> olarak DİZİN veya ledger-.md verilirse <dizin>/.tokens-marker (açık-yol + çıplak-satır-no geriye-uyumlu; /tmp-silinme-kazası biter)
- D4: scripts/retro.sh (seal/check, minimal — daemon YOK): seal commit-aralığını arşivler; SONRAKİ derleme-önkoşulunda revert/amend taraması 1-satır (SKILL §2 PRECONDITION'a eklendi)
- D5: TEMPLATE-budama %8.05 goal-başı-commit-tabanına göre (29577→27197 char; savcı-S1 sonrası taban commit-çıpalı — working-tree ara-tabana göre %11.45) — koruma: silinen-çapa=0 + xref-yeşil + template-integrity (lint-shadow bağlayıcı DEĞİL: lint.sh TEMPLATE'i okumaz, savcı-S2 dürüstlük-notu §Shadow-test'e işlendi)
- ÇIKARILAN yanlışlar: dil-politikası çift-anlatımı, el-ile-hash tarifi (kanonik ledger.sh varken), RED-HOLD çift-anlatım, hardening-bullet↔haiku-checklist kopyası, arşiv-resume↔§Resume örtüşmesi

## 3.0.1 (2026-07-06) — rapor-zenginleştirme (operatör-isteği)
- tokens.sh report: SÜRE satırı (goal-start→rapor duvar-saati) + KOD-DEĞİŞİMİ satırı (git-shortstat + commit-sayısı; mark artık opsiyonel proj-dir ile git-HEAD kaydeder)

## 3.0 (2026-07-06) — telemetri + mekanik-disiplin sürümü
- tokens.sh (mark/report): goal-başına TOKEN-RAPORU — TOTAL+model-başına $ (requestId-dedup, placeholder-dürüstlük-notu, subagent-mtime-filtresi, resmî-fiyat-gömülü)
- lint.sh: LINT-skoru script-üretimi (mekanik alt-küme, placeholder→cap-79)
- state.sh + goals/STATE.md: canlı-ilerleme (script-üretimi)
- GUARDRAILS-OTO: TEMPLATE §Post-mortem (oto-yakalama + overlap-keskinleştirme) + derleme-önkoşulu "GUARDRAILS uygulandı:" beyanı (3-ısırık dersi mekanikleşti)
- Röportaj: HER koşulda zorunlu (sayım-istisnası İPTAL; tek-istisna açık "röportajsız") + ADAPTİF çok-aşama (≤3 cevap-türevi takip-turu) + Q6 ROL-BAŞINA jüri-modeli
- Jüri: anchored-discrete confidence 0/25/50/75/100 (APPROVE≥75) + 2.-REJECT'te kök-neden-protokolü
- Araştırma: ≥25 canlı-kaynak (EVIDENCE-30 K1-K26); ertelenen: seal-sonrası-izleme(presence-tarzı), tam-hook-zorlama, dashboard
