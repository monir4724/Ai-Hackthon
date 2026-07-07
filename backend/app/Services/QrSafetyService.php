<?php

namespace App\Services;

use App\Support\BanglaFlagLabels;

class QrSafetyService
{
    /** Fraud-heavy types from payment transaction dataset (isFraud=1). */
    private const FRAUD_TX_TYPES = ['TRANSFER', 'CASH_OUT'];

    public function __construct(
        private readonly UrlSafetyService $urlSafety,
        private readonly ScamAnalysisService $analysisService
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function check(string $payload, ?string $sessionId = null): array
    {
        $payload = trim($payload);
        $flags = [];
        $score = 0;
        $urlResult = null;
        $textResult = null;

        if ($this->looksLikeUrl($payload)) {
            $urlResult = $this->urlSafety->check($payload);
            $flags = array_merge($flags, $urlResult['flags'] ?? []);
            $score = max($score, (int) ($urlResult['risk_score'] ?? 0));
        }

        if (preg_match('/\b(TRANSFER|CASH_OUT|CASH_IN|PAYMENT)\b/i', $payload)) {
            if (preg_match('/\b(TRANSFER|CASH_OUT)\b/i', $payload)) {
                $flags[] = 'qr_transfer_pattern';
                $score += 40;
            }
        }

        if (preg_match('/(০১|01)[0-9]{8,9}/u', $payload)) {
            $flags[] = 'qr_phone_number';
            $score += 25;
        }

        if (preg_match('/(bkash|nagad|rocket|বিকাশ|নগদ|রকেট|merchant|payment)/iu', $payload)) {
            $flags[] = 'qr_mfs_keyword';
            $score += 30;
        }

        if (! $this->looksLikeUrl($payload) || mb_strlen($payload) > 80) {
            $textResult = $this->analysisService->analyze($payload, 'sms');
            $flags = array_merge($flags, $textResult['prefilter']['flags'] ?? []);
            $score = max($score, (int) ($textResult['prefilter']['risk_score'] ?? 0));
        }

        $flags = array_values(array_unique($flags));
        $riskLevel = $score >= 55 ? 'high' : ($score >= 28 ? 'medium' : 'low');
        $verdictMap = ['high' => 'উচ্চ ঝুঁকি', 'medium' => 'সতর্ক', 'low' => 'সতর্ক'];

        $explanation = $this->buildExplanation($urlResult, $textResult, $flags);

        $result = [
            'risk_level' => $riskLevel,
            'verdict_bn' => $verdictMap[$riskLevel],
            'flags' => $flags,
            'flags_bn' => BanglaFlagLabels::enrich($flags),
            'risk_score' => min(100, $score),
            'explanation' => $explanation,
            'disclaimer' => 'এটি ১০০% নিশ্চিত নয় — এটি একটি ঝুঁকি নির্দেশক টুল',
            'module' => 'qr',
            'url_check' => $urlResult,
            'text_analysis' => $textResult,
            'matched_pattern' => 'QR / Payment fraud check',
            'scam_category' => 'আর্থিক/QR প্রতারণা',
        ];

        if ($sessionId) {
            try {
                $this->analysisService->saveHistory($sessionId, mb_substr($payload, 0, 500), $result);
            } catch (\Throwable) {
                // history save is best-effort
            }
        }

        return $result;
    }

    private function looksLikeUrl(string $value): bool
    {
        return (bool) preg_match('#^https?://#i', $value);
    }

    private function buildExplanation(?array $urlResult, ?array $textResult, array $flags): string
    {
        $parts = [];

        if ($urlResult) {
            $parts[] = 'URL যাচাই: '.($urlResult['explanation'] ?? '');
        }
        if ($textResult) {
            $parts[] = 'টেক্সট বিশ্লেষণ: '.($textResult['explanation'] ?? '');
        }
        if ($parts === []) {
            $labels = array_map(fn ($f) => BanglaFlagLabels::label($f), $flags);

            return 'QR কন্টেন্টে সন্দেহজন্য লক্ষণ: '.implode('; ', $labels);
        }

        return implode(' ', $parts);
    }
}

