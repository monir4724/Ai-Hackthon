<?php

namespace App\Support;

class DatasetCsv
{
    /**
     * Resolve path to rokkhakoboch_synthetic_dataset_bn.csv (50 labeled rows).
     * Checks project root, data/, and backend/database/data/.
     */
    public static function path(): ?string
    {
        $candidates = [
            base_path('../rokkhakoboch_synthetic_dataset_bn.csv'),
            base_path('../data/rokkhakoboch_synthetic_dataset_bn.csv'),
            database_path('data/rokkhakoboch_synthetic_dataset_bn.csv'),
            base_path('../datasets/rokkhakoboch_synthetic_dataset_bn.csv'),
        ];

        foreach ($candidates as $path) {
            if (file_exists($path)) {
                return $path;
            }
        }

        return null;
    }

    /**
     * @return array<int, array<string, string>>
     */
    public static function rows(): array
    {
        $path = self::path();
        if (! $path || ($handle = fopen($path, 'r')) === false) {
            return [];
        }

        $header = fgetcsv($handle);
        $header = array_map(fn ($h) => trim(preg_replace('/^\xEF\xBB\xBF/', '', $h ?? '')), $header);
        $rows = [];

        while (($data = fgetcsv($handle)) !== false) {
            if (count($data) !== count($header)) {
                continue;
            }
            $rows[] = array_combine($header, $data);
        }

        fclose($handle);

        return $rows;
    }
}
