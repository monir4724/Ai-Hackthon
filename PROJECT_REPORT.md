# PROJECT REPORT — Rokkhakoboch (রক্ষাকবচ)

**Team:** Team Beta  
**Institution:** University of Frontier Technology, Bangladesh (with collaborator from Ananda Mohan College)  
**Repository:** [github.com/monir4724/Ai-Hackthon](https://github.com/monir4724/Ai-Hackthon)  
**Live web:** https://innovative-flow-production-c724.up.railway.app  
**Live API:** https://ai-hackthon-production.up.railway.app  
**Submission deadline:** July 8, 2026  

---

## 1. Problem Statement

Bangladesh has one of the world's highest mobile-money adoption rates. Alongside bKash, Nagad, and Rocket came a parallel wave of **MFS phishing, OTP theft, fake payment requests, and QR scams** delivered through SMS, messenger apps, and malicious links. Victims—often under time pressure—lack a simple, Bangla-first tool to **triage suspicious messages before transferring money**.

Key pain points we observed:

- **Language gap:** Most global phishing tools are English-centric; Bangla scam patterns (urgency framing, agent impersonation, lottery/cashback lures) need localized detection.
- **Speed under stress:** Users need an answer in seconds, not after manual research.
- **Trust and honesty:** Overclaiming "100% detection" erodes credibility; users need clear **risk indicators** with explanations.
- **Fragmented awareness:** Scam patterns repeat nationally but victims rarely see aggregated threat intelligence by region.

Rokkhakoboch (রক্ষাকবচ — "protective armor") addresses these gaps through a **10-module National Cyber Defense architecture** delivered on **web (React)**, **mobile (Flutter APK)**, and a **Laravel API backend** powered by dataset-informed rule-based prefiltering plus Google Gemini reasoning.

---

## 2. Proposed Solution

Rokkhakoboch is an AI-assisted **risk-indicator platform** for everyday Bangladeshi users. It does not block transactions or intercept live calls; it helps users decide whether to trust a message, link, or QR code.

### Core capabilities (working modules)

| Module | Name | Status | What it does |
|--------|------|--------|--------------|
| 1 | MFS Message Sentinel | Active | Paste or auto-scan (Android) MFS SMS → Bangla verdict + scam category badge |
| 2 | Call Transcript Analysis | Active | Paste call transcript → dedicated Gemini prompt (English scripts + BD patterns) |
| 3 | URL Phishing Guard | Active | URL check with 0–100 risk score, Bangla flags, dataset-derived heuristics |
| 4 | Financial Fraud Shield | Active | QR scan (mobile) or manual input (web) → combined URL + text via `/api/qr-check` |
| 6 | Media Verification | Experimental | Client-side ELA heatmap (editing-signal hint, not deepfake ML) |
| 7 | Device Protection | Active | BD-specific checklist + live permission status (Play Store–safe) |
| 10 | National Threat Intelligence | Active | 130+ seeded patterns, division labels, threat map |
| 5, 8, 9 | Social / Identity / Business | Roadmap | Placeholder "coming soon" |

### Platform delivery

- **Web:** React + Vite SPA — scan, URL check, QR text input, device checklist, result, history, feed, report.
- **Mobile:** Flutter Android APK — same API flows plus camera QR scan, SMS auto-scan toggle, threat map, Firebase push alerts, experimental media check.
- **Backend:** Laravel REST API — `/api/analyze`, `/api/url-check`, `/api/qr-check`, `/api/reports`, `/api/history/{sessionId}`, health at `/up`.
- **Database:** MySQL — `scam_patterns` (130+ rows after seed), `scan_histories`, `location_label` for regional reports.

### Architecture (data flow)

```
User input (SMS / transcript / URL / QR / report)
        ↓
Laravel API (dataset-informed prefilter + optional Gemini)
        ↓
Structured JSON verdict (risk_level, verdict_bn, explanation, flags, flags_bn, scam_category)
        ↓
Web UI / Mobile UI (VerdictSeal, risk score bar, history, feed, map)
        ↓
Rule-based fallback if Gemini unavailable
```

Community reports and seeded threat feed enrich Module 10; division tags enable regional visualization on the mobile threat map (OpenStreetMap, no API key).

---

## 3. Methodology

### Development approach

We followed an **MVP-first, honesty-first, dataset-informed** methodology:

1. **Problem framing** — Mapped common Bangladesh MFS scam categories (OTP phishing, send-money reversal, fake agent, lottery, SIM-swap cues).
2. **Dataset collection & extraction** — Curated corpora in `datasets/`; automated extraction to `backend/database/data/extracted_dataset_insights.json`.
3. **Two-stage detection pipeline** — Fast rule-based prefilter (dataset keywords) → Gemini structured reasoning → rule-based fallback on API failure.
4. **Full-stack integration** — Laravel API, React web, Flutter mobile sharing one API contract and session-based history.
5. **Iterative module expansion** — Core scan → URL/QR → device checklist → threat map → SMS auto-scan → dataset-driven hardening across all active modules.
6. **Testing** — Manual end-to-end flows, Flutter unit tests (SMS filter, ELA), `flutter analyze` clean, release/debug APK builds, `npm run build` for web.

### Datasets used

| Dataset | Records | Application |
|---------|---------|-------------|
| BangalaBarta smishing CSV | 2,772 (924 smish) | Keyword prefilter, 15 Gemini few-shot examples, BangalaBartaSeeder (+50 patterns), ThreatFeedSeeder (+30 entries with division labels) |
| rokkhakoboch synthetic CSV | 50 | Original ScamPatternSeeder + few-shot baseline |
| URL phishing CSV | ~651,000 | Top suspicious TLDs, brand-in-subdomain, hyphen/IP patterns → UrlSafetyService |
| Payment fraud CSV | 6M+ transactions | TRANSFER/CASH_OUT dominance, balance-drain patterns → QrSafetyService |
| English_Scam.txt | Call scripts | Transcript-specific Gemini prompt (gov grant, tech support, prize, charity, police + BD variants) |

Large CSVs are gitignored; extracted insights and small copies (BangalaBarta, English_Scam) ship in `backend/database/data/` for Railway seeding.

### Deployment methodology

- **Web:** Railway — separate Laravel backend + React frontend services + MySQL plugin.
- **Mobile:** Flutter release/debug APK distributed directly; Firebase for push notifications (Android).
- **Post-deploy:** `php artisan db:seed --force` on backend service.

---

## 4. AI/ML Approach

Rokkhakoboch uses **no custom-trained neural model**. Detection is a hybrid pipeline:

### Stage A — Rule-based prefilter (deterministic, dataset-informed)

Before any API call, text is scored against extracted scam signatures:

- **OTP/PIN theft:** পিন, OTP, গোপন কোড, পাসওয়ার্ড
- **Account lock:** অ্যাকাউন্ট বন্ধ, ফ্রিজ, সাসপেন্ড, ব্লক
- **MFS fraud:** bKash, Nagad, Rocket brand + suspicious requests
- **Lottery/prize, fake job, fake investment, urgency phrases** — from BangalaBarta frequency analysis
- Outputs: `risk_score`, `flags[]`, `matched_patterns[]`, `scam_category`

### Stage B — Gemini 2.5 Flash (API inference)

- **Model:** `gemini-2.5-flash` (Google Generative AI API)
- **Mode:** Zero-shot + few-shot — 15 real BangalaBarta smishing examples + 50 synthetic examples
- **Modules:** Separate prompts for SMS vs call transcript analysis
- **Context:** All prompts include Bangladesh MFS context (bKash, Nagad, Rocket)
- **Output:** Structured JSON — `risk_level`, `verdict_bn`, `explanation`, `matched_pattern`, `scam_category`, `disclaimer`
- **Temperature:** 0.2 (low variance for consistent triage)
- **Fallback:** Rule-based verdict when Gemini fails or rate-limits (`ai_source: gemini_fallback`)

### URL & QR checking (heuristic, dataset-informed)

- **`/api/url-check`:** Suspicious TLDs (.tk, .ml, .ga, .cf, .gq), MFS/telecom impersonation domains, URL shorteners, brand-in-subdomain, IP URLs, encoded chars → `risk_score` 0–100 + `flags_bn` in Bangla
- **`/api/qr-check`:** Routes payload through URL checker + SMS analyzer; payment fraud indicators from transaction dataset (TRANSFER/CASH_OUT, phone-in-QR patterns)

### What we deliberately did NOT do

- No fine-tuning on any corpus
- No claimed accuracy percentage
- No live call audio ML — Module 2 is paste-only transcript analysis
- Module 6 uses **Error Level Analysis (ELA)** heuristics only — not a deepfake classifier

---

## 5. Results

### Functional deliverables

| Component | Result |
|-----------|--------|
| Backend API | 6 endpoints operational; Gemini + rule-based fallback; dataset-informed prefilters |
| Web app | Full flow: scan → URL → QR text → device checklist → verdict → history → feed |
| Mobile APK | Release (~69 MB) + debug builds; Modules 1–4, 6, 7, 10 active |
| Database | 130+ seeded patterns (50 synthetic + 50 BangalaBarta + 30 threat feed with division labels) |
| Tests | Flutter tests passing; `flutter analyze` clean; frontend production build passes |
| SMS auto-scan | Android-only; expanded bKash/Nagad/Rocket keyword filter; opt-in toggle |
| Threat map | Division-level circles from `location_label`; auto-loads on open |

### Demonstration scenarios (judge-ready)

1. Paste a BangalaBarta-style bKash OTP phishing SMS → **high risk** verdict with category badge (e.g. "OTP ফিশিং").
2. Paste an English scam call transcript → transcript-specific analysis with BD-localized red flags.
3. Check a suspicious URL → risk score bar + Bangla flag explanations.
4. Scan a QR code (mobile) or paste payment text (web) → combined URL + text verdict via `/api/qr-check`.
5. Open threat feed → "এখন পর্যন্ত X টি স্ক্যাম রিপোর্ট" with division labels and time-ago.
6. Device protection screen → BD checklist + live SMS/overlay permission warnings.

### Honest outcome framing

Results are **risk indicators**, not court-grade evidence. The system is optimized for **user caution and education**, not autonomous blocking.

---

## 6. Limitations & Future Work

### Known limitations

- **Not 100% accurate** — false positives and false negatives are possible; advisory framing only.
- **Gemini API dependency** — rate limits, latency, and outages affect live AI quality; fallback is less nuanced.
- **Bangla-first optimization** — English or mixed-language messages may get weaker analysis (transcript mode handles English scripts better).
- **No live call interception** — privacy and platform restrictions; transcript paste only.
- **SMS auto-scan: Android only** — iOS does not permit SMS reading.
- **Module 6 is experimental** — ELA shows compression/editing artifacts, not deepfake proof.
- **Threat map is coarse** — division-level approximation, not GPS precision.
- **Large datasets not in git** — insights extracted to JSON; local CSVs needed only for re-extraction.

### Future work

| Module | Planned direction |
|--------|-------------------|
| 5 — Social Media Scam Watch | Screenshot/text pattern reporting for Facebook/Messenger/Telegram |
| 8 — Identity Protection | SIM-swap/KYC impersonation guidance |
| 9 — Business Protection | Merchant/agent fraud playbooks |
| Cross-cutting | Human feedback loop, URL reputation feeds, optional English output, on-device privacy dashboard |

### Ethical considerations

- False positives may cause unnecessary alarm; false negatives may create false confidence — disclaimers on every verdict.
- SMS auto-scan processes only finance-keyword-matching messages; no bulk SMS storage.
- Community reports are anonymous; no PII required.
- Experimental media check is labeled honestly to prevent misuse as "proof."

---

## Conclusion

Rokkhakoboch delivers a practical, Bangla-first scam triage MVP across web and mobile, combining **dataset-informed explainable rules** with Gemini reasoning inside an extensible 10-module architecture. It prioritizes **honest risk communication** over inflated accuracy claims—appropriate for protecting everyday MFS users in Bangladesh.

**Team Beta:** Moniruzzaman Monir (Lead), Mufrid Johanee (Backend/QA), Raiyan Ibne Kamal (Ideation), Kazi Mukddmur Rahman Sami (Frontend UI/UX — Ananda Mohan College).
