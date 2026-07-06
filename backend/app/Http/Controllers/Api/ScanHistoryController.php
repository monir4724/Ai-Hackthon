<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ScanHistory;
use App\Services\ScamAnalysisService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ScanHistoryController extends Controller
{
    public function __construct(
        private readonly ScamAnalysisService $analysisService
    ) {}

    public function index(string $sessionId): JsonResponse
    {
        $history = ScanHistory::where('session_id', $sessionId)
            ->orderByDesc('created_at')
            ->limit(30)
            ->get();

        return response()->json(['data' => $history]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'session_id' => 'required|string|max:64',
            'text' => 'required|string|min:5|max:5000',
            'module' => 'nullable|string|in:sms,call_transcript,url',
        ]);

        $result = $this->analysisService->analyze(
            $validated['text'],
            $validated['module'] ?? 'sms'
        );

        $this->analysisService->saveHistory(
            $validated['session_id'],
            $validated['text'],
            $result
        );

        return response()->json($result);
    }
}
