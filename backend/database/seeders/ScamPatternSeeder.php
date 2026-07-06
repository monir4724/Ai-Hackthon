<?php

namespace Database\Seeders;

use App\Models\ScamPattern;
use App\Support\DatasetCsv;
use Illuminate\Database\Seeder;

class ScamPatternSeeder extends Seeder
{
    public function run(): void
    {
        $rows = DatasetCsv::rows();

        if (empty($rows)) {
            $this->command?->warn('CSV not found, skipping scam pattern seed.');

            return;
        }

        foreach ($rows as $row) {
            ScamPattern::updateOrCreate(
                ['external_id' => $row['id']],
                [
                    'category' => $row['category'],
                    'label' => $row['label'],
                    'risk_level' => $row['risk_level'] === 'none' ? 'safe' : $row['risk_level'],
                    'text_bn' => $row['text_bn'],
                    'red_flags_bn' => $row['red_flags_bn'],
                    'pattern_basis' => $row['pattern_basis'],
                    'is_synthetic' => strtoupper($row['is_synthetic'] ?? 'TRUE') === 'TRUE',
                    'is_community_report' => false,
                ]
            );
        }

        $this->command?->info('Seeded '.count($rows).' scam patterns from CSV.');
    }
}
