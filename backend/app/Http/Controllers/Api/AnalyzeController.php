<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ScamAnalysisService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AnalyzeController extends Controller
{
    public function __construct(
        private readonly ScamAnalysisService $analysisService
    ) {}

    public function analyze(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'text' => 'required|string|min:5|max:5000',
            'module' => 'nullable|string|in:sms,call_transcript,url',
            'session_id' => 'nullable|string|max:64',
        ]);

        $result = $this->analysisService->analyze(
            $validated['text'],
            $validated['module'] ?? 'sms'
        );

        if (! empty($validated['session_id'])) {
            try {
                $this->analysisService->saveHistory(
                    $validated['session_id'],
                    $validated['text'],
                    $result
                );
            } catch (\Throwable $e) {
                Log::warning('Failed to save scan history', [
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return response()->json($result, 200);
    }
}
