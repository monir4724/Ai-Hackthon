<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ScamAnalysisService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnalyzeController extends Controller
{
    public function __construct(
        private readonly ScamAnalysisService $analysisService
    ) {}

    public function analyze(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'text' => 'required|string|min:5|max:5000',
            'module' => 'nullable|string|in:sms,call_transcript',
            'session_id' => 'nullable|string|max:64',
        ]);

        $result = $this->analysisService->analyze(
            $validated['text'],
            $validated['module'] ?? 'sms'
        );

        if (! empty($validated['session_id'])) {
            $this->analysisService->saveHistory(
                $validated['session_id'],
                $validated['text'],
                $result
            );
        }

        return response()->json($result);
    }
}
