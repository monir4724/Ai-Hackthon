# Model & Data Card — Rokkhakoboch (রক্ষাকবচ)

**Project:** Rokkhakoboch — AI-assisted Bangla scam risk indicator  
**Team:** Team Beta  
**Last updated:** July 2026  

---

## Pre-trained model used

| Field | Detail |
|-------|--------|
| **Model** | Gemini 2.5 Flash |
| **Provider** | Google (Generative Language API) |
| **Usage** | API inference only — zero-shot + few-shot prompting |
| **Fine-tuning** | None performed in this project |
| **Fallback** | Rule-based heuristic engine when API unavailable |
| **Prompts** | Separate templates for SMS vs call transcript; all include Bangladesh MFS context (bKash, Nagad, Rocket) |

We do **not** host or ship a custom-trained ML model. All "AI" behavior is prompt-engineered inference plus deterministic, dataset-informed rules.

---

## Dataset 1 — Synthetic corpus (primary seed)

| Field | Detail |
|-------|--------|
| **File** | `rokkhakoboch_synthetic_dataset_bn.csv` |
| **Size** | 50 rows |
| **Origin** | Manually created by Team Beta for this hackathon |
| **Label** | `is_synthetic=TRUE` on all rows |
| **Language** | Bangla (বাংলা) |
| **Categories** | OTP phishing, lottery scam, send-money reversal, fake agent, SIM-swap cues, fake cashback, urgency lures, call transcript examples |
| **Used for** | Few-shot examples in Gemini prompt; `ScamPatternSeeder` (50 DB rows) |
| **Limitation** | Small, synthetic, not representative of all real-world scam diversity |

---

## Dataset 2 — BangalaBarta smishing corpus

| Field | Detail |
|-------|--------|
| **File** | `BangalaBarta bangla_spam_sms smishing.csv` |
| **Source** | Mendeley Data — [BangalaBart dataset](https://data.mendeley.com/datasets/jfkfbw3gzh/2) |
| **Size** | 2,772 messages (924 smishing, remainder promo/normal) |
| **Classes** | smish, promo, normal |
| **Coverage** | Bangladeshi telecom contexts (Grameenphone, Banglalink, Robi) |
| **Used for** | (1) Rule-based prefilter keyword extraction (OTP, account lock, MFS, lottery, job, investment, urgency); (2) 15 real few-shot examples in Gemini prompt; (3) `BangalaBartaSeeder` (+50 DB patterns); (4) `ThreatFeedSeeder` (+30 entries with division labels) |
| **Not used for** | Model fine-tuning or weight training |
| **Attribution** | Cite Mendeley Data / BangalaBart per original dataset terms |

---

## Dataset 3 — URL phishing corpus

| Field | Detail |
|-------|--------|
| **File** | `dataset_with_all_features v2 module 3.csv` (local only; gitignored) |
| **Size** | ~651,000 URLs |
| **Classes** | phishing, benign, malware, defacement |
| **Used for** | Heuristic rules in `UrlSafetyService`: suspicious TLDs (.tk, .ml, .ga, .cf, .gq), brand-in-subdomain, hyphen density, IP URLs, encoded characters, MFS/telecom impersonation patterns |
| **Stored insights** | `backend/database/data/extracted_dataset_insights.json` |
| **Not used for** | Model training |

---

## Dataset 4 — Payment fraud transactions

| Field | Detail |
|-------|--------|
| **File** | `PS_20174392719_1491204439457_log module 4.csv` (local only; gitignored) |
| **Size** | 6M+ transactions |
| **Columns** | step, type, amount, nameOrig, balances, nameDest, isFraud, isFlaggedFraud |
| **Used for** | QR/payment fraud rules in `QrSafetyService`: TRANSFER/CASH_OUT dominance among fraud, sender balance → 0 pattern, receiver 0 → large credit pattern, bKash/Nagad/Rocket QR indicators |
| **Stored insights** | `backend/database/data/extracted_dataset_insights.json` |
| **Not used for** | Model training |

---

## Dataset 5 — English scam call transcripts

| Field | Detail |
|-------|--------|
| **File** | `English_Scam.txt` |
| **Size** | Multiple call script transcripts |
| **Used for** | Transcript-specific Gemini prompt patterns: government grant scams, fake tech support, prize scams, charity fraud, police impersonation; plus BD-localized variants (BTRC, bKash agent, fake bank officer) |
| **Also copied to** | `backend/database/data/English_Scam.txt` for Railway seeding context |

---

## Seeders (database)

| Seeder | Rows | Source |
|--------|------|--------|
| `ScamPatternSeeder` | 50 | Synthetic CSV |
| `BangalaBartaSeeder` | 50 | BangalaBarta smish rows |
| `ThreatFeedSeeder` | 30 | BangalaBarta snippets + random division labels |

Run: `php artisan db:seed --force`

---

## Known limitations

- **Small synthetic corpus (50 rows)** — baseline few-shot; real diversity comes from BangalaBarta extraction.
- **Large CSVs not in git** — insights pre-extracted; re-extraction requires local CSV copies.
- **API rate limits** — Gemini quotas may throttle live analysis during demos.
- **Not 100% accurate** — outputs are risk indicators, not legal proof of fraud.
- **Bangla-first** — mixed-language messages may receive weaker SMS analysis (transcript mode handles English better).
- **No live call interception** — analysis is text/transcript paste only.
- **No fine-tuning** — model behavior depends on prompting and prefilter rules, not custom weights.

---

## Ethical considerations

- **False positives** may cause unnecessary fear; **false negatives** may create false confidence. Every verdict includes an advisory disclaimer (এটি ১০০% নিশ্চিত নয়).
- **Advisory framing** — the tool educates and warns; it does not block payments or accuse individuals.
- **Privacy (SMS auto-scan, Android)** — only finance/MFS-keyword-matching SMS are analyzed; non-matching messages are discarded in memory without storage or logging.
- **Community reports** — anonymous; no name required; optional division tag only.
- **Experimental media module** — ELA is labeled as non-definitive; must not be presented as deepfake proof.

---

## Summary

Rokkhakoboch combines **multiple reference corpora** (synthetic, BangalaBarta, URL phishing, payment fraud, English call scripts) with **Gemini 2.5 Flash API inference** and **dataset-informed rule-based prefilters**. No fine-tuning was performed. Extracted insights are baked into PHP services and JSON; honest scope and user safety are prioritized over accuracy claims.
