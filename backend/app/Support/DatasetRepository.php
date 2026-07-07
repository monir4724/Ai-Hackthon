<?php

namespace App\Support;

class DatasetRepository
{
    public static function datasetsRoot(): string
    {
        $candidates = [
            base_path('../datasets'),
            base_path('datasets'),
            base_path('database/data'),
        ];

        foreach ($candidates as $path) {
            if (is_dir($path)) {
                return realpath($path) ?: $path;
            }
        }

        return base_path('../datasets');
    }

    public static function path(string $filename): ?string
    {
        $full = self::datasetsRoot().DIRECTORY_SEPARATOR.$filename;

        return file_exists($full) ? $full : null;
    }

    /**
     * @return array<int, array{label: string, text: string}>
     */
    public static function bangalaBartaRows(?string $labelFilter = null): array
    {
        $path = self::path('BangalaBarta bangla_spam_sms smishing.csv');
        if (! $path) {
            return [];
        }

        return self::readLabelTextCsv($path, $labelFilter);
    }

    /**
     * @return array<int, string>
     */
    public static function englishScamTranscripts(int $limit = 20): array
    {
        $path = self::path('English_Scam.txt');
        if (! $path) {
            return [];
        }

        $content = file_get_contents($path) ?: '';
        preg_match_all('/^\d+\.\s*(.+)$/m', $content, $matches);

        return array_slice(array_map('trim', $matches[1] ?? []), 0, $limit);
    }

    /**
     * @return array<int, array<string, string>>
     */
    private static function readLabelTextCsv(string $path, ?string $labelFilter): array
    {
        if (($handle = fopen($path, 'r')) === false) {
            return [];
        }

        $header = fgetcsv($handle);
        $header = array_map(fn ($h) => trim(preg_replace('/^\xEF\xBB\xBF/', '', $h ?? '')), $header);
        $rows = [];

        while (($data = fgetcsv($handle)) !== false) {
            if (count($data) !== count($header)) {
                continue;
            }
            $row = array_combine($header, $data);
            if ($labelFilter !== null && strtolower($row['label'] ?? '') !== strtolower($labelFilter)) {
                continue;
            }
            $rows[] = [
                'label' => $row['label'] ?? '',
                'text' => $row['text'] ?? '',
            ];
        }

        fclose($handle);

        return $rows;
    }
}
