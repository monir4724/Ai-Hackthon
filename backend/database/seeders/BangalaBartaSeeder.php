<?php

namespace Database\Seeders;

use App\Models\ScamPattern;
use App\Support\DatasetRepository;
use App\Support\ScamCategoryDetector;
use Illuminate\Database\Seeder;

class BangalaBartaSeeder extends Seeder
{
    public function run(): void
    {
        $rows = DatasetRepository::bangalaBartaRows('smish');

        if ($rows === []) {
            $this->command?->warn('BangalaBarta CSV not found, skipping.');

            return;
        }

        shuffle($rows);
        $selected = array_slice($rows, 0, min(50, count($rows)));
        $count = 0;

        foreach ($selected as $i => $row) {
            $text = trim($row['text']);
            if (mb_strlen($text) < 10) {
                continue;
            }

            $category = ScamCategoryDetector::categoryForPattern($text);
            $externalId = 'bb-'.md5($text);

            ScamPattern::updateOrCreate(
                ['external_id' => $externalId],
                [
                    'category' => $category,
                    'label' => 'smish',
                    'risk_level' => 'high',
                    'text_bn' => mb_substr($text, 0, 2000),
                    'red_flags_bn' => 'BangalaBarta স্মিশিং ডেটাসেট',
                    'pattern_basis' => 'BangalaBarta real smishing SMS',
                    'is_synthetic' => false,
                    'is_community_report' => false,
                ]
            );
            $count++;
        }

        $this->command?->info("Seeded {$count} BangalaBarta smishing patterns.");
    }
}
