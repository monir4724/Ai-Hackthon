# Rokkhakoboch — Backend (Laravel)

REST API for Bangla scam detection: rule-based prefilter + Google Gemini inference + rule-based fallback.

## Live

- API: https://ai-hackthon-production.up.railway.app/api
- Health: https://ai-hackthon-production.up.railway.app/up

## Setup

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
```

Configure `.env`:
- `DB_*` — MySQL connection
- `GEMINI_API_KEY` — Google AI Studio key
- `GEMINI_MODEL=gemini-2.5-flash` (optional)
- `FRONTEND_URL` — for CORS (production)

```bash
php artisan migrate
php artisan db:seed --force
php artisan serve
```

## API endpoints

| Method | Path | Controller | Description |
|--------|------|------------|-------------|
| POST | `/api/analyze` | AnalyzeController | SMS / call transcript analysis |
| POST | `/api/url-check` | UrlCheckController | URL heuristics + Bangla flags |
| POST | `/api/qr-check` | QrCheckController | Combined QR/payment check |
| GET | `/api/reports` | ReportController | Threat feed |
| POST | `/api/reports` | ReportController | Community report |
| GET | `/api/history/{sessionId}` | ScanHistoryController | Scan history |

## Key services

| Service | Purpose |
|---------|---------|
| `RuleBasedPrefilterService` | Dataset-informed keyword prefilter |
| `GeminiScamAnalyzer` | Gemini API (SMS + transcript prompts) |
| `ScamAnalysisService` | Orchestrates prefilter → Gemini → fallback |
| `UrlSafetyService` | URL heuristics from phishing dataset insights |
| `QrSafetyService` | Combined URL + text + payment fraud rules |
| `ScamCategoryDetector` | Maps flags to Bangla scam category labels |
| `BanglaFlagLabels` | Bangla flag labels and explanations |

## Seeders

```
ScamPatternSeeder      → 50 synthetic patterns
BangalaBartaSeeder     → 50 real smishing patterns
ThreatFeedSeeder       → 30 threat entries with location_label
```

Data sources: `database/data/` and `../datasets/` (via `DatasetRepository`).

## Dataset insights

Pre-extracted patterns: `database/data/extracted_dataset_insights.json`

Large CSVs (651k URLs, 6M transactions) are gitignored; insights are baked into PHP services.

## Deployment

Railway root directory: `backend`. See root `DEPLOYMENT.md`.
