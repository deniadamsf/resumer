<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DailyQuota;
use Illuminate\Http\Request;

class QuotaController extends Controller
{
    /**
     * Get user's today quota status.
     */
    public function getQuota(Request $request)
    {
        $user = $request->user();
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->input('device_uuid') ?? $user?->device_uuid;

        if (!$deviceUuid && !$user) {
            return response()->json([
                'success' => false,
                'message' => 'Device UUID or authenticated user required.',
            ], 422);
        }

        $quota = DailyQuota::getTodayQuota($user?->id, $deviceUuid ?? 'unknown');

        return response()->json([
            'success' => true,
            'quota' => [
                'used' => $quota->used_count,
                'limit' => DailyQuota::MAX_DAILY_LIMIT,
                'remaining' => $quota->remainingCount(),
                'resets_at' => now()->endOfDay()->toIso8601String(),
            ],
        ]);
    }
}
