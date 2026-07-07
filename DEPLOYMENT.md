# Deployment Guide — Rokkhakoboch

## Live URLs

| Service | URL |
|---------|-----|
| Frontend | https://innovative-flow-production-c724.up.railway.app |
| Backend | https://ai-hackthon-production.up.railway.app |
| Health | https://ai-hackthon-production.up.railway.app/up |

## Recommended Host: Railway

**Why Railway:** Native PHP/Laravel support, MySQL plugin, simple env vars, free tier for hackathon demos.

### Backend (Laravel)

1. Create Railway project → Deploy from GitHub
2. Set root directory: `backend`
3. Add MySQL service, link plugin vars:
   - `DB_CONNECTION=mysql`
   - `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
4. Set env vars:
   - `APP_KEY` (run `php artisan key:generate --show` locally)
   - `APP_ENV=production`
   - `APP_DEBUG=false`
   - `APP_URL=https://ai-hackthon-production.up.railway.app`
   - `FRONTEND_URL=https://innovative-flow-production-c724.up.railway.app`
   - `GEMINI_API_KEY=...` (Google AI Studio)
   - `GEMINI_MODEL=gemini-2.5-flash`
5. Build: `composer install --no-dev --optimize-autoloader` (via `nixpacks.toml`)
6. Start: migrate + seed + serve (via `railway.json` / `Procfile`)

### Frontend (React)

1. Second Railway service in same project
2. Root directory: `frontend`
3. Build: `npm install --include=dev && npm run build` (via `railway.json`)
4. Set at **build time**:
   - `VITE_API_URL=https://ai-hackthon-production.up.railway.app/api`
5. Start: `npx serve dist -s -l $PORT`
6. Node 18 is pinned via `.nvmrc`, `.node-version`, `engines`, and `nixpacks.toml`

> **Note:** `frontend/.env.production` in the repo also sets the production API URL as a fallback.

### Alternative: Render

- Web Service for Laravel (Dockerfile or native PHP)
- Static Site for frontend
- Brief specifies MySQL — use Railway MySQL or PlanetScale

## Post-Deploy Checklist

- [ ] `GET /up` returns 200
- [ ] `POST /api/analyze` returns JSON verdict with Bangla explanation
- [ ] `POST /api/url-check` returns URL risk assessment
- [ ] `GET /api/reports` returns seeded + community patterns
- [ ] Frontend loads and scans end-to-end against live backend
- [ ] CORS allows frontend origin

## Required Credentials

Before live deploy, provide:

- `GEMINI_API_KEY` in backend Railway variables
- `APP_KEY` for Laravel encryption
- Railway account with GitHub deploy connected
