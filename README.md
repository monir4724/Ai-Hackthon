# Rokkhakoboch (রক্ষাকবচ)

AI-powered Bangla scam message detector — hackathon MVP with 10-module national cyber defense architecture.

## Stack

- **Frontend:** React + Vite + Tailwind CSS (`frontend/`)
- **Backend:** Laravel 12 + MySQL (`backend/`)
- **AI:** OpenAI GPT-4o (optional — rule-based mock fallback when no API key)

## Local Development

Uses `php artisan serve` on port 8000 (faster iteration than XAMPP vhost).

### Prerequisites

- XAMPP: Apache + MySQL running
- PHP 8.2+, Composer, Node 18+

### Database

```sql
CREATE DATABASE rokkhakoboch CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

```bash
cd backend
php artisan migrate
php artisan db:seed
```

### Backend

```bash
cd backend
cp .env.example .env   # if needed
# Set OPENAI_API_KEY in .env for live AI
php artisan serve
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173 — API proxied to http://localhost:8000/api

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/analyze` | Analyze SMS/call transcript |
| POST | `/api/url-check` | URL safety check |
| GET | `/api/reports` | Scam pattern feed |
| POST | `/api/reports` | Community report |
| GET | `/api/history/{sessionId}` | Scan history |

## Modules (10-Module Architecture)

1. MFS Message Sentinel — **active**
2. Call Transcript Analysis — **active**
3. URL Phishing Guard — **active**
4–9. Financial, Social, Deepfake, Device, Identity, Business — **roadmap**
10. National Threat Intelligence — **partial** (community feed)

## Deployment

- **Backend:** Railway or Render (PHP/Laravel + MySQL)
- **Frontend:** Railway static, Render, or Netlify (SPA)
- Do NOT use Vercel for Laravel backend

See `DEPLOYMENT.md` for details.

## Disclaimer

This tool provides **risk indicators**, not guarantees. Never claim 100% accuracy.
