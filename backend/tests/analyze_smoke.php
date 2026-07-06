<?php

/**
 * Local smoke test for /api/analyze with Gemini.
 * Usage: php tests/analyze_smoke.php
 */

$tests = [
    ['id' => 'scam_001', 'expect' => 'high', 'text' => 'জরুরি সতর্কতা: আপনার bKash হিসাবে অস্বাভাবিক লগইন সনাক্ত হয়েছে। আজই ০১XXXXXXXXX নম্বরে কল করে আপনার ৪ ডিজিট কোড জানিয়ে হিসাব সচল রাখুন, অন্যথায় ২৪ ঘণ্টার মধ্যে স্থায়ীভাবে বন্ধ হবে।'],
    ['id' => 'scam_009', 'expect' => 'high', 'text' => 'অভিনন্দন! আপনার নাম্বারটি Nagad বর্ষপূর্তি লাকি ড্র-তে ৫০,০০০ টাকা জিতেছে। পুরস্কার নিতে প্রসেসিং ফি পাঠান এই নাম্বারে।'],
    ['id' => 'scam_015', 'expect' => 'medium', 'text' => 'ভাই দুঃখিত, ভুল করে আপনার নাম্বারে ৫,০০০ টাকা চলে গেছে। প্লিজ এই নাম্বারে ফেরত দিয়ে দিন, আমার খুব প্রয়োজন।'],
    ['id' => 'scam_021', 'expect' => 'high', 'text' => 'নতুন bKash অ্যাপ আপডেট এসেছে, এখনই ডাউনলোড করুন নাহলে পুরনো অ্যাপ কাজ করবে না: bkash-update.example'],
    ['id' => 'scam_027', 'expect' => 'high', 'text' => 'আপনার সিম পুনঃনিবন্ধনের জন্য আজকের মধ্যে NID নম্বর এবং জন্মতারিখ পাঠান, অন্যথায় সংযোগ বন্ধ হয়ে যাবে।'],
    ['id' => 'legit_035', 'expect' => 'safe', 'text' => 'আপনি ৫০০ টাকা ক্যাশ ইন করেছেন। এজেন্ট: শাহআলম স্টোর। ব্যালেন্স: ২,৩৫০ টাকা। bKash সাহায্যের জন্য ১৬২৪৭।'],
    ['id' => 'legit_043', 'expect' => 'low', 'text' => 'bKash-এ এই ঈদে পাঠাও রাইডে ২০% ক্যাশব্যাক, সর্বোচ্চ ৫০ টাকা। কোড: EIDRIDE। শর্ত প্রযোজ্য।'],
    ['id' => 'legit_049', 'expect' => 'safe', 'text' => 'আপনার bKash পিন ৩ বার ভুল দেওয়ায় সাময়িকভাবে লক হয়েছে, ৩০ মিনিট পর আবার চেষ্টা করুন বা ১৬২৪৭ কল করুন।'],
];

$base = 'http://127.0.0.1:8000/api/analyze';
$required = ['risk_level', 'verdict_bn', 'explanation', 'matched_pattern', 'disclaimer', 'prefilter', 'analyzed_at'];
$results = [];

foreach ($tests as $test) {
    $ch = curl_init($base);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => ['Content-Type: application/json', 'Accept: application/json'],
        CURLOPT_POSTFIELDS => json_encode(['text' => $test['text'], 'module' => 'sms'], JSON_UNESCAPED_UNICODE),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 90,
    ]);
    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    $json = json_decode($body, true);
    $missing = array_values(array_filter($required, fn ($k) => ! array_key_exists($k, $json ?? [])));
    $aiSource = $json['ai_source'] ?? 'unknown';
    $isMock = ($json['confidence'] ?? '') === 'mock' || $aiSource === 'rule_mock' || $aiSource === 'gemini_fallback';

    $results[] = [
        'id' => $test['id'],
        'http' => $code,
        'risk' => $json['risk_level'] ?? 'ERROR',
        'expected' => $test['expect'],
        'verdict_bn' => $json['verdict_bn'] ?? '',
        'pattern' => $json['matched_pattern'] ?? '',
        'confidence' => $json['confidence'] ?? '',
        'ai_source' => $aiSource,
        'is_mock' => $isMock ? 'YES' : 'no',
        'format_ok' => empty($missing),
        'missing_keys' => $missing,
        'explanation_snip' => mb_substr($json['explanation'] ?? '', 0, 80),
    ];
}

echo json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE).PHP_EOL;
