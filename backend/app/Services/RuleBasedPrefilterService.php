<?php

namespace App\Services;

class RuleBasedPrefilterService
{
    private const SUSPICIOUS_KEYWORDS = [
        'জরুরি', 'জরুরী', 'লক হয়ে', 'লক হবে', 'ব্লক', 'বন্ধ', 'ফ্রিজ', 'সাসপেন্ড',
        'OTP', 'ওটিপি', 'পিন', 'কোড', 'কোড দিন', 'কোড পাঠান',
        'লটারি', 'বিজয়ী', 'পুরস্কার', 'ক্যাশব্যাক', 'জিতেছেন', 'জিতেছে',
        'ভেরিফাই', 'ভেরিফিকেশন', 'KYC', 'কেওয়াইসি', 'NID', 'এনআইডি',
        'প্রসেসিং ফি', 'কুরিয়ার ফি', 'ট্যাক্স ফি', 'জয়েনিং ফি',
        'ভুলে টাকা', 'ভুলে সেন্ড', 'ফেরত দিন', 'ফেরত পাঠান',
        'কলব্যাক', 'কল করুন', 'শেয়ার করুন', 'রিপ্লাই করুন',
        'সিম বন্ধ', 'পুনঃনিবন্ধন', 'ডুপ্লিকেট',
        'অফিসিয়াল এজেন্ট', 'কাস্টমার কেয়ার', 'সিকিউরিটি টিম',
        'ডাউনলোড করুন', 'আপডেট', 'ইনস্টল',
        'অবিলম্বে', 'আজই', '২৪ ঘণ্টা', 'দেরি করলে',
    ];

    private const OFFICIAL_DOMAINS = [
        'bkash.com', 'nagad.com.bd', 'rocket.com.bd',
        'grameenphone.com', 'banglalink.net', 'robi.com.bd',
    ];

    private const SHORTENER_PATTERNS = [
        'bit.ly', 'tinyurl', 't.co', 'goo.gl', 'ow.ly', 'is.gd', 'rb.gy',
    ];

    public function scan(string $text): array
    {
        $flags = [];
        $patterns = [];
        $score = 0;

        foreach (self::SUSPICIOUS_KEYWORDS as $keyword) {
            if (mb_stripos($text, $keyword) !== false) {
                $flags[] = "keyword:{$keyword}";
                $score += 8;
            }
        }

        if (preg_match_all('/https?:\/\/[^\s]+/iu', $text, $urls)) {
            foreach ($urls[0] as $url) {
                $urlLower = strtolower($url);
                $isOfficial = false;
                foreach (self::OFFICIAL_DOMAINS as $domain) {
                    if (str_contains($urlLower, $domain)) {
                        $isOfficial = true;
                        break;
                    }
                }
                if (! $isOfficial) {
                    $flags[] = "suspicious_url:{$url}";
                    $score += 25;
                    $patterns[] = 'Fake app / phishing link';
                }
                foreach (self::SHORTENER_PATTERNS as $short) {
                    if (str_contains($urlLower, $short)) {
                        $flags[] = "shortened_url:{$short}";
                        $score += 15;
                    }
                }
            }
        }

        if (preg_match('/\.example\b/i', $text)) {
            $flags[] = 'fake_domain:.example';
            $score += 30;
            $patterns[] = 'Fake app / phishing link';
        }

        if (preg_match('/(bKash|Nagad|Rocket|নগদ|রকেট)/iu', $text)
            && preg_match('/(০১|01)[0-9Xx]{8,}/u', $text)) {
            $flags[] = 'brand_with_personal_number';
            $score += 25;
            $patterns[] = 'OTP/Account-lock phishing';
        }

        if (preg_match('/(পিন|PIN|OTP|ওটিপি|কোড|ডিজিট).{0,40}(বলুন|দিন|শেয়ার|পাঠান|SMS|জানিয়ে|জানান|রিপ্লাই)/iu', $text)) {
            $flags[] = 'credential_request';
            $score += 35;
            $patterns[] = 'OTP/Account-lock phishing';
        }

        if (preg_match('/(কল করে|কল করুন|কলব্যাক).{0,50}(কোড|পিন|OTP|ওটিপি)/iu', $text)) {
            $flags[] = 'vishing_callback';
            $score += 30;
            $patterns[] = 'OTP/Account-lock phishing';
        }

        if (preg_match('/(লটারি|বিজয়ী|জিতেছেন|পুরস্কার).{0,50}(ফি|টাকা|পাঠান|bKash)/iu', $text)) {
            $flags[] = 'lottery_advance_fee';
            $score += 25;
            $patterns[] = 'Lottery / prize scam';
        }

        if (preg_match('/(ভুলে|মিস্টেক|ভুল).{0,40}(টাকা|সেন্ড|চলে গেছে).{0,40}(ফেরত)/iu', $text)) {
            $flags[] = 'reversal_scam';
            $score += 18;
            $patterns[] = 'Send-money reversal scam';
        }

        if (preg_match('/(সিম|SIM).{0,30}(বন্ধ|নিবন্ধন|NID|এনআইডি)/iu', $text)) {
            $flags[] = 'sim_swap';
            $score += 22;
            $patterns[] = 'SIM-swap impersonation';
        }

        if (preg_match('/(১৬২৪৭|16247)/u', $text) && ! preg_match('/(পিন|OTP|কোড|লিংক)/iu', $text)) {
            $score = max(0, $score - 10);
            $flags[] = 'official_helpline_present';
        }

        return [
            'risk_score' => min(100, $score),
            'flags' => array_values(array_unique($flags)),
            'matched_patterns' => array_values(array_unique($patterns)),
            'flag_count' => count(array_unique($flags)),
        ];
    }
}
