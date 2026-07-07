<?php

namespace App\Support;

class BanglaFlagLabels
{
    public static function label(string $flag): string
    {
        return match ($flag) {
            'shortened_url' => 'সংক্ষিপ্ত URL (bit.ly/cutt.ly ইত্যাদি)',
            'brand_impersonation_in_domain' => 'ডোমেইনে bKash/Nagad/Rocket অনুকরণ',
            'official_domain_match' => 'পরিচিত অফিসিয়াল ডোমেইন',
            'fake_example_domain' => 'উদাহরণ/ভুয়া ডোমেইন',
            'no_https' => 'HTTPS নেই — অসুরক্ষিত সংযোগ',
            'ip_address_url' => 'IP ঠিকানা ভিত্তিক URL',
            'many_hyphens' => 'ডোমেইনে অতিরিক্ত হাইফেন',
            'encoded_chars' => 'এনকোডেড/সন্দেহজন্য অক্ষর',
            'telecom_impersonation' => 'টেলিকম (GP/Robi/Blink) অনুকরণ',
            'mfs_payment_phishing' => 'MFS পেমেন্ট/ভেরিফাই ফিশিং URL',
            'subdomain_brand_trap' => 'সাবডোমেইনে ব্র্যান্ড নাম',
            'qr_transfer_pattern' => 'QR-এ TRANSFER/CASH_OUT প্যাটার্ন',
            'qr_phone_number' => 'QR-এ সন্দেহজনক মোবাইল নম্বর',
            'qr_mfs_keyword' => 'QR-এ bKash/Nagad/Rocket কীওয়ার্ড',
            default => self::fromPrefix($flag),
        };
    }

    public static function explanation(string $flag): string
    {
        return match ($flag) {
            'shortened_url' => 'সংক্ষিপ্ত লিংক লুকিয়ে ভুয়া সাইটে নিয়ে যেতে পারে।',
            'brand_impersonation_in_domain' => 'অফিসিয়াল সেবার মতো দেখানো ভুয়া ডোমেইন।',
            'no_https' => 'ডেটা চুরির ঝুঁকি বেশি — অফিসিয়াল অ্যাপ ব্যবহার করুন।',
            'telecom_impersonation' => 'GP/Robi/Banglalink-এর ভুয়া পেজ হতে পারে।',
            'mfs_payment_phishing' => 'bKash/Nagad পেমেন্ট চুরির ফিশিং হতে পারে।',
            'qr_transfer_pattern' => 'পেমেন্ট ফ্রড ডেটাসেটে TRANSFER/CASH_OUT উচ্চ ঝুঁকি।',
            default => 'সতর্ক থাকুন এবং অফিসিয়াল চ্যানেলে যাচাই করুন।',
        };
    }

    /**
     * @param  array<int, string>  $flags
     * @return array<int, array{key: string, label_bn: string, explanation_bn: string}>
     */
    public static function enrich(array $flags): array
    {
        return array_map(fn ($flag) => [
            'key' => $flag,
            'label_bn' => self::label($flag),
            'explanation_bn' => self::explanation($flag),
        ], $flags);
    }

    private static function fromPrefix(string $flag): string
    {
        if (str_starts_with($flag, 'suspicious_tld:')) {
            return 'সন্দেহজন্য TLD ('.substr($flag, 15).')';
        }
        if (str_starts_with($flag, 'keyword:')) {
            return 'সন্দেহজন্য শব্দ: '.substr($flag, 8);
        }

        return str_replace('_', ' ', $flag);
    }
}
