/// Data model immutable for AI Job Matcher results
class JobMatchResult {
  final int matchScore;
  final String verdict;
  final String? fitSummary;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final List<String> tailoringSuggestions;
  final Map<String, dynamic>? tailoredCvData;

  const JobMatchResult({
    required this.matchScore,
    required this.verdict,
    this.fitSummary,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.tailoringSuggestions,
    this.tailoredCvData,
  });

  factory JobMatchResult.fromJson(Map<String, dynamic> json) {
    return JobMatchResult(
      matchScore: (json['match_score'] as num?)?.toInt() ??
          (json['score'] as num?)?.toInt() ??
          (json['total_score'] as num?)?.toInt() ??
          0,
      verdict: json['verdict'] as String? ?? 'Analisis Selesai',
      fitSummary: json['fit_summary'] as String?,
      matchedKeywords: (json['matched_keywords'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      missingKeywords: (json['missing_keywords'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      tailoringSuggestions: (json['tailoring_suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      tailoredCvData: json['tailored_cv_data'] is Map
          ? Map<String, dynamic>.from(json['tailored_cv_data'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'match_score': matchScore,
      'verdict': verdict,
      'fit_summary': fitSummary,
      'matched_keywords': matchedKeywords,
      'missing_keywords': missingKeywords,
      'tailoring_suggestions': tailoringSuggestions,
      'tailored_cv_data': tailoredCvData,
    };
  }
}
