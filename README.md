# Rokkhakoboch (রক্ষাকবচ)

## Judge Quickstart

**One-line pitch:** Rokkhakoboch (রক্ষাকবচ) is an AI-powered Bangla scam detector that helps users triage suspicious MFS messages, links, QR codes, and call transcripts before money is lost — honest risk indicators, not guaranteed verdicts.

**Live demo**
- Web: https://innovative-flow-production-c724.up.railway.app
- API health: https://ai-hackthon-production.up.railway.app/up
- Mobile APK: `mobile/build/app/outputs/flutter-apk/app-release.apk` (or `app-debug.apk` after debug build)

**Run locally (3 steps)**
1. **Backend** — `cd backend` → copy `.env.example` to `.env`, set `GEMINI_API_KEY`, run `composer install`, `php artisan migrate --seed`, then `php artisan serve` (port 8000)
2. **Frontend** — `cd frontend` → `npm install` → `npm run dev` → open http://localhost:5173
3. **Mobile (optional)** — `cd mobile` → `flutter pub get` → `flutter build apk --release`

---

**AI-powered Bangla scam detector** for Bangladesh — scan MFS/SMS content, call transcripts, suspicious links, QR payment scams, and community reports through a 10‑module “National Cyber Defense” architecture.

**Tagline:** _“টাকা হারানোর আগেই ধরা পড়বে”_ — a fast, honest **risk-indicator** tool for everyday users.

---

## Problem statement

Bangladesh faces frequent MFS/OTP phishing, fake payment/QR scams, and social engineering campaigns across SMS, links, and social platforms. Most victims don’t have a simple way to **triage risk quickly in Bangla** with clear red flags and guidance.

Rokkhakoboch focuses on:
- **Bangla-first UX** (verdict + red flags + guidance)
- **Fast triage** (rule-based prefilter + Gemini reasoning + fallback when API unavailable)
- **Dataset-informed detection** (BangalaBarta smishing, URL phishing, payment fraud patterns)
- **Community intelligence** (reports + threat feed + division-level threat map)

---

## Tech stack

- **Backend**: Laravel (PHP) + MySQL (`backend/`)
- **Frontend (web)**: React + Vite + Tailwind CSS v3 (`frontend/`)
- **Mobile**: Flutter (Android/iOS project; some features Android-only) (`mobile/`)
- **AI**: Google **Gemini** (configurable model; default `gemini-2.5-flash`)
- **Maps**: `flutter_map` + OpenStreetMap tiles (no API key)
- **QR scanning**: `mobile_scanner`
- **Notifications**: Firebase Messaging + local notifications (mobile)

---

## Features (10 modules)

### Fully working (active)
- **Module 1 — এমএফএস মেসেজ সেন্টিনেল**: Paste/scan SMS text → `/api/analyze` verdict with scam category badge
  - Dataset-driven keyword prefilter from BangalaBarta (924 smishing rows)
  - Android enhancement: **optional SMS auto-scan** (toggle in Settings; finance/MFS-only filter)
- **Module 2 — কল ট্রান্সক্রিপ্ট বিশ্লেষণ**: Paste call transcript → separate Gemini prompt (English scam scripts + BD-localized patterns)
- **Module 3 — URL/ফিশিং লিংক গার্ড**: `/api/url-check` with risk score 0–100, Bangla flags, suspicious TLD/MFS/telecom heuristics
- **Module 4 — আর্থিক প্রতারণা শিল্ড**: `/api/qr-check` — combined URL + text analysis; payment fraud rules from transaction dataset
  - Web: manual QR/payment text input | Mobile: camera QR scanner
- **Module 6 — ডিপফেক/মিডিয়া ভেরিফিকেশন (experimental)**: client-side ELA “manipulation signal check” (not a real deepfake model)
- **Module 7 — ডিভাইস সুরক্ষা**: Bangladesh-specific checklist + live permission status (SMS, overlay, install, accessibility)
- **Module 10 — জাতীয় হুমকি বুদ্ধিমত্তা**: Threat feed (130+ seeded patterns) + division-level threat map

### Roadmap (coming soon placeholders)
- **Module 5 — সোশ্যাল মিডিয়া স্ক্যাম ওয়াচ**
- **Module 8 — পরিচয় সুরক্ষা**
- **Module 9 — ব্যবসায়িক সুরক্ষা**

---

## Datasets

Training/evaluation corpora live in `datasets/` (large CSVs gitignored; insights baked into code). See `datasets/README.md` and `MODEL_DATA_CARD.md`.

| Dataset | Size | Used for |
|---------|------|----------|
| BangalaBarta smishing CSV | 2,772 SMS | Prefilter keywords, Gemini few-shot, 50 DB patterns, 30 threat feed entries |
| rokkhakoboch synthetic CSV | 50 rows | Original few-shot + ScamPatternSeeder |
| URL phishing CSV | ~651k URLs | Heuristic TLD/pattern rules (`extracted_dataset_insights.json`) |
| Payment fraud CSV | 6M+ transactions | QR/payment fraud rules (TRANSFER/CASH_OUT patterns) |
| English_Scam.txt | Call transcripts | Transcript-specific Gemini prompt patterns |

After clone, place large CSVs locally in `datasets/` if re-extracting insights. Production seeding uses files in `backend/database/data/`.

---

## API (backend)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/analyze` | Analyze Bangla text (SMS / call transcript) |
| `POST` | `/api/url-check` | URL safety check with risk score + Bangla flags |
| `POST` | `/api/qr-check` | Combined QR/payment payload check (URL + text) |
| `GET` | `/api/reports` | Threat feed (scam patterns/reports) |
| `POST` | `/api/reports` | Submit a community report (optional `location_label`) |
| `GET` | `/api/history/{sessionId}` | Scan history by session id |
| `GET` | `/up` | Health check |

All analyze endpoints return: `risk_level`, `verdict_bn`, `explanation`, `flags`, `disclaimer`. URL/QR endpoints add `risk_score` (0–100) and `flags_bn`.

---

## Setup & run (local)

### Prerequisites
- PHP 8.2+, Composer
- Node.js 18+ (20 recommended)
- MySQL (XAMPP/MySQL is fine)
- Flutter SDK (for mobile)

### 1) Backend (Laravel)

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
```

Create DB (example):

```sql
CREATE DATABASE rokkhakoboch CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Run migrations + seed (50 synthetic + 50 BangalaBarta + 30 threat feed):

```bash
php artisan migrate
php artisan db:seed --force
```

Set Gemini keys in `backend/.env`:
- `GEMINI_API_KEY`
- `GEMINI_MODEL` (optional; default is fine)

Run API:

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

### 2) Frontend (React)

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

Frontend uses:
- `VITE_API_URL` (default: `http://localhost:8000/api`)

### 3) Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter analyze
flutter build apk --release
```

Release APK output:
- `mobile/build/app/outputs/flutter-apk/app-release.apk`

Debug build:
```bash
flutter build apk --debug
# → mobile/build/app/outputs/flutter-apk/app-debug.apk
```

Firebase (Android):
- Place your `google-services.json` at `mobile/android/app/google-services.json` (gitignored; do not commit)

---

## Deployment (Railway)

- **Backend**: Railway (Laravel service + MySQL plugin)
- **Frontend**: Railway (separate service, static build)

See `DEPLOYMENT.md` for live URLs, env vars, and post-deploy checklist (including `php artisan db:seed --force`).

---

## Disclaimer (honesty policy)

Rokkhakoboch provides **risk indicators**, not guarantees.
- No 100% accuracy claims
- “High risk” means “take caution and verify,” not “proven scam”
- Experimental Module 6 (ELA) is **not** a real deepfake detector
- Rule-based fallback runs when Gemini API is unavailable

---

## Documentation

| File | Purpose |
|------|---------|
| `README.md` | This file — quickstart & overview |
| `PROJECT_REPORT.md` | Full hackathon report (problem, methodology, results) |
| `DEPLOYMENT.md` | Railway deploy guide + live URLs |
| `MODEL_DATA_CARD.md` | AI model & dataset transparency card |
| `datasets/README.md` | Dataset inventory & usage in this project |

---

## Team / credits

**Team Beta** — Hackathon submission

| Member | Role | Institution |
|--------|------|-------------|
| Moniruzzaman Monir | Team Leader & Project Management | University of Frontier Technology, Bangladesh |
| Mufrid Johanee | Functionality & Backend Testing | University of Frontier Technology, Bangladesh |
| Raiyan Ibne Kamal | Idea Generator | University of Frontier Technology, Bangladesh |
| Kazi Mukddmur Rahman Sami | Frontend UI/UX Developer | Ananda Mohan College |

**Credits**
- BangalaBarta / BangalaBart smishing dataset (Mendeley Data) — pattern reference & seeding
- OpenStreetMap contributors (map tiles)
- Flutter ecosystem packages: `mobile_scanner`, `flutter_map`, `permission_handler`, etc.
- Google Gemini API (AI analysis)
