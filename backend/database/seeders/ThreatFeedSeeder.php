<?php

namespace Database\Seeders;

use App\Models\ScamPattern;
use App\Support\DatasetRepository;
use App\Support\ScamCategoryDetector;
use Illuminate\Database\Seeder;

class ThreatFeedSeeder extends Seeder
{
    private const DIVISIONS = [
        'ঢাকা', 'চট্টগ্রাম', 'সিলেট', 'রাজশাহী', 'খুলনা', 'বরিশাল', 'রংপুর', 'ময়মনসিংহ',
    ];

    public function run(): void
    {
        $rows = DatasetRepository::bangalaBartaRows('smish');

        if ($rows === []) {
            $this->command?->warn('BangalaBarta CSV not found for threat feed.');

            return;
        }

        shuffle($rows);
        $selected = array_slice($rows, 0, min(30, count($rows)));
        $count = 0;

        foreach ($selected as $i => $row) {
            $text = trim($row['text']);
            if (mb_strlen($text) < 10) {
                continue;
            }

            $snippet = mb_strlen($text) > 100 ? mb_substr($text, 0, 100).'…' : $text;
            $category = ScamCategoryDetector::categoryForPattern($text);
            $division = self::DIVISIONS[$i % count(self::DIVISIONS)];
            $externalId = 'threat-'.md5($snippet.$i);

            ScamPattern::updateOrCreate(
                ['external_id' => $externalId],
                [
                    'category' => $category,
                    'label' => 'threat_intel',
                    'risk_level' => 'high',
                    'text_bn' => $snippet,
                    'location_label' => $division,
                    'red_flags_bn' => 'BangalaBarta থ্রেট ইন্টেল',
                    'pattern_basis' => 'National threat feed entry',
                    'is_synthetic' => false,
                    'is_community_report' => true,
                ]
            );
            $count++;
        }

        $this->command?->info("Seeded {$count} threat feed entries with location labels.");
    }
}
