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

        // Find existing user or create a new user
        $user = User::where('google_id', $googleUser['sub'])->first();

        if (!$user) {
            $user = User::create([
                'google_id' => $googleUser['sub'],
                'email' => $googleUser['email'],
                'name' => $googleUser['name'] ?? 'Resumer User',
                'avatar_url' => $googleUser['picture'] ?? null,
                'device_uuid' => $deviceUuid,
            ]);
        } else {
            // Preserve user's custom name if already edited/set!
            $user->update([
                'email' => $googleUser['email'],
                'avatar_url' => $googleUser['picture'] ?? $user->avatar_url,
                'device_uuid' => $deviceUuid,
            ]);
        }

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
                $webClientId = config('services.google.web_client_id');
                if (!empty($webClientId) && isset($payload['aud']) && $payload['aud'] !== $webClientId) {
                    Log::warning('Google OAuth aud mismatch: expected ' . $webClientId . ', got ' . $payload['aud']);
                    return null;
                }
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
     * Get authenticated user profile.
     */
    public function getProfile(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'avatar_url' => $user->avatar_url,
                'device_uuid' => $user->device_uuid,
            ],
        ]);
    }

    /**
     * Update user profile name independently from Google account name.
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:100',
        ]);

        $user = $request->user();
        $user->name = trim($request->input('name'));
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profil pengguna berhasil diperbarui.',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'avatar_url' => $user->avatar_url,
                'device_uuid' => $user->device_uuid,
            ],
        ]);
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

    /**
     * Permanently delete authenticated user account and all associated data.
     */
    public function deleteAccount(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
            ], 401);
        }

        $email = $user->email;

        \Illuminate\Support\Facades\DB::transaction(function () use ($user) {
            $user->tokens()->delete();
            $user->cvProfiles()->delete();
            $user->atsHistories()->delete();
            $user->dailyQuotas()->delete();
            $user->delete();
        });

        Log::info("Account permanently deleted via mobile API for user: {$email}");

        return response()->json([
            'success' => true,
            'message' => 'Akun dan seluruh data profil CV Anda telah berhasil dihapus secara permanen.',
        ]);
    }
}
