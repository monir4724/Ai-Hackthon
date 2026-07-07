<?php

namespace App\Support;

class ScamCategoryDetector
{
    private const RULES = [
        'OTP/PIN ফিশিং' => [
            'পিন', 'OTP', 'ওটিপি', 'গোপন কোড', 'পাসওয়ার্ড', 'PIN', 'password', 'কোড দিন', 'কোড পাঠান', 'পিন SMS',
        ],
        'অ্যাকাউন্ট লক স্ক্যাম' => [
            'অ্যাকাউন্ট বন্ধ', 'নিষ্ক্রিয়', 'ফ্রিজ', 'সাসপেন্ড', 'ব্লক', 'লক হয়', 'লক হবে', 'অ্যাকাউন্টে সমস্যা',
        ],
        'bKash/Nagad/MFS স্ক্যাম' => [
            'বিকাশ', 'bKash', 'B-Kash', 'নগদ', 'Nagad', 'রকেট', 'Rocket', 'MFS', 'Upay', 'উপায়', 'Tap',
        ],
        'লটারি/পুরস্কার স্ক্যাম' => [
            'পুরস্কার', 'জিতেছেন', 'জিতুন', 'লটারি', 'অভিনন্দন', 'সোনা জিত', 'বিজয়ী', 'prize', 'winner', 'jackpot',
        ],
        'ভুয়া চাকরি/ইনকাম' => [
            'বাড়িতে বসে', 'ইনকাম', 'ফর্ম ফিলাপ', 'ফর্ম', 'বেতন', 'চাকরি', 'part time', 'part-time', 'নিয়োগ',
        ],
        'ভুয়া বিনিয়োগ' => [
            'বিনিয়োগ', 'ক্রিপ্টো', 'crypto', 'ইনভেস্ট', 'investment', 'সঞ্চয় দ্বিগুণ',
        ],
        'জরুরি/challenge' => [
            'এখনই', 'অবিলম্বে', 'আজই', '২৪ ঘণ্টা', '24 ঘণ্টা', 'দেরি করলে', 'জরুরি', 'জরুরী', 'urgent',
        ],
        'কল/ভিশিং স্ক্যাম' => [
            'কল করুন', 'কল করে', 'whatsapp', 'হোয়াটসঅ্যাপ', 'inbox', 'ফোন',
        ],
        'ফিশিং লিংক' => [
            'http://', 'https://', 'bit.ly', 'cutt.ly', 'tinyurl', 'ক্লিক করুন', 'লিংক',
        ],
    ];

    public static function detect(string $text): string
    {
        $scores = [];
        foreach (self::RULES as $category => $keywords) {
            $score = 0;
            foreach ($keywords as $keyword) {
                if (mb_stripos($text, $keyword) !== false) {
                    $score++;
                }
            }
            if ($score > 0) {
                $scores[$category] = $score;
            }
        }

        if ($scores === []) {
            return 'সাধারণ স্মিশিং';
        }

        arsort($scores);

        return array_key_first($scores);
    }

    public static function categoryForPattern(string $text): string
    {
        return self::detect($text);
    }
}
