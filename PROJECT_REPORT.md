# PROJECT REPORT — Rokkhakoboch (রক্ষাকবচ)

**SciBlitz AI Challenge 2026 · IEEE Student Branch, CUET**  
**Team:** Team Beta · **Track:** E — National Defence (AI tool for national cyber-scam / MFS fraud awareness)  
**Institution:** University of Frontier Technology, Bangladesh (+ Ananda Mohan College collaborator)  
**Team Lead:** Moniruzzaman Monir  
**Repository:** https://github.com/monir4724/Ai-Hackthon  
**Live web:** https://innovative-flow-production-c724.up.railway.app  
**Live API:** https://ai-hackthon-production.up.railway.app/up  
**Submission deadline:** July 8, 2026, 11:59 PM BST  

---

## Submission checklist (SciBlitz Rulebook §7)

| Deliverable | Status | Link / note |
|-------------|--------|-------------|
| Live public URL | ✅ | https://innovative-flow-production-c724.up.railway.app |
| Project Report (PDF, ≤8 pages) | 📄 | Export this file → PDF, min 10pt font |
| GitHub repository (public) | ✅ | Commits May 14 – July 8, 2026 window |
| Demo video (3–5 min, YouTube/Drive) | ⏳ | Team to upload unlisted link |
| Model & Data Card (1-page PDF) | 📄 | Export `MODEL_DATA_CARD.md` → PDF |

---

## 1. Problem Statement

Bangladesh has one of the world's highest mobile-money adoption rates. Alongside bKash, Nagad, and Rocket came a parallel wave of **MFS phishing, OTP theft, fake payment requests, and QR scams** via SMS, links, and phone calls. Victims under time pressure lack a **Bangla-first tool** to triage suspicious content before losing money.

**National relevance (Track E):** Scam networks operate at scale across divisions; citizens need accessible cyber-defense tooling, not only law-enforcement response after losses occur.

| Pain point | Impact |
|------------|--------|
| Language gap | Global tools are English-centric; Bangla smishing patterns differ |
| Speed under stress | Users need seconds-level triage, not manual research |
| Trust deficit | Overclaiming "100% detection" erodes credibility |
| Fragmented intelligence | Repeat patterns rarely visible regionally |

---

## 2. Proposed Solution

**Rokkhakoboch** (রক্ষাকবচ — "protective armor") is a 10-module **National Cyber Defense** platform: web (React), mobile (Flutter APK), and Laravel API. It provides **honest risk indicators** — not guaranteed verdicts — for SMS, call transcripts, URLs, QR payments, and community threat reporting.

### Active modules

| Module | Name | Platform | Function |
|--------|------|----------|----------|
| 1 | MFS Message Sentinel | Web + Mobile | SMS paste / Android auto-scan → Bangla verdict + category |
| 2 | Call Transcript Analysis | Web + Mobile | Paste transcript → dedicated AI analysis |
| 3 | URL Phishing Guard | Web + Mobile | URL → risk score 0–100 + Bangla flags |
| 4 | Financial Fraud Shield | Web + Mobile | QR/payment text → combined URL + text check |
| 7 | Device Protection | Web + Mobile | BD security checklist + permission awareness |
| 10 | National Threat Intelligence | Web + Mobile | Feed (130+ patterns) + division threat map |
| 6 | Media Verification | Mobile only | Experimental ELA (not deepfake ML) |
| 5, 8, 9 | Social / Identity / Business | Roadmap | Coming soon |

### Architecture

```
User input → Laravel API (dataset-informed prefilter + Gemini)
          → JSON verdict (risk_level, verdict_bn, flags, scam_category)
          → Web / Mobile UI
          → Rule-based fallback if Gemini unavailable
```

---

## 3. Methodology

1. **Problem mapping** — Bangladesh MFS scam taxonomy (OTP, lottery, reversal, fake agent, SIM-swap).
2. **Dataset curation** — Five corpora in `datasets/` (see Model & Data Card).
3. **Insight extraction** — Keywords, TLDs, fraud transaction patterns → `extracted_dataset_insights.json` + PHP services.
4. **Hybrid pipeline** — Rule prefilter → Gemini structured JSON → fallback rules.
5. **Full-stack delivery** — Shared API for web + mobile; session history; community reports with `location_label`.
6. **Deployment** — Railway (Laravel + React + MySQL); Flutter APK with production API URL.
7. **Validation** — Manual E2E demos, Flutter tests, `flutter analyze`, frontend production build.

### Datasets

| Dataset | Records | Role in MVP |
|---------|---------|-------------|
| BangalaBarta smishing CSV | 2,772 (924 smish) | Modules 1, 10 — keywords, few-shot, seeders |
| Synthetic Bangla CSV | 50 | Baseline few-shot + ScamPatternSeeder |
| URL phishing CSV | ~651,000 | Module 3 — heuristic rules |
| Payment fraud CSV | 6.3M+ | Module 4 — TRANSFER/CASH_OUT patterns |
| English_Scam / NonScam | ~800 each | Module 2 — transcript prompt design |

---

## 4. AI/ML Approach

### 4.1 Current implementation (submitted MVP)

| Layer | Technology | Purpose |
|-------|------------|---------|
| Text analysis | **Gemini 2.5 Flash** (Google API) | Zero-shot + few-shot Bangla scam reasoning |
| Text prefilter | Rule-based (BangalaBarta keywords) | Fast flags before API call |
| URL check | Rule-based (651k URL insights) | TLD, brand impersonation, shorteners → score 0–100 |
| QR / payment | Combined URL + text + fraud heuristics | Module 4 |
| Fallback | Same rule engine | Works when Gemini rate-limits or fails |

**No custom model weights were trained** in this submission. This aligns with Rulebook §8.1: *"Technical Implementation does not require training from scratch; effective, appropriate, and well-integrated use of existing tools and APIs will score well."*

### 4.2 Dataset অনুযায়ী কোন ML Model — Module by Module

Task type অনুযায়ী model choice করতে হয়। প্রতিটা dataset আলাদা ধরনের সমস্যা (text classification vs tabular classification vs imbalanced fraud), তাই আলাদা model লাগবে।

#### Module 1 & 10 — BangalaBarta SMS (Text, 3-class: smish/promo/normal)

| Priority | Model | Rationale |
|----------|-------|-----------|
| Best fit | Logistic Regression + TF-IDF | Interpretable; probability helps promo/smish overlap |
| Better accuracy | SVM (linear) | Strong on sparse text vectors |
| Ensemble | XGBoost / LightGBM | Subtle class boundaries |
| Baseline | Multinomial Naive Bayes | Quick text baseline |

Avoid: KNN, Linear Regression, unsupervised clustering (labels exist).

#### Module 3 — URL Phishing (Tabular, 4-class, 58–64 features)

| Priority | Model | Rationale |
|----------|-------|-----------|
| Best fit | XGBoost / LightGBM | Standard for tabular phishing (TLD, IP, brand flags) |
| Second | Random Forest | Feature importance for explainability |
| Baseline | Decision Tree | Demo-friendly decision paths |

Avoid: SVM at 651k scale, KNN inference cost, Naive Bayes independence assumption.

#### Module 4 — Payment Fraud (Tabular, imbalanced binary, 6.3M rows)

| Priority | Model | Rationale |
|----------|-------|-----------|
| Best fit | LightGBM | Speed + `scale_pos_weight` for imbalance |
| Strong | XGBoost | Fraud detection track record |
| Alternative | Random Forest | Robust with less tuning |

Avoid: Plain logistic regression (low fraud recall), ANN (boosting wins on tabular at this scale).

#### Module 2 — Call Transcripts (Text, binary: scam vs non-scam)

| Priority | Model | Rationale |
|----------|-------|-----------|
| Best fit | Logistic Regression + TF-IDF | Balanced 800/800 corpus |
| Better | SVM (linear) | Reliable text classifier |
| Advanced | Fine-tuned DistilBERT | Higher accuracy, more compute |

#### Summary table

| Module | Data type | Recommended ML | MVP today |
|--------|-----------|----------------|-----------|
| 1, 10 | Text (3-class) | Logistic Regression → SVM/LightGBM | Gemini + rules |
| 3 | Tabular (4-class) | XGBoost / LightGBM | Heuristic rules |
| 4 | Tabular (imbalanced) | LightGBM | Heuristic rules |
| 2 | Text (binary) | Logistic Regression | Gemini prompt |

### 4.3 Why custom ML is future work (honest)

Training the recommended models requires:
1. Python environment (scikit-learn, xgboost, lightgbm) — Colab or local
2. Export to `.pkl` / `.onnx`
3. Serving via Flask/FastAPI microservice or PHP-ML port
4. Evaluation metrics (precision/recall/F1) per module — especially promo vs smish and fraud imbalance

This is **planned augmentation** of the rule-based system, not a claim of current deployment.

---

## 5. Results

### Deliverables

| Component | Outcome |
|-----------|---------|
| Backend | 6 REST endpoints; Gemini + fallback; 130+ seeded threat patterns |
| Web | Scan, URL, QR text, device checklist, feed, history, report |
| Mobile | Release APK (~69 MB) with production Railway API; QR scan, SMS auto-scan, threat map |
| Datasets | Five corpora studied; insights extracted; not used for weight training |

### Judge-ready demo scenarios

1. Paste Bangla bKash OTP phishing SMS → high risk + category badge.
2. Paste English scam call transcript → BD-localized red flags.
3. Check suspicious URL → risk bar + Bangla flag explanations.
4. QR scan (mobile) or paste payment text (web) → combined verdict.
5. Threat feed → division labels + report count.
6. Device protection → BD checklist + permission status.

### Alignment with judging criteria (Rulebook §8)

| Criterion (weight) | How we address it |
|--------------------|-------------------|
| Innovation (25%) | Bangla-first 10-module cyber-defense architecture for Bangladesh MFS |
| Technical (25%) | Full-stack deploy, dataset-informed pipeline, Gemini + fallback |
| Impact (20%) | Everyday MFS users; national threat feed by division |
| Demo (20%) | Live Railway URL + mobile APK + demo video |
| Communication (10%) | This report + Model & Data Card + Bangla UX |

---

## 6. Limitations & Future Work

### Limitations

- Risk indicators only — not 100% accurate; no legal proof.
- Gemini API dependency; fallback is less nuanced.
- Promo vs smish overlap in BangalaBarta → false positives on carrier offers.
- Payment dataset is generic, not bKash-specific.
- No live call interception; transcript paste only.
- Module 6 ELA is experimental, not deepfake ML.
- Custom ML classifiers **not yet trained** (see §4.2).

### Future work

| Priority | Plan |
|----------|------|
| Module 3 & 4 | Train **XGBoost/LightGBM** on URL features and payment fraud columns; serve via Python microservice to augment rules |
| Module 1 & 10 | Train **TF-IDF + Logistic Regression/SVM** for smish/promo/normal; reduce Gemini cost |
| Module 2 | TF-IDF binary classifier on English_Scam/NonScam + Bangla transcript augmentation |
| Modules 5, 8, 9 | Social media, identity, business fraud modules |
| Cross-cutting | Human feedback loop, URL reputation API, on-device privacy dashboard |

### Ethical considerations

- Disclaimers on every verdict (এটি ১০০% নিশ্চিত নয়).
- SMS auto-scan: finance keywords only; no bulk storage.
- Anonymous community reports; no PII required.
- All third-party datasets and models attributed in README and Model & Data Card.

---

## Conclusion

Rokkhakoboch delivers a deployable, Bangla-first scam triage MVP combining **dataset-informed rules** and **Gemini reasoning**, with a clear **ML roadmap** (Logistic Regression / SVM for text; XGBoost/LightGBM for tabular URL and fraud modules). We prioritize honest risk communication and national cyber-awareness over inflated accuracy claims.

**Team Beta:** Moniruzzaman Monir (Lead), Mufrid Johanee (Backend/QA), Raiyan Ibne Kamal (Ideation), Kazi Mukddmur Rahman Sami (Frontend UI/UX — Ananda Mohan College).

---

*Export to PDF (≤8 pages, min 10pt font) for SciBlitz submission. Include figures: architecture diagram, screenshot of verdict screen, threat map.*
