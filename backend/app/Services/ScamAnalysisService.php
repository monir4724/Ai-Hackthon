<?php

namespace App\Services;

use App\Models\ScanHistory;
use Illuminate\Support\Facades\Log;

class ScamAnalysisService
{
    public function __construct(
        private readonly RuleBasedPrefilterService $prefilter,
        private readonly GeminiScamAnalyzer $geminiAnalyzer
    ) {}

    public function analyze(string $text, string $module = 'sms'): array
    {
        $prefilterResult = $this->prefilter->scan($text);

        try {
            if (config('services.gemini.api_key')) {
                $aiResult = $this->geminiAnalyzer->analyze($text, $prefilterResult, $module);
            } else {
                $aiResult = $this->mockAnalyze($text, $prefilterResult);
            }
        } catch (\Throwable $e) {
            Log::error('Gemini analysis failed, using rule-based fallback', [
                'error' => $e->getMessage(),
            ]);
            $aiResult = $this->ruleBasedFallback($text, $prefilterResult);
            $aiResult['ai_source'] = 'gemini_fallback';
        }

        return array_merge($aiResult, [
            'prefilter' => $prefilterResult,
            'module' => $module,
            'disclaimer' => 'এটি ১০০% নিশ্চিত নয় — এটি একটি ঝুঁকি নির্দেশক টুল',
            'analyzed_at' => now()->toIso8601String(),
            'ai_source' => $aiResult['ai_source'] ?? ($aiResult['confidence'] === 'mock' ? 'rule_mock' : 'gemini'),
        ]);
    }

    public function saveHistory(?string $sessionId, string $text, array $result): void
    {
        if (! $sessionId) {
            return;
        }

        ScanHistory::create([
            'session_id' => $sessionId,
            'input_text' => mb_substr($text, 0, 500),
            'risk_level' => $result['risk_level'],
            'matched_pattern' => $result['matched_pattern'] ?? null,
            'explanation' => $result['explanation'] ?? null,
            'module' => $result['module'] ?? 'sms',
        ]);
    }

    private function mockAnalyze(string $text, array $prefilter): array
    {
        $score = $prefilter['risk_score'];
        $patterns = $prefilter['matched_patterns'] ?? [];

        // Escalate when structural scam patterns are detected
        if (! empty($patterns) && $score < 35) {
            $score = 35;
        }
        if (in_array('OTP/Account-lock phishing', $patterns, true) && $score < 70) {
            $score = max($score, 70);
        }

        if ($score >= 70) {
            return [
                'risk_level' => 'high',
                'verdict_bn' => 'উচ্চ ঝুঁকি',
                'explanation' => 'এই বার্তায় একাধিক সন্দেহজনক লক্ষণ পাওয়া গেছে — জরুরি চাপ, OTP/পিন চাওয়া, বা অফিসিয়াল নয় এমন লিংক। টাকা পাঠানো বা কোড শেয়ার করবেন না।',
                'matched_pattern' => $prefilter['matched_patterns'][0] ?? 'OTP/Account-lock phishing',
                'confidence' => 'mock',
                'ai_source' => 'rule_mock',
            ];
        }

        if ($score >= 35) {
            return [
                'risk_level' => 'medium',
                'verdict_bn' => 'সতর্ক',
                'explanation' => 'কিছু সন্দেহজনক উপাদান আছে। প্রেরক যাচাই করুন এবং অফিসিয়াল অ্যাপ/হেল্পলাইন দিয়ে নিশ্চিত হোন।',
                'matched_pattern' => $prefilter['matched_patterns'][0] ?? 'Suspicious pattern',
                'confidence' => 'mock',
                'ai_source' => 'rule_mock',
            ];
        }

        if ($score >= 10) {
            return [
                'risk_level' => 'low',
                'verdict_bn' => 'সতর্ক',
                'explanation' => 'সাধারণত নিরাপদ মনে হলেও কিছু শব্দ সতর্কতা দেখাতে পারে। বিস্তারিত যাচাই করুন।',
                'matched_pattern' => 'Genuine promotional (legit but often flagged)',
                'confidence' => 'mock',
                'ai_source' => 'rule_mock',
            ];
        }

        return [
            'risk_level' => 'safe',
            'verdict_bn' => 'নিরাপদ',
            'explanation' => 'এটি সাধারণ লেনদেন নিশ্চিতকরণ বা তথ্যমূলক বার্তার মতো দেখাচ্ছে। তবুও অজানা লিংকে ক্লিক করবেন না।',
            'matched_pattern' => 'Genuine transaction alert',
            'confidence' => 'mock',
            'ai_source' => 'rule_mock',
        ];
    }

    private function ruleBasedFallback(string $text, array $prefilter): array
    {
        return $this->mockAnalyze($text, $prefilter);
    }
}
