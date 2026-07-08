# Deployment Guide — Rokkhakoboch

## Live URLs

| Service | URL |
|---------|-----|
| Frontend | https://innovative-flow-production-c724.up.railway.app |
| Backend | https://ai-hackthon-production.up.railway.app |
| Health | https://ai-hackthon-production.up.railway.app/up |
| API base | https://ai-hackthon-production.up.railway.app/api |

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

**Seeding on deploy:** Ensure `php artisan db:seed --force` runs after migrate. This loads:
- 50 synthetic patterns (`ScamPatternSeeder`)
- 50 BangalaBarta smishing patterns (`BangalaBartaSeeder`)
- 30 threat feed entries with division labels (`ThreatFeedSeeder`)

Seeder data files are in `backend/database/data/` (BangalaBarta CSV, English_Scam.txt, extracted insights JSON). No need for the full 651k/6M CSVs on Railway.

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
- [ ] `POST /api/analyze` returns JSON verdict with Bangla explanation + `scam_category`
- [ ] `POST /api/url-check` returns URL risk score (0–100) + `flags_bn`
- [ ] `POST /api/qr-check` returns combined URL + text verdict
- [ ] `GET /api/reports` returns 130+ seeded patterns with `location_label`
- [ ] `php artisan db:seed --force` completed on production DB
- [ ] Frontend loads and scans end-to-end against live backend
- [ ] CORS allows frontend origin (`FRONTEND_URL` in backend env)
- [ ] Web modules active: Scan, URL check, QR check (manual), Device protection, Feed
- [ ] Mobile APK points to production API (`mobile/lib/core/api/api_config.dart`)

## Required Credentials

Before live deploy, provide:

- `GEMINI_API_KEY` in backend Railway variables
- `APP_KEY` for Laravel encryption
- Railway account with GitHub deploy connected

## Mobile APK Distribution

Build locally and distribute the APK directly (not deployed to Railway):

```bash
cd mobile
flutter pub get
flutter build apk --release
# Output: mobile/build/app/outputs/flutter-apk/app-release.apk
```

Ensure `ApiConfig.baseUrl` in the mobile app matches the production backend URL.
