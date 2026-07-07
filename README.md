# Rokkhakoboch (রক্ষাকবচ)

## Judge Quickstart

**One-line pitch:** Rokkhakoboch (রক্ষাকবচ) is an AI-powered Bangla scam detector that helps users triage suspicious MFS messages, links, and QR codes before money is lost — honest risk indicators, not guaranteed verdicts.

**Live demo**
- Web: _TBD — add Railway URL after deploy_
- API health: _TBD_/up
- Mobile APK: `mobile/build/app/outputs/flutter-apk/app-release.apk`

**Run locally (3 steps)**
1. **Backend** — `cd backend` → copy `.env.example` to `.env`, set `GEMINI_API_KEY`, run `composer install`, `php artisan migrate --seed`, then `php artisan serve` (port 8000)
2. **Frontend** — `cd frontend` → `npm install` → `npm run dev` → open http://localhost:5173
3. **Mobile (optional)** — `cd mobile` → `flutter pub get` → `flutter build apk --release`

---

**AI-powered Bangla scam detector** for Bangladesh — scan MFS/SMS content, suspicious links, QR payment scams, and community reports through a 10‑module “National Cyber Defense” architecture.

**Tagline:** _“টাকা হারানোর আগেই ধরা পড়বে”_ — a fast, honest **risk-indicator** tool for everyday users.

---

## Problem statement

Bangladesh faces frequent MFS/OTP phishing, fake payment/QR scams, and social engineering campaigns across SMS, links, and social platforms. Most victims don’t have a simple way to **triage risk quickly in Bangla** with clear red flags and guidance.

Rokkhakoboch focuses on:
- **Bangla-first UX** (verdict + red flags + guidance)
- **Fast triage** (rule-based prefilter + Gemini reasoning)
- **Community intelligence** (reports + threat feed + threat map)

---

## Tech stack

- **Backend**: Laravel (PHP) + MySQL (`backend/`)
- **Frontend (web)**: React + Vite (`frontend/`)
- **Mobile**: Flutter (Android/iOS project; some features Android-only) (`mobile/`)
- **AI**: Google **Gemini** (configurable model; default `gemini-2.5-flash`)
- **Maps**: `flutter_map` + OpenStreetMap tiles (no API key)
- **QR scanning**: `mobile_scanner`
- **Notifications**: Firebase Messaging + local notifications (mobile)

---

## Features (10 modules)

### Fully working (active)
- **Module 1 — এমএফএস মেসেজ সেন্টিনেল**: Paste/scan SMS text → `/api/analyze` verdict
  - Android enhancement: **optional SMS auto-scan** (toggle in Settings; finance/MFS-only filter)
- **Module 2 — কল ট্রান্সক্রিপ্ট বিশ্লেষণ**: Paste transcript → analyze
- **Module 3 — URL/ফিশিং লিংক গার্ড**: `/api/url-check` verdict
- **Module 4 — আর্থিক প্রতারণা শিল্ড**: QR scan → auto URL/text analysis
- **Module 6 — ডিপফেক/মিডিয়া ভেরিফিকেশন (experimental)**: client-side ELA “manipulation signal check” (not a real deepfake model)
- **Module 7 — ডিভাইস সুরক্ষা**: Play-Store-safe self-permission checklist (educational awareness; does not scan other apps)
- **Module 10 — জাতীয় হুমকি বুদ্ধিমত্তা**: Threat feed + threat map (division-level heat overview)

### Roadmap (coming soon placeholders)
- **Module 5 — সোশ্যাল মিডিয়া স্ক্যাম ওয়াচ**
- **Module 8 — পরিচয় সুরক্ষা**
- **Module 9 — ব্যবসায়িক সুরক্ষা**

---

## API (backend)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/analyze` | Analyze Bangla text (SMS/transcript/auto-sms) |
| `POST` | `/api/url-check` | URL safety check |
| `GET` | `/api/reports` | Community feed (scam patterns/reports) |
| `POST` | `/api/reports` | Submit a community report (optional `location_label`) |
| `GET` | `/api/history/{sessionId}` | Scan history by session id |
| `GET` | `/up` | Health check |

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

Run migrations + seed:

```bash
php artisan migrate
php artisan db:seed
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

Firebase (Android):
- Place your `google-services.json` at `mobile/android/app/google-services.json` (gitignored; do not commit)

---

## Deployment (Railway)

- **Backend**: Railway (Laravel service + MySQL plugin)
- **Frontend**: Railway (separate service, static build)

See `DEPLOYMENT.md` for additional notes.

---

## Disclaimer (honesty policy)

Rokkhakoboch provides **risk indicators**, not guarantees.
- No 100% accuracy claims
- “High risk” means “take caution and verify,” not “proven scam”
- Experimental Module 6 (ELA) is **not** a real deepfake detector

---

## Screenshots

> TODO: Add screenshots here (web + mobile flows).

- Home / Scan / Result
- URL check
- QR scan
- Threat feed + threat map
- Settings (SMS auto-scan toggle)
- Experimental media check

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
- OpenStreetMap contributors (map tiles)
- Flutter ecosystem packages: `mobile_scanner`, `flutter_map`, `permission_handler`, etc.
- Google Gemini API (AI analysis)
