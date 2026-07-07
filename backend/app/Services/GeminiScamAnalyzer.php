<?php

namespace App\Services;

use App\Support\DatasetCsv;
use App\Support\DatasetRepository;
use Illuminate\Support\Facades\Http;

class GeminiScamAnalyzer
{
    private array $fewShotExamples;

    public function __construct()
    {
        $this->fewShotExamples = $this->loadFewShotExamples();
    }

    public function analyze(string $text, array $prefilter, string $module = 'sms'): array
    {
        $apiKey = config('services.gemini.api_key');
        if (! $apiKey) {
            throw new \RuntimeException('Gemini API key not configured');
        }

        $model = config('services.gemini.model', 'gemini-2.5-flash');
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent";

        $systemPrompt = $this->buildSystemPrompt($module);
        $userPrompt = $this->buildUserPrompt($text, $prefilter, $module);

        $response = Http::timeout(45)
            ->post($url.'?key='.urlencode($apiKey), [
                'systemInstruction' => [
                    'parts' => [['text' => $systemPrompt]],
                ],
                'contents' => [
                    [
                        'role' => 'user',
                        'parts' => [['text' => $userPrompt]],
                    ],
                ],
                'generationConfig' => [
                    'temperature' => 0.2,
                    'responseMimeType' => 'application/json',
                ],
            ]);

        if (! $response->successful()) {
            throw new \RuntimeException('Gemini API error: '.$response->body());
        }

        $content = $response->json('candidates.0.content.parts.0.text');
        if (! is_string($content) || $content === '') {
            throw new \RuntimeException('Gemini returned empty response');
        }

        $parsed = json_decode($content, true);
        if (! is_array($parsed)) {
            throw new \RuntimeException('Failed to parse Gemini JSON response');
        }

        return $this->normalizeResult($parsed);
    }

    private function buildSystemPrompt(string $module): string
    {
        if ($module === 'call_transcript') {
            return $this->buildTranscriptSystemPrompt();
        }

        $examples = collect($this->fewShotExamples)
            ->map(fn ($ex) => "উদাহরণ:\nবার্তা: {$ex['text_bn']}\nঝুঁকি: {$ex['risk_level']}\nপ্যাটার্ন: {$ex['category']}\nলাল পতাকা: {$ex['red_flags_bn']}")
            ->implode("\n\n");

        return <<<PROMPT
আপনি রক্ষাকবচ — বাংলাদেশের AI-চালিত প্রতারণা সনাক্তকরণ সহকারী।

Bangladesh context — bKash, Nagad, Rocket are the main MFS platforms. Scammers often impersonate banks, BTRC, telecom, and MFS agents.

ব্যবহারকারী একটি SMS/মেসেজ জমা দিয়েছেন।

আপনার কাজ: বার্তাটি বিশ্লেষণ করে JSON ফরম্যাটে উত্তর দিন। কখনো ১০০% নিশ্চয়তা দাবি করবেন না — এটি ঝুঁকি নির্দেশক।

Few-shot উদাহরণ (BangalaBarta স্মিশিং ডেটাসেট):
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

    private function buildTranscriptSystemPrompt(): string
    {
        $englishPatterns = implode("\n- ", array_slice(DatasetRepository::englishScamTranscripts(8), 0, 8));

        return <<<PROMPT
আপনি রক্ষাকবচ — বাংলাদেশের AI-চালিত প্রতারণা সনাক্তকরণ সহকারী।

Bangladesh context — bKash, Nagad, Rocket are the main MFS platforms.

ব্যবহারকারী একটি কল ট্রান্সক্রিপ্ট (লাইভ কল নয়) জমা দিয়েছেন — ইংরেজি বা বাংলা হতে পারে।

সাধারণ স্ক্যাম কল প্যাটার্ন (English dataset):
- {$englishPatterns}

বাংলাদেশ-নির্দিষ্ট ভিশিং:
- BTRC/টেলিকম কর্তৃপক্ষের ভান
- bKash/Nagad/Rocket এজেন্ট/অফিসারের ভান
- ভুয়া ব্যাংক অফিসার OTP/PIN চাওয়া
- সরকারি grant/সubsidy scam
- জরুরি আত্মীয়/accident টাকা চাওয়া

উত্তর ফরম্যাট (শুধু JSON):
{
  "risk_level": "high|medium|low|safe",
  "verdict_bn": "উচ্চ ঝুঁকি|সতর্ক|নিরাপদ",
  "explanation": "বাংলায় কেন ঝুঁকিপূর্ণ — ২-৪ বাক্য",
  "matched_pattern": "Government grant scam|Fake bank officer|BTRC impersonation|MFS agent fraud|etc",
  "confidence": "low|medium|high"
}
PROMPT;
    }

    private function buildUserPrompt(string $text, array $prefilter, string $module): string
    {
        $flags = implode(', ', $prefilter['flags'] ?? []);
        $category = $prefilter['scam_category'] ?? 'unknown';
        $type = $module === 'call_transcript' ? 'কল ট্রান্সক্রিপ্ট' : 'বার্তা';

        return "{$type}:\n{$text}\n\nপ্রি-ফিল্টার স্কোর: {$prefilter['risk_score']}/100\nপ্রি-ফিল্টার ফ্ল্যাগ: {$flags}\nসনাক্ত শ্রেণি: {$category}";
    }

    private function normalizeResult(array $parsed): array
    {
        $allowed = ['high', 'medium', 'low', 'safe'];
        $riskLevel = strtolower($parsed['risk_level'] ?? 'medium');
        if (! in_array($riskLevel, $allowed, true)) {
            $riskLevel = 'medium';
        }
        $verdictMap = [
            'high' => 'উচ্চ ঝুঁকি',
            'medium' => 'সতর্ক',
            'low' => 'সতর্ক',
            'safe' => 'নিরাপদ',
        ];

        return [
            'risk_level' => $riskLevel,
            'verdict_bn' => $parsed['verdict_bn'] ?? ($verdictMap[$riskLevel] ?? 'সতর্ক'),
            'explanation' => $parsed['explanation'] ?? $parsed['ai_explanation'] ?? 'বিশ্লেষণ সম্পন্ন হয়েছে।',
            'matched_pattern' => $parsed['matched_pattern'] ?? 'Unknown',
            'confidence' => $parsed['confidence'] ?? 'medium',
            'ai_source' => 'gemini',
        ];
    }

    private function loadFewShotExamples(): array
    {
        $bangla = DatasetRepository::bangalaBartaRows('smish');
        if ($bangla !== []) {
            shuffle($bangla);
            $picked = array_slice($bangla, 0, 15);

            return array_map(fn ($r) => [
                'text_bn' => mb_substr($r['text'], 0, 300),
                'risk_level' => 'high',
                'category' => \App\Support\ScamCategoryDetector::categoryForPattern($r['text']),
                'red_flags_bn' => 'BangalaBarta smishing',
            ], $picked);
        }

        $rows = DatasetCsv::rows();
        if (empty($rows)) {
            return $this->defaultFewShotExamples();
        }

        $highRisk = array_values(array_filter($rows, fn ($r) => ($r['risk_level'] ?? '') === 'high'));

        return array_map(fn ($r) => [
            'text_bn' => $r['text_bn'] ?? '',
            'risk_level' => $r['risk_level'] === 'none' ? 'safe' : $r['risk_level'],
            'category' => $r['category'] ?? '',
            'red_flags_bn' => $r['red_flags_bn'] ?? '',
        ], array_slice($highRisk, 0, 10));
    }

    private function defaultFewShotExamples(): array
    {
        return [
            [
                'text_bn' => 'জরুরি: আপনার bKash হিসাব বন্ধ হবে, OTP দিন।',
                'risk_level' => 'high',
                'category' => 'OTP/PIN ফিশিং',
                'red_flags_bn' => 'জরুরি, OTP চাওয়া',
            ],
        ];
    }
}
