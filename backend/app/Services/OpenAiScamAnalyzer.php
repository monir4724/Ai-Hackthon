<?php

namespace App\Services;

use App\Support\DatasetCsv;
use Illuminate\Support\Facades\Http;

class OpenAiScamAnalyzer
{
    private array $fewShotExamples;

    public function __construct()
    {
        $this->fewShotExamples = $this->loadFewShotExamples();
    }

    public function analyze(string $text, array $prefilter, string $module = 'sms'): array
    {
        $apiKey = config('services.openai.api_key');
        if (! $apiKey) {
            throw new \RuntimeException('OpenAI API key not configured');
        }

        $systemPrompt = $this->buildSystemPrompt($module);
        $userPrompt = $this->buildUserPrompt($text, $prefilter);

        $response = Http::withToken($apiKey)
            ->timeout(45)
            ->post('https://api.openai.com/v1/chat/completions', [
                'model' => config('services.openai.model', 'gpt-4o'),
                'messages' => [
                    ['role' => 'system', 'content' => $systemPrompt],
                    ['role' => 'user', 'content' => $userPrompt],
                ],
                'response_format' => ['type' => 'json_object'],
                'temperature' => 0.2,
            ]);

        if (! $response->successful()) {
            throw new \RuntimeException('OpenAI API error: '.$response->body());
        }

        $content = $response->json('choices.0.message.content');
        $parsed = json_decode($content, true);

        if (! is_array($parsed)) {
            throw new \RuntimeException('Failed to parse OpenAI response');
        }

        return $this->normalizeResult($parsed);
    }

    private function buildSystemPrompt(string $module): string
    {
        $moduleContext = $module === 'call_transcript'
            ? 'ব্যবহারকারী একটি কল ট্রান্সক্রিপ্ট (লাইভ কল নয়) জমা দিয়েছেন।'
            : 'ব্যবহারকারী একটি SMS/মেসেজ জমা দিয়েছেন।';

        $examples = collect($this->fewShotExamples)
            ->map(fn ($ex) => "উদাহরণ:\nবার্তা: {$ex['text_bn']}\nঝুঁকি: {$ex['risk_level']}\nপ্যাটার্ন: {$ex['category']}\nলাল পতাকা: {$ex['red_flags_bn']}")
            ->implode("\n\n");

        return <<<PROMPT
আপনি রক্ষাকবচ — বাংলাদেশের AI-চালিত প্রতারণা সনাক্তকরণ সহকারী।

{$moduleContext}

আপনার কাজ: বার্তাটি বিশ্লেষণ করে JSON ফরম্যাটে উত্তর দিন। কখনো ১০০% নিশ্চয়তা দাবি করবেন না — এটি ঝুঁকি নির্দেশক।

Few-shot উদাহরণ:
{$examples}

উত্তর ফরম্যাট (শুধু JSON):
{
  "risk_level": "high|medium|low|safe",
  "verdict_bn": "উচ্চ ঝুঁকি|সতর্ক|নিরাপদ",
  "explanation": "সাধারণ বাংলায় কেন ঝুঁকিপূর্ণ বা নিরাপদ — ২-৪ বাক্য",
  "matched_pattern": "প্যাটার্নের ইংরেজি/বাংলা নাম",
  "confidence": "low|medium|high"
}
PROMPT;
    }

    private function buildUserPrompt(string $text, array $prefilter): string
    {
        $flags = implode(', ', $prefilter['flags'] ?? []);

        return "বার্তা:\n{$text}\n\nপ্রি-ফিল্টার স্কোর: {$prefilter['risk_score']}/100\nপ্রি-ফিল্টার ফ্ল্যাগ: {$flags}";
    }

    private function normalizeResult(array $parsed): array
    {
        $riskLevel = strtolower($parsed['risk_level'] ?? 'medium');
        $verdictMap = [
            'high' => 'উচ্চ ঝুঁকি',
            'medium' => 'সতর্ক',
            'low' => 'সতর্ক',
            'safe' => 'নিরাপদ',
        ];

        return [
            'risk_level' => $riskLevel,
            'verdict_bn' => $parsed['verdict_bn'] ?? ($verdictMap[$riskLevel] ?? 'সতর্ক'),
            'explanation' => $parsed['explanation'] ?? 'বিশ্লেষণ সম্পন্ন হয়েছে।',
            'matched_pattern' => $parsed['matched_pattern'] ?? 'Unknown',
            'confidence' => $parsed['confidence'] ?? 'medium',
            'ai_source' => 'openai',
        ];
    }

    private function loadFewShotExamples(): array
    {
        $rows = DatasetCsv::rows();

        if (empty($rows)) {
            return $this->defaultFewShotExamples();
        }

        $highRisk = array_values(array_filter($rows, fn ($r) => ($r['risk_level'] ?? '') === 'high'));
        $safe = array_values(array_filter($rows, fn ($r) => in_array($r['risk_level'] ?? '', ['none', 'low'], true)));
        $medium = array_values(array_filter($rows, fn ($r) => ($r['risk_level'] ?? '') === 'medium'));

        $selected = array_merge(
            array_slice($highRisk, 0, 4),
            array_slice($medium, 0, 2),
            array_slice($safe, 0, 4)
        );

        return array_map(fn ($r) => [
            'text_bn' => $r['text_bn'] ?? '',
            'risk_level' => $r['risk_level'] === 'none' ? 'safe' : $r['risk_level'],
            'category' => $r['category'] ?? '',
            'red_flags_bn' => $r['red_flags_bn'] ?? '',
        ], $selected);
    }

    private function defaultFewShotExamples(): array
    {
        return [
            [
                'text_bn' => 'জরুরি: আপনার bKash হিসাব বন্ধ হবে, OTP দিন।',
                'risk_level' => 'high',
                'category' => 'OTP/Account-lock phishing',
                'red_flags_bn' => 'জরুরি, OTP চাওয়া',
            ],
        ];
    }
}
