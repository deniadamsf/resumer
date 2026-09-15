<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PrivacyPolicyController;

Route::get('/', function () {
    return response()->json([
        'app' => 'Resumer API Gateway',
        'status' => 'online',
        'version' => '1.0.0',
        'documentation' => 'https://resumer.cellanoma.my.id/privacy-policy',
        'timestamp' => now()->toIso8601String(),
    ]);
});

Route::get('/privacy-policy', [PrivacyPolicyController::class, 'show'])->name('privacy-policy');
