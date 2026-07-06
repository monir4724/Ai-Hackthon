<?php

namespace App\Services;

class UrlSafetyService
{
    private const OFFICIAL_DOMAINS = [
        'bkash.com', 'nagad.com.bd', 'rocket.com.bd',
        'grameenphone.com', 'banglalink.net', 'robi.com.bd',
        'teletalk.com.bd', 'desco.org.bd', 'dpdc.org.bd',
    ];

    private const SUSPICIOUS_TLDS = ['.tk', '.ml', '.ga', '.cf', '.gq', '.xyz', '.top', '.click'];

    private const SHORTENERS = ['bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'rb.gy', 'is.gd', 'ow.ly'];

    public function check(string $url): array
    {
        $parsed = parse_url($url);
        $host = strtolower($parsed['host'] ?? '');
        $flags = [];
        $score = 0;

        foreach (self::OFFICIAL_DOMAINS as $domain) {
            if ($host === $domain || str_ends_with($host, '.'.$domain)) {
                return [
                    'risk_level' => 'low',
                    'verdict_bn' => 'সতর্ক',
                    'flags' => ['official_domain_match'],
                    'explanation' => 'ডোমেইনটি পরিচিত অফিসিয়াল সেবার সাথে মিলে যায়। তবুও URL সম্পূর্ণ যাচাই করুন — ফিশিং সাইট অনেক সময় অনুরূপ নাম ব্যবহার করে।',
                    'disclaimer' => 'এটি ১০০% নিশ্চিত নয় — এটি একটি ঝুঁকি নির্দেশক টুল',
                ];
            }
        }

        foreach (self::SHORTENERS as $short) {
            if (str_contains($host, $short)) {
                $flags[] = 'shortened_url';
                $score += 30;
            }
        }

        foreach (self::SUSPICIOUS_TLDS as $tld) {
            if (str_ends_with($host, $tld)) {
                $flags[] = "suspicious_tld:{$tld}";
                $score += 25;
            }
        }

        if (preg_match('/(bkash|nagad|rocket|bd-grant|mfs|verify|update|login)/i', $host)) {
            $flags[] = 'brand_impersonation_in_domain';
            $score += 35;
        }

        if (str_contains($host, 'example')) {
            $flags[] = 'fake_example_domain';
            $score += 40;
        }

        if (! str_starts_with($url, 'https://')) {
            $flags[] = 'no_https';
            $score += 15;
        }

        $riskLevel = $score >= 50 ? 'high' : ($score >= 25 ? 'medium' : 'low');
        $verdictMap = ['high' => 'উচ্চ ঝুঁকি', 'medium' => 'সতর্ক', 'low' => 'সতর্ক'];

        return [
            'risk_level' => $riskLevel,
            'verdict_bn' => $verdictMap[$riskLevel],
            'flags' => $flags,
            'risk_score' => min(100, $score),
            'explanation' => $this->buildExplanation($flags, $host),
            'disclaimer' => 'এটি ১০০% নিশ্চিত নয় — এটি একটি ঝুঁকি নির্দেশক টুল',
        ];
    }

    private function buildExplanation(array $flags, string $host): string
    {
        if (empty($flags)) {
            return "ডোমেইন {$host} — কোনো স্পষ্ট লাল পতাকা পাওয়া যায়নি, তবে অজানা লিংকে ব্যক্তিগত তথ্য দেবেন না।";
        }

        return 'লিংকে সন্দেহজন্য লক্ষণ: '.implode(', ', $flags).'. অফিসিয়াল অ্যাপ বা হেল্পলাইন দিয়ে যাচাই করুন।';
    }
}
