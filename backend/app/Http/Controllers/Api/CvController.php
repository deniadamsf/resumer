<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CvProfile;
use App\Models\AtsHistory;
use App\Models\DailyQuota;
use App\Services\Gemini\GeminiService;
use Illuminate\Http\Request;
use Exception;

class CvController extends Controller
{
    protected GeminiService $gemini;

    public function __construct(GeminiService $gemini)
    {
        $this->gemini = $gemini;
    }

    /**
     * Retrieve all saved CV profiles for the authenticated user (up to 3 variations).
     */
    public function getProfiles(Request $request)
    {
        $user = $request->user();
        $profiles = $user->cvProfiles()->get();

        return response()->json([
            'success' => true,
            'profiles' => $profiles,
        ]);
    }

    /**
     * Save or update a CV profile (multi-profil 1, 2, or 3).
     */
    public function saveProfile(Request $request)
    {
        $request->validate([
            'profile_index' => 'required|integer|between:1,3',
            'title' => 'required|string|max:100',
            'target_job' => 'nullable|string|max:100',
            'template_id' => 'nullable|string|in:asian_ats,western_strict,modern_accent',
            'font_family' => 'nullable|string|in:Outfit,Calibri,Arial,Garamond',
            'accent_color' => 'nullable|string|max:20',
            'cv_data' => 'required|array',
            'ats_score' => 'nullable|integer|between:0,100',
        ]);

        $user = $request->user();

        $profile = CvProfile::updateOrCreate(
            [
                'user_id' => $user->id,
                'profile_index' => $request->input('profile_index'),
            ],
            [
                'title' => $request->input('title'),
                'target_job' => $request->input('target_job'),
                'template_id' => $request->input('template_id', 'asian_ats'),
                'font_family' => $request->input('font_family', 'Outfit'),
                'accent_color' => $request->input('accent_color', '#0B132B'),
                'cv_data' => $request->input('cv_data'),
                'ats_score' => $request->input('ats_score'),
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Profile saved successfully.',
            'profile' => $profile,
        ]);
    }

    /**
     * Delete a specific CV profile slot.
     */
    public function deleteProfile(Request $request, int $profileIndex)
    {
        $user = $request->user();
        $user->cvProfiles()->where('profile_index', $profileIndex)->delete();

        return response()->json([
            'success' => true,
            'message' => "Profile {$profileIndex} deleted successfully.",
        ]);
    }

    /**
     * AI CV Generator: Polishes candidate inputs into high-impact Google XYZ resume.
     * Consumes 1 daily quota on successful generation.
     */
    public function generate(Request $request)
    {
        $request->validate([
            'full_name' => 'required|string|max:150',
            'contact' => 'required|array',
            'experiences' => 'nullable|array',
            'educations' => 'nullable|array',
            'skills' => 'nullable|array',
        ]);

        /** @var DailyQuota $dailyQuota */
        $dailyQuota = $request->attributes->get('daily_quota');

        try {
            $generatedData = $this->gemini->generateCv($request->all());

            // Deduct quota only upon verified success
            if ($dailyQuota) {
                $dailyQuota->consumeQuota();
            }

            return response()->json([
                'success' => true,
                'message' => 'CV generated successfully.',
                'cv_data' => $generatedData,
                'quota' => [
                    'remaining' => $dailyQuota ? $dailyQuota->remainingCount() : null,
                    'limit' => DailyQuota::MAX_DAILY_LIMIT,
                ],
            ]);
        } catch (Exception $e) {
            // Graceful rollback: quota is not deducted
            return response()->json([
                'success' => false,
                'message' => 'Generation failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * ATS Score Checker: Calculates 0-100 ATS Score and detailed actionable feedback.
     * Monetized via Rewarded Ad in mobile app before calling or revealing.
     */
    public function atsCheck(Request $request)
    {
        $request->validate([
            'cv_text' => 'required|string|min:50',
            'target_role' => 'nullable|string|max:100',
            'cv_profile_id' => 'nullable|integer|exists:cv_profiles,id',
        ]);

        $user = $request->user();
        $deviceUuid = $request->header('X-Device-UUID') ?? $user?->device_uuid ?? 'unknown';

        try {
            $analysis = $this->gemini->checkAtsScore(
                $request->input('cv_text'),
                $request->input('target_role'),
                $request->input('language', 'id_ID')
            );

            // Save history record
            $history = AtsHistory::create([
                'user_id' => $user?->id,
                'device_uuid' => $deviceUuid,
                'cv_profile_id' => $request->input('cv_profile_id'),
                'score' => $analysis['total_score'] ?? 85,
                'breakdown' => $analysis['breakdown'] ?? [],
                'actionable_feedback' => $analysis['actionable_feedback'] ?? [],
            ]);

            return response()->json([
                'success' => true,
                'ats_result' => $analysis,
                'history_id' => $history->id,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'ATS Check failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * 1-Click ATS Auto-Fix: Transforms a lower-scoring CV to 95+ score.
     * Consumes 1 daily quota on successful auto-fix.
     */
    public function atsAutoFix(Request $request)
    {
        $request->validate([
            'cv_text' => 'required|string|min:50',
            'suggestions' => 'nullable|array',
        ]);

        /** @var DailyQuota $dailyQuota */
        $dailyQuota = $request->attributes->get('daily_quota');

        try {
            $improved = $this->gemini->autoFixAts(
                $request->input('cv_text'),
                $request->input('suggestions', []),
                $request->input('language', 'id_ID')
            );

            // Deduct quota on success
            if ($dailyQuota) {
                $dailyQuota->consumeQuota();
            }

            return response()->json([
                'success' => true,
                'improved_cv' => $improved,
                'quota' => [
                    'remaining' => $dailyQuota ? $dailyQuota->remainingCount() : null,
                    'limit' => DailyQuota::MAX_DAILY_LIMIT,
                ],
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Auto-Fix failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Job Matcher: Compares CV with job posting text or screenshot OCR.
     */
    public function jobMatch(Request $request)
    {
        $request->validate([
            'cv_text' => 'required|string|min:50',
            'job_text' => 'nullable|string',
            'job_image' => 'nullable|string', // Base64 image
        ]);

        if (!$request->filled('job_text') && !$request->filled('job_image')) {
            return response()->json([
                'success' => false,
                'message' => 'Either job_text or job_image is required.',
            ], 422);
        }

        try {
            $matchResult = $this->gemini->matchJob(
                $request->input('cv_text'),
                $request->input('job_text'),
                $request->input('job_image')
            );

            return response()->json([
                'success' => true,
                'match_result' => $matchResult,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Job match failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * AI Cover Letter Generator.
     */
    public function coverLetter(Request $request)
    {
        $request->validate([
            'cv_text' => 'required|string|min:50',
            'company_name' => 'required|string|max:100',
            'target_role' => 'required|string|max:100',
        ]);

        try {
            $letter = $this->gemini->generateCoverLetter(
                $request->input('cv_text'),
                $request->input('company_name'),
                $request->input('target_role'),
                $request->input('language', 'id_ID')
            );

            return response()->json([
                'success' => true,
                'cover_letter' => $letter,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Cover letter generation failed: ' . $e->getMessage(),
            ], 500);
        }
    }
}
