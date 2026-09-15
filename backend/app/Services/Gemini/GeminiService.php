<?php

namespace App\Services\Gemini;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class GeminiService
{
    protected string $apiKey;
    protected string $model;
    protected string $baseUrl;

    public function __construct()
    {
        $this->apiKey = config('services.gemini.api_key', env('GEMINI_API_KEY', ''));
        $this->model = config('services.gemini.model', env('GEMINI_MODEL', 'gemini-2.5-flash-lite'));
        $this->baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
    }

    /**
     * Generate structured, ATS-compliant CV content from user form input.
     */
    public function generateCv(array $input): array
    {
        $systemPrompt = <<<PROMPT
You are a premier Executive ATS CV Architect for elite Fortune 500 and global tech standards.
Your objective is to polish the candidate's data into a world-class ATS-ready resume.
Rules:
1. Apply Google XYZ formula: "Accomplished [X] as measured by [Y], by doing [Z]" using strong action verbs (Spearheaded, Orchestrated, Engineered, Accelerated).
2. Professional Summary: 3-4 impactful sentences summarizing core value proposition, key competencies, and career trajectory.
3. Work Experience: Rephrase each bullet point with high-impact action verbs and estimated realistic metrics.
4. Output strict JSON only. Do not add markdown backticks outside JSON.

Output JSON structure:
{
  "full_name": "string",
  "professional_title": "string",
  "summary": "string",
  "experiences": [
    {
      "company": "string",
      "position": "string",
      "location": "string",
      "start_date": "string",
      "end_date": "string",
      "highlights": ["string (Google XYZ bullet points)"]
    }
  ],
  "educations": [
    {
      "institution": "string",
      "degree": "string",
      "field_of_study": "string",
      "graduation_year": "string",
      "gpa": "string"
    }
  ],
  "skills": {
    "technical": ["string"],
    "soft": ["string"],
    "tools": ["string"]
  },
  "certifications": ["string"],
  "projects": [
    {
      "title": "string",
      "description": "string",
      "technologies": ["string"]
    }
  ]
}
PROMPT;

        $userPrompt = "Candidate input data:\n" . json_encode($input, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

        return $this->callGeminiJson($systemPrompt, $userPrompt);
    }

    /**
     * Evaluate CV and calculate ATS Score (0 - 100) with detailed breakdown and recommendations.
     */
    public function checkAtsScore(string $cvText, ?string $targetRole = null): array
    {
        $roleContext = $targetRole ? "Target Role: {$targetRole}\n" : "";

        $systemPrompt = <<<PROMPT
You are an advanced ATS Parser and Corporate HR Recruiter evaluating a resume.
Score the CV rigorously from 0 to 100 based on modern enterprise ATS standards:
1. Keyword & Industry Match (0-25)
2. Impact & Action Verbs (0-25)
3. Format & Readability (0-25)
4. Completeness & Profile Strength (0-25)

Note: If the CV is already highly structured with action verbs and quantifiable metrics, award 90-98 points.

Output strict JSON:
{
  "total_score": 92,
  "verdict": "ATS Ready / Top 5% / Needs Improvement",
  "breakdown": {
    "keyword_match": 23,
    "impact_verbs": 24,
    "readability": 24,
    "completeness": 21
  },
  "strengths": [
    "Strong usage of action verbs and quantifiable results"
  ],
  "improvements": [
    "Add more industry-standard technical keywords"
  ],
  "actionable_feedback": [
    {
      "section": "Experience",
      "issue": "Lack of percentage growth metric in recent role",
      "suggestion": "Quantify revenue or efficiency impact"
    }
  ]
}
PROMPT;

        $userPrompt = "{$roleContext}CV Content to evaluate:\n" . $cvText;

        return $this->callGeminiJson($systemPrompt, $userPrompt);
    }

    /**
     * 1-Click ATS Auto-Fix: Transforms a lower-scoring CV into a 95+ score ATS resume.
     */
    public function autoFixAts(string $cvText, array $suggestions = []): array
    {
        $systemPrompt = <<<PROMPT
You are an expert ATS Optimization Engine.
Your task is to take the provided CV text and suggestions, and completely rewrite weak bullet points into high-impact Google XYZ statements, inject missing industry keywords, and optimize for 95+ ATS readability.

Output strict JSON:
{
  "improved_cv_data": {
    "summary": "string",
    "experiences": [
      {
        "company": "string",
        "position": "string",
        "period": "string",
        "bullet_points": ["string"]
      }
    ],
    "skills": ["string"]
  },
  "estimated_new_score": 96,
  "changes_made": [
    "Rewrote passive experience bullets into quantifiable metric-driven accomplishments",
    "Injected core ATS keywords"
  ]
}
PROMPT;

        $userPrompt = "Original CV Content:\n{$cvText}\nSuggestions:\n" . json_encode($suggestions);

        return $this->callGeminiJson($systemPrompt, $userPrompt);
    }

    /**
     * Job Matcher: Compares CV with job description (or OCR screenshot) and calculates compatibility.
     */
    public function matchJob(string $cvText, ?string $jobText = null, ?string $imageBase64 = null): array
    {
        $systemPrompt = <<<PROMPT
You are an AI Job Matching Specialist.
Analyze the candidate's CV against the provided job posting text or screenshot image.
Calculate compatibility match score (0-100%), list matching keywords, missing keywords, and recommend CV customizations.

Output strict JSON:
{
  "match_score": 85,
  "verdict": "High Match / Moderate Match / Low Match",
  "matched_keywords": ["Flutter", "REST API", "State Management"],
  "missing_keywords": ["CI/CD", "Docker", "GraphQL"],
  "tailoring_suggestions": [
    "Emphasize your deployment experience in the experience highlights",
    "Mention familiarity with Agile methodology"
  ]
}
PROMPT;

        $contents = [];
        $parts = [];

        if ($jobText) {
            $parts[] = ['text' => "Job Description:\n" . $jobText];
        }

        if ($imageBase64) {
            $parts[] = [
                'inline_data' => [
                    'mime_type' => 'image/jpeg',
                    'data' => $imageBase64
                ]
            ];
        }

        $parts[] = ['text' => "Candidate CV:\n" . $cvText];
        $contents[] = ['role' => 'user', 'parts' => $parts];

        return $this->callGeminiWithContents($systemPrompt, $contents);
    }

    /**
     * AI Cover Letter Generator tailored to target company and role.
     */
    public function generateCoverLetter(string $cvText, string $company, string $role): array
    {
        $systemPrompt = <<<PROMPT
You are an Executive Communications Specialist.
Draft a compelling 3-paragraph corporate cover letter for the candidate applying to {$company} for the position of {$role}.
Tone: Confident, professional, tailored, and results-oriented.

Output strict JSON:
{
  "salutation": "Dear Hiring Team at {$company},",
  "paragraph_1": "Introduction and immediate value hook...",
  "paragraph_2": "Core achievements from CV aligned with the role...",
  "paragraph_3": "Forward-looking closing and call to action...",
  "signoff": "Sincerely,\n[Candidate Name]"
}
PROMPT;

        $userPrompt = "Candidate CV:\n" . $cvText;

        return $this->callGeminiJson($systemPrompt, $userPrompt);
    }

    /**
     * Helper to call Gemini API with strict JSON schema.
     */
    protected function callGeminiJson(string $systemPrompt, string $userPrompt): array
    {
        $contents = [
            [
                'role' => 'user',
                'parts' => [
                    ['text' => $userPrompt]
                ]
            ]
        ];

        return $this->callGeminiWithContents($systemPrompt, $contents);
    }

    /**
     * Core Gemini API execution via HTTP POST.
     */
    protected function callGeminiWithContents(string $systemPrompt, array $contents): array
    {
        if (empty($this->apiKey)) {
            // If no API key configured (e.g. initial dev test), return mock structured response
            Log::warning('Gemini API key is empty. Returning mock response for testing.');
            return $this->getMockResponse();
        }

        $url = "{$this->baseUrl}/{$this->model}:generateContent?key={$this->apiKey}";

        $payload = [
            'system_instruction' => [
                'parts' => [
                    ['text' => $systemPrompt]
                ]
            ],
            'contents' => $contents,
            'generationConfig' => [
                'response_mime_type' => 'application/json',
                'temperature' => 0.2,
            ]
        ];

        $response = Http::timeout(30)->post($url, $payload);

        if (!$response->successful()) {
            Log::error('Gemini API Error: ' . $response->body());
            throw new Exception('AI Engine Error: ' . $response->status() . ' - ' . $response->body());
        }

        $result = $response->json();
        $rawText = $result['candidates'][0]['content']['parts'][0]['text'] ?? '{}';

        $decoded = json_decode($rawText, true);
        if (!is_array($decoded)) {
            throw new Exception('Invalid JSON returned by AI Engine.');
        }

        return $decoded;
    }

    /**
     * Mock response for local automated unit tests without hitting Gemini API.
     */
    protected function getMockResponse(): array
    {
        return [
            'full_name' => 'John Doe',
            'professional_title' => 'Senior Mobile Engineer',
            'summary' => 'Accomplished software engineer with 5+ years of experience delivering scalable enterprise applications.',
            'total_score' => 95,
            'verdict' => 'Top 5% ATS Ready',
            'breakdown' => [
                'keyword_match' => 24,
                'impact_verbs' => 25,
                'readability' => 24,
                'completeness' => 22
            ],
            'actionable_feedback' => [
                [
                    'section' => 'General',
                    'issue' => 'None',
                    'suggestion' => 'CV is already primed for modern ATS scanners.'
                ]
            ]
        ];
    }
}
