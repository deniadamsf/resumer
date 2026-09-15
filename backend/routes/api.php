<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ConfigController;
use App\Http\Controllers\Api\QuotaController;
use App\Http\Controllers\Api\CvController;

Route::prefix('v1')->group(function () {

    // Remote App Configuration (Public)
    Route::get('/app-config', [ConfigController::class, 'getAppConfig']);

    // 1-Click Google OAuth Sign-in (Public - OAuth Only)
    Route::post('/auth/google', [AuthController::class, 'googleLogin']);

    // Protected Routes (Sanctum Authenticated)
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/user/quota', [QuotaController::class, 'getQuota']);

        // Multi-Profile CV Management (Up to 3 variations, JSON ~2-5KB)
        Route::get('/cv/profiles', [CvController::class, 'getProfiles']);
        Route::post('/cv/profiles', [CvController::class, 'saveProfile']);
        Route::delete('/cv/profiles/{profileIndex}', [CvController::class, 'deleteProfile']);

        // AI Services (Monetized via Rewarded Ads in Mobile App)
        Route::post('/cv/ats-check', [CvController::class, 'atsCheck']);
        Route::post('/cv/job-match', [CvController::class, 'jobMatch']);
        Route::post('/cv/cover-letter', [CvController::class, 'coverLetter']);

        // AI Services consuming daily quota (Max 5x per day with Graceful Rollback)
        Route::middleware(['quota'])->group(function () {
            Route::post('/cv/generate', [CvController::class, 'generate']);
            Route::post('/cv/ats-autofix', [CvController::class, 'atsAutoFix']);
        });
    });
});
