<?php

namespace App\Services;

use App\Support\BanglaFlagLabels;

class UrlSafetyService
{
    private const OFFICIAL_DOMAINS = [
        'bkash.com', 'nagad.com.bd', 'rocket.com.bd',
        'grameenphone.com', 'banglalink.net', 'robi.com.bd', 'gp.com.bd',
        'teletalk.com.bd', 'desco.org.bd', 'dpdc.org.bd', 'btrc.gov.bd',
    ];

    /** TLDs over-represented in phishing URL datasets. */
    private const SUSPICIOUS_TLDS = [
        '.tk', '.ml', '.ga', '.cf', '.gq', '.xyz', '.top', '.click', '.icu', '.buzz', '.work', '.live', '.shop',
    ];

    private const SHORTENERS = [
        'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'rb.gy', 'is.gd', 'ow.ly', 'cutt.ly', 'cuttly', 'rebrand.ly',
    ];

    private const TELECOM_KEYWORDS = ['gp-', 'grameenphone', 'robi', 'banglalink', 'blink', 'teletalk'];

    private const MFS_KEYWORDS = ['bkash', 'nagad', 'rocket', 'b-kash', 'mfs', 'merchant', 'payment', 'cashout', 'sendmoney'];

    public function check(string $url): array
    {
        $parsed = parse_url($url);
        $host = strtolower($parsed['host'] ?? '');
        $path = strtolower($parsed['path'] ?? '');
        $flags = [];
        $score = 0;

        foreach (self::OFFICIAL_DOMAINS as $domain) {
            if ($host === $domain || str_ends_with($host, '.'.$domain)) {
                return $this->buildResult('low', 10, ['official_domain_match'], $host);
            }
        }

        foreach (self::SHORTENERS as $short) {
            if (str_contains($host, $short) || str_contains($url, $short)) {
                $flags[] = 'shortened_url';
                $score += 28;
            }
        }

        foreach (self::SUSPICIOUS_TLDS as $tld) {
            if (str_ends_with($host, $tld)) {
                $flags[] = "suspicious_tld:{$tld}";
                $score += 22;
            }
        }

        foreach (self::TELECOM_KEYWORDS as $kw) {
            if (str_contains($host, $kw)) {
                $flags[] = 'telecom_impersonation';
                $score += 30;
                break;
            }
        }

        foreach (self::MFS_KEYWORDS as $kw) {
            if (str_contains($host.$path, $kw)) {
                $flags[] = 'mfs_payment_phishing';
                $score += 32;
                break;
            }
        }

        if (preg_match('/(bkash|nagad|rocket|bd-grant|mfs|verify|update|login|secure|account)/i', $host.$path)) {
            $flags[] = 'brand_impersonation_in_domain';
            $score += 30;
        }

        if (preg_match('/^[a-z0-9-]+-(bkash|nagad|rocket|gp|robi|login|secure|verify)/i', $host)) {
            $flags[] = 'subdomain_brand_trap';
            $score += 25;
        }

        if (preg_match('/\d+\.\d+\.\d+\.\d+/', $host)) {
            $flags[] = 'ip_address_url';
            $score += 35;
        }

        if (substr_count($host, '-') >= 3) {
            $flags[] = 'many_hyphens';
            $score += 15;
        }

        if (preg_match('/%[0-9a-f]{2}/i', $url)) {
            $flags[] = 'encoded_chars';
            $score += 12;
        }

        if (str_contains($host, 'example')) {
            $flags[] = 'fake_example_domain';
            $score += 40;
        }

        if (! str_starts_with($url, 'https://')) {
            $flags[] = 'no_https';
            $score += 15;
        }

        $flags = array_values(array_unique($flags));
        $riskLevel = $score >= 55 ? 'high' : ($score >= 28 ? 'medium' : 'low');

        return $this->buildResult($riskLevel, min(100, $score), $flags, $host);
    }

    /**
     * @param  array<int, string>  $flags
     * @return array<string, mixed>
     */
    private function buildResult(string $riskLevel, int $score, array $flags, string $host): array
    {
        $verdictMap = ['high' => 'উচ্চ ঝুঁকি', 'medium' => 'সতর্ক', 'low' => 'সতর্ক'];

        return [
            'risk_level' => $riskLevel,
            'verdict_bn' => $verdictMap[$riskLevel],
            'flags' => $flags,
            'flags_bn' => BanglaFlagLabels::enrich($flags),
            'risk_score' => $score,
            'explanation' => $this->buildExplanation($flags, $host),
            'disclaimer' => 'এটি ১০০% নিশ্চিত নয় — এটি একটি ঝুঁকি নির্দেশক টুল',
        ];
    }

    private function buildExplanation(array $flags, string $host): string
    {
        if ($flags === []) {
            return "ডোমেইন {$host} — কোনো স্পষ্ট লাল পতাকা পাওয়া যায়নি, তবুও অজানা লিংকে ব্যক্তিগত তথ্য দেবেন না।";
        }

        $labels = array_map(fn ($f) => BanglaFlagLabels::label($f), $flags);

        return 'লিংকে সন্দেহজন্য লক্ষণ: '.implode('; ', $labels).'. অফিসিয়াল অ্যাপ বা হেল্পলাইন দিয়ে যাচাই করুন।';
    }
}
