# exm7777 "25-workflow autopilot library" — goal-forge için analiz
Kaynak: x.com/exm7777 thread (2026-07; kullanıcı tam-metni yapıştırdı). Funnel-ucu var (weeklyaiops.com) ama teknik-öz gerçek ve goal-forge ile birebir hizalı.

## Doğrulama (zaten yapıyoruz — güven-teyidi)
- "judge only sees the conversation → 'done when tests pass' bir DİLEK; 'done when green run PASTED' bir SÖZLEŞME" = goal-forge'un KURULUŞ-invariantı (evaluator yalnız transcript okur; ham-kanıt yapıştırılır). "agents say done without it being true; proof you can read is the only version" = literal goal-forge.
- "paste the proof, else paste failures and STOP" = honest-status / NOT-DONE.
- state-file "runs smarter than last" = ledger + PLAN + GUARDRAILS.
- budget + stop-rule ZORUNLU = turn-cap + STOP_REASON.
- cheap-first routing (küçük-model rutini, flagship yalnız fail'de) = 1.9 EFFORT-ROUTING ([M]=haiku, opus/[J]).
- named terminal states = STOP_REASON kümesi.

## ADOPT — bizde yok/daha zayıf, eklemeye değer (öncelik sırası)
1. **Green/Yellow/Red risk-rengi (loop-başına)** — green=yalnız-okur/kendi-dosyası · yellow=taslak, insan-ship'ler · red=asla-yalnız (para/prod/outbound). Bizim §RED-HOLD ikili (geri-dönülmez→HOLD); bu SPEKTRUM + "yellow=draft-human-ships" daha kullanışlı. → TEMPLATE/CAMPAIGN'e loop-renk-etiketi.
2. **ONE-change-per-round** — "tek en-önemli şeyi düzelt, asla hepsini". Frontier-researcher disiplini (değiştir-test-et-koru-yaz). goal-forge /loop-reçetesi bunu SERT-kural yapmalı. → loop-recipe invariantı.
3. **Same-check-every-time** — hafta-hafta kıyaslanabilir SABİT-metrik (trend, tahmin değil). → loop-recipe ölçüm-disiplini.
4. **#21 hard-question escalation queue** — "ucuz-model önce; flagship yalnız LOGLANMIŞ-fail'de". EFFORT-ROUTING'i açık loop-kuralı + "logged failure gate" yapar (maliyet-patlaması önler). → PROCESS/loop.
5. **#24 repeat-offender digest** — "aynı fail iki workflow'da = tek sistem-problemi iki kostümde; tüm run-ledger'ları okur, kostüm-değişimini avlar". GUARDRAILS'imizin ÇOK-DOSYA/ÇOK-KOŞU üstü hali → tüm EVIDENCE-*.md + GUARDRAILS'i tarayan META-loop. Güçlü upgrade.
6. **#22 kill-criteria + #23 pre-mortem** — goal-DERLEME-anında: her canlı-seçenek "beni ne çürütür" (kill-condition) beyan eder + "12-ay-sonra başarısız-oldu, hikâyeyi şimdi yaz". Röportaj/derleme karar-hijyeni. → interview §2 / GUARDRAILS.
7. **#25 shadow prompt loop** — yeni prompt'u "gölgede gerçek-trafiğe karşı koştur, anlaşmazlıklar karar-versin". Yeni LINT/SKILL-sürümünü PROMOTE-etmeden önce gerçek-goal'lara karşı gölge-test → verdict-diff. (v1.9'un test-suite + external-breaker turuyla örtüşür.)

## En yüksek-değerli 3 (hemen)
(a) Green/Yellow/Red — §RED-HOLD'yi spektruma çevir · (b) ONE-change-per-round loop-invariantı · (c) #24 repeat-offender meta-digest (ledger-üstü GUARDRAILS).

## Uyarı-notu
Thread'in "Fable en pahalı model; 7 Temmuz'da pay-as-you-go'ya geçiyor; cheap-first-routing + hard-cap ZORUNLU olur" uyarısı → bizim budget/EFFORT-ROUTING disiplininin ekonomik-aciliyet gerekçesi.
