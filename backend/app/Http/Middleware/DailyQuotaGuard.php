<?php

namespace App\Http\Middleware;

use App\Models\DailyQuota;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class DailyQuotaGuard
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->input('device_uuid');
        $user = $request->user();

        if (!$deviceUuid && !$user) {
            return response()->json([
                'success' => false,
                'message' => 'Device UUID or authenticated user required.',
            ], 422);
        }

        $effectiveDeviceUuid = $deviceUuid ?? ($user->device_uuid ?? 'unknown-device');
        $dailyQuota = DailyQuota::getTodayQuota($user?->id, $effectiveDeviceUuid);

        if (!$dailyQuota->hasRemainingQuota()) {
            return response()->json([
                'success' => false,
                'message' => 'quota.limit_reached',
                'quota' => [
                    'used' => $dailyQuota->used_count,
                    'limit' => DailyQuota::MAX_DAILY_LIMIT,
                    'remaining' => 0,
                    'resets_at' => now()->endOfDay()->toIso8601String(),
                ],
            ], 429);
        }

        // Pass the quota instance forward to the controller
        $request->attributes->set('daily_quota', $dailyQuota);

        return $next($request);
    }
}
