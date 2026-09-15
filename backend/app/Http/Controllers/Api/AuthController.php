<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\DailyQuota;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    /**
     * 1-Click Google OAuth Sign-In (OAuth Only - Zero Manual Passwords).
     */
    public function googleLogin(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
            'device_uuid' => 'required|string',
        ]);

        $idToken = $request->input('id_token');
        $deviceUuid = $request->input('device_uuid');

        $googleUser = $this->verifyGoogleToken($idToken);

        if (!$googleUser) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired Google token.',
            ], 401);
        }

        // Find or create user by google_id or email
        $user = User::updateOrCreate(
            ['google_id' => $googleUser['sub']],
            [
                'email' => $googleUser['email'],
                'name' => $googleUser['name'] ?? 'Resumer User',
                'avatar_url' => $googleUser['picture'] ?? null,
                'device_uuid' => $deviceUuid,
            ]
        );

        // Revoke old tokens and create a fresh Sanctum token
        $user->tokens()->delete();
        $token = $user->createToken('resumer_mobile_token')->plainTextToken;

        // Fetch today's quota for user
        $quota = DailyQuota::getTodayQuota($user->id, $deviceUuid);

        return response()->json([
            'success' => true,
            'message' => 'Authenticated successfully.',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'avatar_url' => $user->avatar_url,
                'device_uuid' => $user->device_uuid,
            ],
            'quota' => [
                'used' => $quota->used_count,
                'limit' => DailyQuota::MAX_DAILY_LIMIT,
                'remaining' => $quota->remainingCount(),
                'resets_at' => now()->endOfDay()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Verify Google ID token via Google Tokeninfo API or mock test payload.
     */
    protected function verifyGoogleToken(string $idToken): ?array
    {
        // Allow mock token for local testing
        if (app()->environment('testing', 'local') && str_starts_with($idToken, 'mock_token_')) {
            return [
                'sub' => 'google_mock_' . substr($idToken, 11),
                'email' => 'user_' . substr($idToken, 11) . '@example.com',
                'name' => 'Demo User',
                'picture' => 'https://ui-avatars.com/api/?name=Demo+User',
            ];
        }

        try {
            $response = Http::timeout(10)->get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $idToken,
            ]);

            if ($response->successful()) {
                $payload = $response->json();
                if (isset($payload['sub'], $payload['email'])) {
                    return $payload;
                }
            }
        } catch (\Exception $e) {
            Log::error('Google OAuth verification failed: ' . $e->getMessage());
        }

        return null;
    }

    /**
     * Log out and invalidate Sanctum token.
     */
    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully.',
        ]);
    }
}
