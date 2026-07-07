<?php

use App\Http\Controllers\Api\AnalyzeController;
use App\Http\Controllers\Api\QrCheckController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\ScanHistoryController;
use App\Http\Controllers\Api\UrlCheckController;
use Illuminate\Support\Facades\Route;

Route::post('/analyze', [AnalyzeController::class, 'analyze']);
Route::post('/url-check', [UrlCheckController::class, 'check']);
Route::post('/qr-check', [QrCheckController::class, 'check']);
Route::get('/reports', [ReportController::class, 'index']);
Route::post('/reports', [ReportController::class, 'store']);
Route::get('/history/{sessionId}', [ScanHistoryController::class, 'index']);
Route::post('/history', [ScanHistoryController::class, 'store']);
