# Rokkhakoboch — Frontend (React + Vite)

Bangla scam detection web app. Static SPA deployed separately from the Laravel backend.

## Live

https://innovative-flow-production-c724.up.railway.app

## Setup

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173

## Environment

Copy `.env.example` to `.env`:

```
VITE_API_URL=http://localhost:8000/api
```

Production build uses `frontend/.env.production` (Railway API URL) as fallback.

## Build

```bash
npm run build
# Output: dist/
```

Node 18 is required (pinned via `.nvmrc`).

## Active pages

| Route | Module | Description |
|-------|--------|-------------|
| `/scan` | 1, 2 | SMS scan + call transcript (multiline) |
| `/url-check` | 3 | URL phishing guard with risk score bar |
| `/qr-check` | 4 | Manual QR/payment text input (no camera on web) |
| `/device-protection` | 7 | Bangladesh device security checklist |
| `/feed` | 10 | Threat feed with report count + division labels |
| `/result` | — | Verdict with category badge, flags, disclaimer |
| `/history` | — | Session-based scan history |
| `/report` | 10 | Submit community scam report |

Module list and status: `src/config/modules.ts`

## Tech stack

- React 19 + TypeScript
- Vite 6
- Tailwind CSS v3
- React Router

## Deployment (Railway)

Root directory: `frontend`. See root `DEPLOYMENT.md` for env vars and build command.
