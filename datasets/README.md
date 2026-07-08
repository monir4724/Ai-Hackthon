# Datasets — Rokkhakoboch

This folder contains reference corpora used to inform rule-based detection, Gemini few-shot prompts, and database seeders. See also `MODEL_DATA_CARD.md` at the repo root.

## Files in this project

| File | Size | In git? | Used for |
|------|------|---------|----------|
| `BangalaBarta bangla_spam_sms smishing.csv` | 2,772 rows | Yes | Module 1, 10 — prefilter keywords, few-shot, seeders |
| `rokkhakoboch_synthetic_dataset_bn.csv` | 50 rows | Yes | Module 1, 10 — original few-shot + ScamPatternSeeder |
| `English_Scam.txt` | Call scripts | Yes | Module 2 — transcript Gemini prompt |
| `English_NonScam.txt` | Reference | Yes | Negative examples (design reference) |
| `dataset_with_all_features v2 module 3.csv` | ~651k URLs | **No** (gitignored) | Module 3 — URL heuristics |
| `final_dataset_with_all_features module 3.csv` | ~651k URLs | **No** | Module 3 — alternate URL corpus |
| `final_dataset_with_all_features_v3.1 module 3.csv` | ~651k URLs | **No** | Module 3 — alternate URL corpus |
| `PS_20174392719_1491204439457_log module 4.csv` | 6M+ rows | **No** | Module 4 — payment fraud rules |
| `module 3.1.xml` | XML export | **No** | Module 3 — reference only |
| `README module 10.md` | External index | Yes | Bangla NLP dataset bibliography (reference) |

## Extracted insights

Automated extraction output (committed):

```
backend/database/data/extracted_dataset_insights.json
```

Contains: smishing keywords by category, suspicious TLDs, URL patterns, payment fraud type frequencies, few-shot example texts.

## Re-extracting insights locally

Place large CSVs in this folder, then run the extraction script (if available) or inspect `DatasetRepository` / seeders for consumption paths.

Backend resolves datasets from (in order):
1. `../datasets/` (monorepo root)
2. `backend/datasets/`
3. `backend/database/data/` (small copies for Railway)

## Seeding production

Railway backend only needs files in `backend/database/data/`:
- `BangalaBarta bangla_spam_sms smishing.csv`
- `English_Scam.txt`
- `rokkhakoboch_synthetic_dataset_bn.csv` (also in `backend/database/data/`)

Run after deploy:
```bash
php artisan db:seed --force
```

## Module mapping

| Module | Primary datasets |
|--------|------------------|
| 1 — SMS Sentinel | BangalaBarta, synthetic |
| 2 — Call Transcript | English_Scam.txt |
| 3 — URL Guard | URL phishing CSVs → insights JSON |
| 4 — Financial/QR | Payment fraud CSV → insights JSON |
| 10 — Threat Intel | BangalaBarta → ThreatFeedSeeder |

## Attribution

- **BangalaBarta / BangalaBart** — Mendeley Data ([dataset link](https://data.mendeley.com/datasets/jfkfbw3gzh/2))
- **Payment fraud CSV** — IEEE-CIS fraud detection style transaction log (reference corpus)
- **Synthetic CSV** — Team Beta, hackathon 2026
