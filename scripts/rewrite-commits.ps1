# Rewrite local git history into granular build-order commits
Set-Location "e:\baadbaki\competition\main code"

git reset --soft bbf258a
git reset HEAD

function Commit-Phase($msg, $paths) {
    foreach ($p in $paths) {
        if (Test-Path $p) { git add $p }
    }
    git commit -m $msg
}

Commit-Phase "initial project setup" @(
    ".gitignore", "README.md", "DEPLOYMENT.md", "data", "rokkhakoboch_synthetic_dataset_bn.csv",
    "stitch_rokkhakoboch_ai_scam_protection",
    "backend/composer.json", "backend/composer.lock", "backend/artisan", "backend/bootstrap",
    "backend/config/app.php", "backend/config/auth.php", "backend/config/cache.php", "backend/config/database.php",
    "backend/config/filesystems.php", "backend/config/logging.php", "backend/config/mail.php",
    "backend/config/queue.php", "backend/config/session.php",
    "backend/database/factories", "backend/database/migrations/0001_01_01_000000_create_users_table.php",
    "backend/database/migrations/0001_01_01_000001_create_cache_table.php",
    "backend/database/migrations/0001_01_01_000002_create_jobs_table.php",
    "backend/public", "backend/resources", "backend/routes/web.php", "backend/routes/console.php",
    "backend/storage", "backend/tests/Feature/ExampleTest.php", "backend/tests/TestCase.php", "backend/tests/Unit",
    "backend/.editorconfig", "backend/.env.example", "backend/.gitattributes", "backend/.gitignore",
    "backend/README.md", "backend/phpunit.xml", "backend/package.json", "backend/vite.config.js",
    "backend/app/Models/User.php", "backend/app/Http/Controllers/Controller.php", "backend/app/Providers",
    "frontend/package.json", "frontend/package-lock.json", "frontend/tsconfig.json", "frontend/tsconfig.app.json",
    "frontend/tsconfig.node.json", "frontend/vite.config.ts", "frontend/index.html", "frontend/public",
    "frontend/.gitignore", "frontend/.oxlintrc.json", "frontend/README.md", "frontend/src/main.tsx",
    "frontend/src/assets"
)

Commit-Phase "basic API scaffold" @(
    "backend/routes/api.php", "backend/bootstrap/app.php", "backend/config/cors.php",
    "backend/app/Http/Controllers/Api/AnalyzeController.php", "backend/app/Services/ScamAnalysisService.php",
    "backend/config/services.php"
)

Commit-Phase "frontend scan flow with mock data" @(
    "frontend/src/App.tsx", "frontend/src/lib/api.ts", "frontend/src/pages/HomePage.tsx",
    "frontend/src/pages/ScanPage.tsx", "frontend/src/pages/ResultPage.tsx",
    "frontend/src/components/Layout.tsx", "frontend/src/components/Navbar.tsx"
)

Commit-Phase "GPT-4o integration for scam analysis" @(
    "backend/app/Services/OpenAiScamAnalyzer.php"
)

Commit-Phase "rule-based pre-filter" @(
    "backend/app/Services/RuleBasedPrefilterService.php"
)

Commit-Phase "database + community reporting" @(
    "backend/database/migrations/2026_07_06_000001_create_scam_patterns_table.php",
    "backend/database/data", "backend/app/Models/ScamPattern.php",
    "backend/database/seeders/ScamPatternSeeder.php", "backend/database/seeders/DatabaseSeeder.php",
    "backend/app/Http/Controllers/Api/ReportController.php",
    "frontend/src/pages/FeedPage.tsx", "frontend/src/pages/ReportPage.tsx"
)

Commit-Phase "scan history" @(
    "backend/database/migrations/2026_07_06_000002_create_scan_histories_table.php",
    "backend/app/Models/ScanHistory.php", "backend/app/Http/Controllers/Api/ScanHistoryController.php",
    "frontend/src/pages/HistoryPage.tsx"
)

Commit-Phase "design system applied" @(
    "frontend/src/index.css", "frontend/src/components/VerdictStamp.tsx", "frontend/src/components/MobileNav.tsx",
    "frontend/src/config/modules.ts", "frontend/src/pages/ModulesPage.tsx", "frontend/src/pages/ModulePlaceholderPage.tsx",
    "frontend/src/pages/UrlCheckPage.tsx", "backend/app/Http/Controllers/Api/UrlCheckController.php",
    "backend/app/Services/UrlSafetyService.php", "frontend/src/assets/design-reference"
)

Commit-Phase "dataset path resolution and prefilter accuracy fixes" @(
    "backend/app/Support/DatasetCsv.php", "backend/tests/analyze_smoke.php", "backend/tests/openai_direct.php"
)

Commit-Phase "deployment config for Railway" @(
    "backend/railway.json", "backend/nixpacks.toml", "backend/Procfile", "backend/.env.railway.example",
    "frontend/railway.json", "frontend/.railwayignore", "DEPLOYMENT.md"
)

# Any remaining changes
$remaining = git status --porcelain
if ($remaining) {
    git add -A
    git commit -m "chore: remaining project files and ai_source telemetry"
}

git log --oneline
