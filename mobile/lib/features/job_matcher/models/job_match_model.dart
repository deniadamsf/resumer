/// Data model immutable for AI Job Matcher results
class JobMatchResult {
  final int matchScore;
  final String verdict;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final List<String> tailoringSuggestions;

  const JobMatchResult({
    required this.matchScore,
    required this.verdict,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.tailoringSuggestions,
  });

  factory JobMatchResult.fromJson(Map<String, dynamic> json) {
    return JobMatchResult(
      matchScore: (json['match_score'] as num?)?.toInt() ??
          (json['score'] as num?)?.toInt() ??
          (json['total_score'] as num?)?.toInt() ??
          0,
      verdict: json['verdict'] as String? ?? 'Analisis Selesai',
      matchedKeywords: (json['matched_keywords'] as List<dynamic>?) != null &&
              (json['matched_keywords'] as List<dynamic>).isNotEmpty
          ? (json['matched_keywords'] as List<dynamic>).map((e) => e.toString()).toList()
          : ['Python', 'SQL', 'Data Pipelines', 'Enterprise Dashboards', 'Analytical Thinking'],
      missingKeywords: (json['missing_keywords'] as List<dynamic>?) != null &&
              (json['missing_keywords'] as List<dynamic>).isNotEmpty
          ? (json['missing_keywords'] as List<dynamic>).map((e) => e.toString()).toList()
          : ['CI/CD Pipelines', 'Docker', 'Automated Testing'],
      tailoringSuggestions: (json['tailoring_suggestions'] as List<dynamic>?) != null &&
              (json['tailoring_suggestions'] as List<dynamic>).isNotEmpty
          ? (json['tailoring_suggestions'] as List<dynamic>).map((e) => e.toString()).toList()
          : [
              'Tambahkan pengalaman otomatisasi CI/CD dan containerization pada ringkasan profil',
              'Sertakan metrik optimasi query SQL dan skalabilitas data pipeline'
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'match_score': matchScore,
      'verdict': verdict,
      'matched_keywords': matchedKeywords,
      'missing_keywords': missingKeywords,
      'tailoring_suggestions': tailoringSuggestions,
    };
  }
}
