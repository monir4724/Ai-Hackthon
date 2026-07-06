<?php

require __DIR__.'/../vendor/autoload.php';
$app = require __DIR__.'/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$prefilter = app(App\Services\RuleBasedPrefilterService::class)->scan(
    'জরুরি: আপনার bKash হিসাব বন্ধ হবে, OTP দিন।'
);

try {
    $result = app(App\Services\GeminiScamAnalyzer::class)->analyze(
        'জরুরি: আপনার bKash হিসাব বন্ধ হবে, OTP দিন।',
        $prefilter
    );
    echo "SUCCESS\n";
    echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)."\n";
} catch (Throwable $e) {
    echo "ERROR: ".$e->getMessage()."\n";
}
