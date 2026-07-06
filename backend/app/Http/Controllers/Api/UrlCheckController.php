<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\UrlSafetyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UrlCheckController extends Controller
{
    public function __construct(
        private readonly UrlSafetyService $urlSafety
    ) {}

    public function check(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'url' => 'required|url|max:2048',
        ]);

        return response()->json($this->urlSafety->check($validated['url']));
    }
}
