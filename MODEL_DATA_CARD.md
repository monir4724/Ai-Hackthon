# Model & Data Card — Rokkhakoboch (রক্ষাকবচ)

**SciBlitz AI Challenge 2026 · Team Beta · Track E (National Defence)**  
**Team Lead:** Moniruzzaman Monir · **Institution:** University of Frontier Technology, Bangladesh  
**Live demo:** https://innovative-flow-production-c724.up.railway.app · **GitHub:** https://github.com/monir4724/Ai-Hackthon  
**Last updated:** July 8, 2026

---

## Pre-trained model deployed (current MVP)

| Field | Detail |
|-------|--------|
| **Model** | Gemini 2.5 Flash |
| **Provider** | Google Generative Language API |
| **License / Terms** | Google AI Studio / Gemini API Terms of Service |
| **Usage** | Zero-shot + few-shot prompting (SMS + call transcript); no weight fine-tuning |
| **Integration** | Laravel backend → structured JSON verdict; rule-based fallback when API unavailable |
| **Temperature** | 0.2 (low-variance triage) |

**Honest scope:** We do **not** ship custom-trained `.pkl`/`.onnx` classifiers in this submission. Datasets informed **rule-based prefilters**, **few-shot examples**, and **DB seeders**. Custom ML classifiers are documented below as **recommended future work**.

---

## Datasets used (source & attribution)

| # | Dataset | Source | Size | Classes | Used in MVP |
|---|---------|--------|------|---------|-------------|
| 1 | `rokkhakoboch_synthetic_dataset_bn.csv` | Team Beta (original) | 50 | scam / legit | Few-shot prompt, `ScamPatternSeeder` |
| 2 | `BangalaBarta bangla_spam_sms smishing.csv` | [Mendeley — BangalaBart](https://data.mendeley.com/datasets/jfkfbw3gzh/2) | 2,772 | smish / promo / normal | Keyword prefilter, few-shot, seeders (Modules 1, 10) |
| 3 | `dataset_with_all_features v2 module 3.csv` | Phishing URL research corpus (Frontiers 2024, DOI 10.3389/fcomp.2024.1308634) | ~651k | phishing / benign / defacement / malware | Heuristic rules → `UrlSafetyService` (Module 3) |
| 4 | `PS_20174392719_1491204439457_log module 4.csv` | IEEE-CIS-style payment fraud log | 6.3M+ | isFraud 0/1 | QR/payment rules → `QrSafetyService` (Module 4) |
| 5 | `English_Scam.txt` / `English_NonScam.txt` | Reference call scripts | ~800 each | scam / non-scam | Transcript Gemini prompt (Module 2) |

Large CSVs (3–4) are gitignored locally; insights stored in `backend/database/data/extracted_dataset_insights.json`.

---

## Dataset অনুযায়ী কোন ML Model — Module by Module

Task type অনুযায়ী model choice করতে হয়। প্রতিটা dataset আলাদা ধরনের সমস্যা (text classification vs tabular classification vs imbalanced fraud), তাই আলাদা model লাগবে।

### Module 1 & 10 — BangalaBarta SMS (Text Classification, 3-class: smish/promo/normal)

| Priority | Model | কেন |
|----------|-------|-----|
| Best fit | **Logistic Regression (TF-IDF)** | Fast, interpretable baseline; probability scores help with promo vs smish overlap |
| Better accuracy | **SVM (Linear kernel)** | Strong on high-dimensional sparse TF-IDF text vectors |
| Ensemble | **Random Forest / XGBoost / LightGBM** | Subtle promo vs smish patterns |
| Baseline | **Multinomial Naive Bayes** | Classic text baseline, quick to train |

Avoid: KNN (slow on sparse text), Linear Regression (classification task), K-means/DBSCAN (labels already available).

**MVP status:** Gemini few-shot + rule-based keywords — **not** trained LR/SVM yet.

---

### Module 3 — URL Phishing (Tabular, 4-class, 58–64 engineered features)

| Priority | Model | কেন |
|----------|-------|-----|
| Best fit | **XGBoost / LightGBM** | Industry standard for tabular phishing detection (TLD, IP, brand-in-subdomain flags) |
| Close second | **Random Forest** | Feature importance for explainability |
| Simple baseline | **Decision Tree** | Demo-friendly "why high risk" explanations |

Avoid: SVM (651k rows = slow), KNN (slow inference), Naive Bayes (feature independence breaks here).

**MVP status:** Rule-based heuristics extracted from dataset — **not** trained XGBoost yet.

---

### Module 4 — Payment Fraud (Tabular, highly imbalanced binary, 6.3M rows)

| Priority | Model | কেন |
|----------|-------|-----|
| Best fit | **LightGBM** | Fastest on 6M+ rows; `scale_pos_weight` for imbalance |
| Also strong | **XGBoost** | Proven in Kaggle fraud competitions |
| Alternative | **Random Forest** | Less tuning, robust |

Avoid: Logistic Regression alone (low recall on severe imbalance), ANN (boosting usually wins on large tabular).

**MVP status:** TRANSFER/CASH_OUT heuristics from dataset analysis — **not** trained LightGBM yet.

---

### Module 2 — English Scam/Non-Scam Transcripts (Text Classification, binary)

| Priority | Model | কেন |
|----------|-------|-----|
| Best fit | **Logistic Regression (TF-IDF)** | Balanced ~800 vs 800, simple and effective |
| Better | **SVM (Linear)** | Consistent on text |
| If time permits | **Fine-tuned DistilBERT** | Higher accuracy, more compute |

**MVP status:** Gemini transcript prompt + English_Scam patterns — **not** trained TF-IDF classifier yet.

---

### Overall summary

| Module | Data type | Recommended model | Backup | MVP today |
|--------|-----------|-------------------|--------|-----------|
| 1, 10 | Text (3-class) | Logistic Regression | SVM / LightGBM | Gemini + rules |
| 3 | Tabular (4-class) | XGBoost / LightGBM | Random Forest | Heuristic rules |
| 4 | Tabular (imbalanced) | LightGBM | XGBoost | Heuristic rules |
| 2 | Text (binary) | Logistic Regression | SVM | Gemini prompt |

---

## Known limitations

- No custom ML model trained or evaluated in this submission (no accuracy % claimed).
- Gemini API dependency — rate limits, latency; rule-based fallback is less nuanced.
- BangalaBarta promo vs smish overlap → false positives possible on legitimate carrier offers.
- Payment fraud dataset is generic (not bKash/Nagad-specific); QR rules are heuristic.
- SMS auto-scan: Android only; finance-keyword filter; no bulk SMS storage.
- Outputs are **risk indicators**, not legal proof — disclaimer on every verdict.

---

## Ethical considerations

- **False positives** may cause unnecessary alarm; **false negatives** may create false confidence.
- **Advisory only** — does not block payments or accuse individuals.
- **Privacy:** SMS auto-scan analyzes finance-keyword matches only; discarded in memory.
- **Community reports:** anonymous; optional division tag only.
- **Third-party attribution:** BangalaBart (Mendeley), Google Gemini API, OpenStreetMap tiles, Flutter/React/Laravel OSS — all listed in README.

---

## Third-party resources (attribution required by rulebook)

| Resource | License / Terms |
|----------|-----------------|
| Google Gemini 2.5 Flash | Google AI API Terms |
| BangalaBart dataset | Mendeley Data terms — cite in publications |
| Laravel, React, Flutter | MIT / BSD open-source |
| OpenStreetMap | ODbL (map tiles, mobile threat map) |

**Export note:** Convert this file to **single-page PDF** for SciBlitz submission form upload.
