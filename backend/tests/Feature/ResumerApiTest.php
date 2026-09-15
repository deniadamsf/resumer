<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\DailyQuota;
use App\Models\CvProfile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ResumerApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test public remote config endpoint.
     */
    public function test_can_fetch_app_config(): void
    {
        $response = $this->getJson('/api/v1/app-config');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'config' => [
                    'app_name',
                    'daily_quota_limit',
                    'admob' => [
                        'banner_unit_id',
                        'rewarded_unit_id',
                        'interstitial_unit_id',
                    ],
                    'min_app_version',
                    'force_update',
                    'is_maintenance',
                    'privacy_policy_url',
                ]
            ]);

        $this->assertEquals(5, $response->json('config.daily_quota_limit'));
    }

    /**
     * Test 1-Click Google OAuth login (OAuth Only).
     */
    public function test_oauth_google_login_flow(): void
    {
        $payload = [
            'id_token' => 'mock_token_123456789',
            'device_uuid' => 'device-uuid-test-001',
        ];

        $response = $this->postJson('/api/v1/auth/google', $payload);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'user' => [
                    'email' => 'user_123456789@example.com',
                    'device_uuid' => 'device-uuid-test-001',
                ],
                'quota' => [
                    'used' => 0,
                    'limit' => 5,
                    'remaining' => 5,
                ]
            ]);

        $this->assertNotEmpty($response->json('token'));
        $this->assertDatabaseHas('users', [
            'google_id' => 'google_mock_123456789',
            'email' => 'user_123456789@example.com',
        ]);
    }

    /**
     * Test Multi-Profile CV storage (Up to 3 variations).
     */
    public function test_cv_profile_crud_limits_to_3(): void
    {
        $user = User::factory()->create(['device_uuid' => 'device-test-002']);

        // Save Profile 1
        $response = $this->actingAs($user)
            ->postJson('/api/v1/cv/profiles', [
                'profile_index' => 1,
                'title' => 'Administrative Role CV',
                'target_job' => 'Executive Assistant',
                'template_id' => 'asian_ats',
                'font_family' => 'Outfit',
                'accent_color' => '#0B132B',
                'cv_data' => [
                    'full_name' => 'Jane Doe',
                    'summary' => 'Experienced administrator...',
                ],
                'ats_score' => 92,
            ]);

        $response->assertStatus(200)
            ->assertJson(['success' => true]);

        $this->assertDatabaseHas('cv_profiles', [
            'user_id' => $user->id,
            'profile_index' => 1,
            'title' => 'Administrative Role CV',
        ]);

        // Attempt invalid profile index (e.g. index 4) should fail validation
        $invalidResponse = $this->actingAs($user)
            ->postJson('/api/v1/cv/profiles', [
                'profile_index' => 4,
                'title' => 'Invalid Profile',
                'cv_data' => [],
            ]);

        $invalidResponse->assertStatus(422);

        // Fetch profiles
        $fetchResponse = $this->actingAs($user)
            ->getJson('/api/v1/cv/profiles');

        $fetchResponse->assertStatus(200)
            ->assertJsonCount(1, 'profiles');
    }

    /**
     * Test Daily Quota limits (Max 5x per day with Graceful Rollback).
     */
    public function test_quota_limits_and_consumption(): void
    {
        $user = User::factory()->create(['device_uuid' => 'device-test-quota']);
        $quota = DailyQuota::getTodayQuota($user->id, 'device-test-quota');

        // Verify initial quota
        $this->assertEquals(5, $quota->remainingCount());

        // Perform 1 CV Generation (mock fallback in test environment)
        $generateResponse = $this->actingAs($user)
            ->withHeader('X-Device-UUID', 'device-test-quota')
            ->postJson('/api/v1/cv/generate', [
                'full_name' => 'Candidate Name',
                'contact' => ['email' => 'candidate@example.com', 'phone' => '08123456789'],
                'experiences' => [
                    ['company' => 'Tech Corp', 'position' => 'Developer', 'period' => '2022-2024']
                ],
                'skills' => ['Flutter', 'PHP', 'Laravel'],
            ]);

        $generateResponse->assertStatus(200)
            ->assertJson(['success' => true]);

        // Refresh quota from DB
        $quota->refresh();
        $this->assertEquals(1, $quota->used_count);
        $this->assertEquals(4, $quota->remainingCount());

        // Exhaust remaining quota
        $quota->update(['used_count' => 5]);

        // Next request should be blocked with 429 Too Many Requests
        $blockedResponse = $this->actingAs($user)
            ->withHeader('X-Device-UUID', 'device-test-quota')
            ->postJson('/api/v1/cv/generate', [
                'full_name' => 'Candidate Name',
                'contact' => ['email' => 'candidate@example.com'],
            ]);

        $blockedResponse->assertStatus(429)
            ->assertJson([
                'success' => false,
                'message' => 'quota.limit_reached',
                'quota' => [
                    'remaining' => 0,
                ],
            ]);
    }

    /**
     * Test ATS Score Check endpoint.
     */
    public function test_ats_score_checker(): void
    {
        $user = User::factory()->create(['device_uuid' => 'device-ats-test']);

        $response = $this->actingAs($user)
            ->postJson('/api/v1/cv/ats-check', [
                'cv_text' => 'Experienced software engineer who spearheaded architecture design, increased system performance by 40%, and led 5 junior developers.',
                'target_role' => 'Senior Backend Engineer',
            ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'ats_result' => [
                    'total_score',
                    'breakdown',
                ],
                'history_id',
            ]);

        $this->assertDatabaseHas('ats_histories', [
            'user_id' => $user->id,
        ]);
    }

    /**
     * Test Privacy Policy static view.
     */
    public function test_privacy_policy_page_loads(): void
    {
        $response = $this->get('/privacy-policy');
        $response->assertStatus(200)
            ->assertSee('Privacy Policy')
            ->assertSee('Zero Server Photo Processing Guarantee');
    }
}
