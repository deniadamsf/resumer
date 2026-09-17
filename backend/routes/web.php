<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Web\HomeController;
use App\Http\Controllers\Web\LegalController;
use App\Http\Controllers\Web\AccountDeletionController;

// Executive Landing Page
Route::get('/', [HomeController::class, 'index'])->name('home');

// Direct APK Download
Route::get('/download-apk', [HomeController::class, 'downloadApk'])->name('download-apk');

// Legal Documents (Google Play Store & GDPR/CCPA Compliance)
Route::get('/privacy-policy', [LegalController::class, 'privacyPolicy'])->name('privacy-policy');
Route::get('/disclaimer', [LegalController::class, 'disclaimer'])->name('disclaimer');

// Account Deletion Flow (Google Play Console Policy Compliance)
Route::get('/delete-account', [AccountDeletionController::class, 'show'])->name('account-deletion');
Route::post('/delete-account', [AccountDeletionController::class, 'submit'])->name('account-deletion.submit');
