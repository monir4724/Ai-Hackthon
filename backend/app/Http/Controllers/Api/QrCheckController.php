<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\QrSafetyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class QrCheckController extends Controller
{
    public function __construct(
        private readonly QrSafetyService $qrSafety
    ) {}

    public function check(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'payload' => 'required|string|min:3|max:5000',
            'session_id' => 'nullable|string|max:64',
        ]);

        try {
            $result = $this->qrSafety->check(
                $validated['payload'],
                $validated['session_id'] ?? null
            );
        } catch (\Throwable $e) {
            Log::error('QR check failed', ['error' => $e->getMessage()]);

            return response()->json([
                'message' => 'QR যাচাই ব্যর্থ হয়েছে।',
            ], 503);
        }

        return response()->json($result, 200);
    }
}
