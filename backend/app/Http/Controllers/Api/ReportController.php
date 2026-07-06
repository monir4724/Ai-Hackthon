<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ScamPattern;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = ScamPattern::query()
            ->orderByDesc('created_at');

        if ($request->boolean('community_only')) {
            $query->where('is_community_report', true);
        }

        $patterns = $query->limit(50)->get([
            'id', 'category', 'label', 'risk_level', 'text_bn',
            'red_flags_bn', 'is_community_report', 'created_at',
        ]);

        return response()->json(['data' => $patterns]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'text_bn' => 'required|string|min:10|max:2000',
            'category' => 'nullable|string|max:120',
            'risk_level' => 'nullable|string|in:high,medium,low,safe',
        ]);

        $pattern = ScamPattern::create([
            'category' => $validated['category'] ?? 'Community reported scam',
            'label' => 'scam',
            'risk_level' => $validated['risk_level'] ?? 'high',
            'text_bn' => $validated['text_bn'],
            'red_flags_bn' => 'সম্প্রদায় রিপোর্ট',
            'pattern_basis' => 'User-submitted community report',
            'is_synthetic' => false,
            'is_community_report' => true,
        ]);

        return response()->json([
            'message' => 'রিপোর্ট সংরক্ষিত হয়েছে',
            'data' => $pattern,
        ], 201);
    }
}
