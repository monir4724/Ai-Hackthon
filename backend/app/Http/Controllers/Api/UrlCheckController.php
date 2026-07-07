<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ScamAnalysisService;
use App\Services\UrlSafetyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class UrlCheckController extends Controller
{
    public function __construct(
        private readonly UrlSafetyService $urlSafety,
        private readonly ScamAnalysisService $analysisService
    ) {}

    public function check(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'url' => 'required|url|max:2048',
            'session_id' => 'nullable|string|max:64',
        ]);

        $result = $this->urlSafety->check($validated['url']);
        $result['module'] = 'url';
        $result['matched_pattern'] = 'URL safety check';

        if (! empty($validated['session_id'])) {
            try {
                $this->analysisService->saveHistory(
                    $validated['session_id'],
                    $validated['url'],
                    $result
                );
            } catch (\Throwable $e) {
                Log::warning('Failed to save URL check history', [
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return response()->json($result, 200);
    }
}
