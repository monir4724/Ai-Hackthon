<?php

namespace App\Services;

use App\Support\ScamCategoryDetector;

class RuleBasedPrefilterService
{
    /** @var array<string, array<int, string>> */
    private const KEYWORD_CATEGORIES = [
        'otp_pin' => [
            'পিন', 'OTP', 'ওটিপি', 'গোপন কোড', 'পাসওয়ার্ড', 'PIN', 'password', 'কোড দিন', 'কোড পাঠান',
            'পিন SMS', 'পিন sms', 'রিসেট', 'verification code', 'verify code',
        ],
        'account_lock' => [
            'অ্যাকাউন্ট বন্ধ', 'নিষ্ক্রিয়', 'ফ্রিজ', 'সাসপেন্ড', 'ব্লক', 'লক হয়', 'লক হবে', 'block', 'suspend',
            'অ্যাকাউন্টে সমস্যা', 'হিসাব বন্ধ', 'নিষ্ক্রিয় করা',
        ],
        'mfs' => [
            'বিকাশ', 'bKash', 'B-Kash', 'নগদ', 'Nagad', 'রকেট', 'Rocket', 'MFS', 'Upay', 'উপায়', 'merchant pay',
        ],
        'lottery' => [
            'পুরস্কার', 'জিতেছেন', 'জিতুন', 'লটারি', 'অভিনন্দন', 'সোনা জিত', 'বিজয়ী', 'prize', 'winner',
            'jackpot', 'free iphone', 'ফ্রি',
        ],
        'job' => [
            'বাড়িতে বসে', 'ইনকাম', 'ফর্ম ফিলাপ', 'ফর্ম', 'বেতন', 'চাকরি', 'part time', 'part-time', 'নিয়োগ',
            'online selection', 'whatsapp',
        ],
        'investment' => [
            'বিনিয়োগ', 'ক্রিপ্টো', 'crypto', 'ইনভেস্ট', 'investment', 'সঞ্চয় দ্বিগুণ', 'লাভ',
        ],
        'urgency' => [
            'এখনই', 'অবিলম্বে', 'আজই', '২৪ ঘণ্টা', '24 ঘণ্টা', 'দেরি করলে', 'জরুরি', 'জরুরী', 'urgent', 'immediately',
        ],
    ];

    private const OFFICIAL_DOMAINS = [
        'bkash.com', 'nagad.com.bd', 'rocket.com.bd',
        'grameenphone.com', 'banglalink.net', 'robi.com.bd',
    ];

    private const SHORTENER_PATTERNS = [
        'bit.ly', 'tinyurl', 't.co', 'goo.gl', 'ow.ly', 'is.gd', 'rb.gy', 'cutt.ly', 'cuttly',
    ];

    public function scan(string $text): array
    {
        $flags = [];
        $patterns = [];
        $score = 0;

        foreach (self::KEYWORD_CATEGORIES as $category => $keywords) {
            foreach ($keywords as $keyword) {
                if (mb_stripos($text, $keyword) !== false) {
                    $flags[] = "keyword:{$keyword}";
                    $score += match ($category) {
                        'otp_pin' => 12,
                        'account_lock' => 10,
                        'mfs' => 8,
                        'lottery' => 9,
                        'job' => 8,
                        'investment' => 10,
                        'urgency' => 6,
                        default => 5,
                    };
                    $patterns[] = ScamCategoryDetector::detect($text);
                }
            }
        }

        if (preg_match_all('/https?:\/\/[^\s\]]+/iu', $text, $urls)) {
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

        if (preg_match('/(bKash|Nagad|Rocket|নগদ|রকেট|বিকাশ)/iu', $text)
            && preg_match('/(০১|01)[0-9Xx]{8,}/u', $text)) {
            $flags[] = 'brand_with_personal_number';
            $score += 25;
            $patterns[] = 'OTP/Account-lock phishing';
        }

        if (preg_match('/(পিন|PIN|OTP|ওটিপি|কোড|ডিজিট).{0,40}(বলুন|দিন|শেয়ার|পাঠান|SMS|জানিয়ে|জানান|রিপ্লাই)/iu', $text)) {
            $flags[] = 'credential_request';
            $score += 35;
            $patterns[] = 'OTP/PIN ফিশিং';
        }

        if (preg_match('/(কল করে|কল করুন|কলব্যাক).{0,50}(কোড|পিন|OTP|ওটিপি)/iu', $text)) {
            $flags[] = 'vishing_callback';
            $score += 30;
            $patterns[] = 'কল/ভিশিং স্ক্যাম';
        }

        if (preg_match('/(লটারি|বিজয়ী|জিতেছেন|পুরস্কার).{0,50}(ফি|টাকা|পাঠান|bKash|বিকাশ)/iu', $text)) {
            $flags[] = 'lottery_advance_fee';
            $score += 25;
            $patterns[] = 'লটারি/পুরস্কার স্ক্যাম';
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

        $scamCategory = ScamCategoryDetector::detect($text);

        return [
            'risk_score' => min(100, $score),
            'flags' => array_values(array_unique($flags)),
            'matched_patterns' => array_values(array_unique($patterns)),
            'flag_count' => count(array_unique($flags)),
            'scam_category' => $scamCategory,
        ];
    }
}
