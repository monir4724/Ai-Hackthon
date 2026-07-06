# Deployment Guide — Rokkhakoboch

## Recommended Host: Railway

**Why Railway:** Native PHP/Laravel support, MySQL plugin, simple env vars, free tier for hackathon demos.

### Backend (Laravel)

1. Create Railway project → Deploy from GitHub
2. Set root directory: `backend`
3. Add MySQL service, link `DATABASE_URL` or set:
   - `DB_CONNECTION=mysql`
   - `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
4. Set env vars:
   - `APP_KEY` (run `php artisan key:generate --show` locally)
   - `APP_ENV=production`
   - `APP_DEBUG=false`
   - `APP_URL=https://your-backend.up.railway.app`
   - `OPENAI_API_KEY=sk-...`
5. Build command: `composer install --no-dev --optimize-autoloader`
6. Start command: `php artisan migrate --force && php artisan db:seed --force && php artisan serve --host=0.0.0.0 --port=$PORT`

### Frontend (React)

1. Second Railway service OR Netlify
2. Root: `frontend`
3. Build: `npm ci && npm run build`
4. Set `VITE_API_URL=https://your-backend.up.railway.app/api`
5. Serve `dist/` as static site

### Alternative: Render

- Web Service for Laravel (Dockerfile or native PHP)
- Static Site for frontend
- Render PostgreSQL can be used but brief specifies MySQL — use Railway MySQL or PlanetScale

## Post-Deploy Checklist

- [ ] `GET /up` returns 200
- [ ] `POST /api/analyze` returns JSON verdict
- [ ] Frontend loads and scans end-to-end
- [ ] Community feed shows seeded patterns

## STOP — Credentials Needed

Before live deploy, provide:
- `OPENAI_API_KEY` in backend `.env`
- Railway/Render account approval for deployment
