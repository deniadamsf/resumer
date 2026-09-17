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
        $this->model = config('services.gemini.model', env('GEMINI_MODEL', 'gemini-3.5-flash-lite'));
        $this->baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
    }

    /**
     * Generate structured, ATS-compliant CV content from user form input.
     */
    public function generateCv(array $input): array
    {
        $locale = $input['language'] ?? 'id_ID';
        $isEnglish = str_starts_with(strtolower($locale), 'en');
        $langInstruction = $isEnglish
            ? "CRITICAL LANGUAGE REQUIREMENT: Generate ALL resume text (summary, highlights/bullet points, project descriptions, skills) strictly in US English."
            : "CRITICAL LANGUAGE REQUIREMENT: Generate ALL resume text (summary, highlights/bullet points, project descriptions, skills) strictly in professional formal Indonesian (Bahasa Indonesia baku HRD & korporat).";

        $systemPrompt = <<<PROMPT
You are a premier Executive ATS CV Architect for elite Fortune 500 and global tech standards.
Your objective is to polish the candidate's data into a world-class ATS-ready resume.
Rules:
1. Apply Google XYZ formula: "Accomplished [X] as measured by [Y], by doing [Z]" using strong action verbs (Spearheaded, Orchestrated, Engineered, Accelerated).
2. Professional Summary: 3-4 impactful sentences summarizing core value proposition, key competencies, and career trajectory.
3. Work Experience: Rephrase each bullet point with high-impact action verbs and estimated realistic metrics.
4. {$langInstruction}
5. Output strict JSON only. Do not add markdown backticks outside JSON.

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
    public function checkAtsScore(string $cvText, ?string $targetRole = null, string $locale = 'id_ID'): array
    {
        $roleContext = $targetRole ? "Target Role: {$targetRole}\n" : "";
        $isEnglish = str_starts_with(strtolower($locale), 'en');
        $langInstruction = $isEnglish
            ? "CRITICAL LANGUAGE REQUIREMENT: Write all strengths, improvements, verdict, and actionable feedback strictly in English."
            : "CRITICAL LANGUAGE REQUIREMENT: Write all strengths, improvements, verdict, and actionable feedback strictly in Bahasa Indonesia.";

        $systemPrompt = <<<PROMPT
You are an advanced ATS Parser and Corporate HR Recruiter evaluating a resume.
Score the CV rigorously from 0 to 100 based on modern enterprise ATS standards:
1. Keyword & Industry Match (0-25)
2. Impact & Action Verbs (0-25)
3. Format & Readability (0-25)
4. Completeness & Profile Strength (0-25)
5. {$langInstruction}

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
    public function autoFixAts(string $cvText, array $suggestions = [], string $locale = 'id_ID'): array
    {
        $isEnglish = str_starts_with(strtolower($locale), 'en');
        $langInstruction = $isEnglish
            ? "CRITICAL LANGUAGE REQUIREMENT: Output improved summary, bullet points, skills, and changes_made strictly in US English."
            : "CRITICAL LANGUAGE REQUIREMENT: Output improved summary, bullet points, skills, and changes_made strictly in formal Indonesian (Bahasa Indonesia baku HRD).";

        $systemPrompt = <<<PROMPT
You are an expert ATS Optimization Engine.
Your task is to take the provided CV text and suggestions, and completely rewrite weak bullet points into high-impact Google XYZ statements, inject missing industry keywords, and optimize for 95+ ATS readability.
Rules:
1. {$langInstruction}
2. Apply Google XYZ formula to experience bullets.

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
    public function matchJob(string $cvText, ?string $jobText = null, ?string $imageBase64 = null, string $locale = 'id_ID'): array
    {
        $isEnglish = str_starts_with(strtolower($locale), 'en');
        $langInstruction = $isEnglish
            ? "CRITICAL LANGUAGE REQUIREMENT: Output verdict and tailoring_suggestions strictly in US English."
            : "CRITICAL LANGUAGE REQUIREMENT: Output verdict and tailoring_suggestions strictly in formal corporate Indonesian (Bahasa Indonesia baku HRD).";

        $systemPrompt = <<<PROMPT
You are an AI Job Matching Specialist.
Analyze the candidate's CV against the provided job posting text or screenshot image.
Calculate compatibility match score (0-100%), list matching keywords, missing keywords, and recommend CV customizations.

Rules:
1. {$langInstruction}
2. Ensure tailoring_suggestions provide concrete, actionable advice to align the CV with the job description.

Output strict JSON:
{
  "match_score": 85,
  "verdict": "string",
  "matched_keywords": ["string"],
  "missing_keywords": ["string"],
  "tailoring_suggestions": [
    "string"
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
     * AI Cover Letter Generator tailored to target company and role, grounded strictly in candidate CV.
     */
    public function generateCoverLetter(string $cvText, string $company, string $role, string $locale = 'id_ID'): array
    {
        $isEnglish = str_starts_with(strtolower($locale), 'en');
        $langInstruction = $isEnglish
            ? "CRITICAL LANGUAGE REQUIREMENT: Draft the entire cover letter (salutation, 3 body paragraphs, signoff) strictly in US English."
            : "CRITICAL LANGUAGE REQUIREMENT: Draft the entire cover letter (salutation, 3 body paragraphs, signoff) strictly in formal corporate Indonesian (Bahasa Indonesia formal).";

        $systemPrompt = <<<PROMPT
You are an Executive Communications Specialist and HR Recruiter.
Draft a bespoke, highly compelling 3-paragraph corporate cover letter for the candidate applying to {$company} for the target position of {$role}.
Tone: Confident, sophisticated, bespoke executive, and strictly grounded in the candidate's actual qualifications.

CRITICAL GROUNDING RULES:
1. Menganalisis secara mendalam seluruh isi CV kandidat yang diberikan (posisi saat ini, riwayat pekerjaan, pencapaian berformula Google XYZ dengan metrik terukur, keahlian utama, dan pendidikan).
2. Paragraf 1 (Pembuka): Nyatakan antusiasme melamar posisi {$role} di {$company}. Kemukakan ringkasan nilai jual utama (unique selling proposition) kandidat yang berakar langsung pada rekam jejak spesialisasi CV-nya.
3. Paragraf 2 (Korelasi Bukti & Capaian CV): Ambil 2-3 pencapaian nyata, metrik persentase/skala, proyek, atau keahlian spesifik dari riwayat kerja di CV kandidat. Tunjukkan korelasi bagaimana pencapaian masa lalu tersebut akan langsung menyelesaikan tantangan bisnis atau mendorong target strategis di {$company}. DILARANG MENGARANG fakta di luar CV!
4. Paragraf 3 (Visi Kontribusi & Penutup): Sampaikan visi kontribusi kandidat terhadap inovasi dan pertumbuhan {$company}, serta seruan aksi (call to action) untuk tahap wawancara dengan sopan dan percaya diri.
5. Signoff: Penutup profesional satu baris tanpa menyertakan nama (misal: "Sincerely," atau "Hormat saya,"). Nama dan tanda tangan kandidat akan disematkan secara dinamis oleh sistem.
6. {$langInstruction}

Output strict JSON:
{
  "salutation": "Dear Hiring Team at {$company},",
  "paragraph_1": "...",
  "paragraph_2": "...",
  "paragraph_3": "...",
  "signoff": "Sincerely,"
}
PROMPT;

        $userPrompt = "Candidate CV:\n" . $cvText;
        $result = $this->callGeminiJson($systemPrompt, $userPrompt);
        $result['company'] = !empty($result['company']) ? $result['company'] : $company;
        $result['role'] = !empty($result['role']) ? $result['role'] : $role;
        return $result;
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
        if (empty($this->apiKey) || app()->environment('testing')) {
            // If in test environment or no API key configured, return mock structured response
            Log::info('Returning mock response for testing environment.');
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

        $response = Http::timeout(30)
            ->withOptions(['force_ip_resolve' => 'v4'])
            ->post($url, $payload);

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
                    'section' => 'Experience',
                    'issue' => 'Include more quantifiable metrics in past roles',
                    'suggestion' => 'Highlight performance gains and team leadership scale'
                ]
            ],
            'improved_cv_data' => [
                'summary' => 'Accomplished Senior Mobile Engineer with proven track record in architecting high-performance Flutter applications.',
                'experiences' => [
                    [
                        'company' => 'Tech Enterprise',
                        'position' => 'Senior Mobile Engineer',
                        'period' => '2021 - Present',
                        'bullet_points' => [
                            'Spearheaded mobile architecture optimization, reducing crash rates by 45% across 200,000+ active users.',
                            'Architected clean state management pipeline resulting in 30% faster feature delivery.'
                        ]
                    ]
                ],
                'skills' => ['Flutter', 'Dart', 'CI/CD', 'REST API', 'Clean Architecture']
            ],
            'estimated_new_score' => 96,
            'changes_made' => [
                'Converted passive voice to Google XYZ impact formula',
                'Injected enterprise ATS keywords'
            ],
            // Job Matcher mock fields
            'match_score' => 88,
            'matched_keywords' => ['Flutter', 'Dart', 'REST API', 'State Management', 'Clean Architecture'],
            'missing_keywords' => ['CI/CD Pipelines', 'Automated Testing', 'Docker'],
            'tailoring_suggestions' => [
                'Tambahkan pengalaman mengenai integrasi CI/CD dan unit test pada ringkasan kerja',
                'Tonjolkan pencapaian optimasi performa dan skalabilitas arsitektur'
            ],
            // Cover Letter mock fields
            'salutation' => 'Dear Hiring Team,',
            'paragraph_1' => 'I am writing to express my strong interest in the open position...',
            'paragraph_2' => 'With extensive background in high-performance application engineering...',
            'paragraph_3' => 'I welcome the opportunity to discuss how my skill set aligns with your goals...',
            'signoff' => 'Sincerely,'
        ];
    }
}
