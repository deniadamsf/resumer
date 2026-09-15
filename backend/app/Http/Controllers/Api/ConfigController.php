<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DailyQuota;
use Illuminate\Http\Request;

class ConfigController extends Controller
{
    /**
     * Remote Configuration for Mobile App without releasing APK updates.
     */
    public function getAppConfig(Request $request)
    {
        return response()->json([
            'success' => true,
            'config' => [
                'app_name' => 'Resumer',
                'daily_quota_limit' => (int) env('DAILY_QUOTA_LIMIT', DailyQuota::MAX_DAILY_LIMIT),
                'admob' => [
                    'banner_unit_id' => env('ADMOB_BANNER_UNIT_ID', 'ca-app-pub-3940256099942544/6300978111'),
                    'rewarded_unit_id' => env('ADMOB_REWARDED_UNIT_ID', 'ca-app-pub-3940256099942544/5224354917'),
                    'interstitial_unit_id' => env('ADMOB_INTERSTITIAL_UNIT_ID', 'ca-app-pub-3940256099942544/1033173712'),
                ],
                'min_app_version' => env('MIN_APP_VERSION', '1.0.0'),
                'latest_app_version' => env('LATEST_APP_VERSION', '1.0.0'),
                'force_update' => (bool) env('FORCE_UPDATE', false),
                'is_maintenance' => (bool) env('IS_MAINTENANCE', false),
                'privacy_policy_url' => url('/privacy-policy'),
            ],
        ]);
    }
}
