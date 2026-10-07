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

  static String _cleanKeyword(dynamic raw) {
    if (raw == null) return '';
    if (raw is Map) {
      final val = raw['suggestion'] ??
          raw['description'] ??
          raw['text'] ??
          raw['keyword'] ??
          raw['name'] ??
          raw['skill'] ??
          raw['title'] ??
          raw['value'] ??
          (raw.values.isNotEmpty ? raw.values.first : null);
      if (val != null) return _cleanKeyword(val);
      return '';
    }
    String str = raw.toString().trim();
    // Strip markdown formatting like bold/italic/backticks
    str = str.replaceAll(RegExp(r'[*_`]'), '').trim();
    // If wrapped in curly braces like {"keyword": "..."} or {keyword: ...}
    if (str.startsWith('{') && str.endsWith('}')) {
      final inner = str.substring(1, str.length - 1).trim();
      if (inner.contains(':')) {
        final parts = inner.split(':');
        if (parts.length > 1) {
          str = parts.sublist(1).join(':').trim();
        }
      }
    }
    while (str.startsWith('"') || str.startsWith("'")) {
      str = str.substring(1).trim();
    }
    while (str.endsWith('"') || str.endsWith("'")) {
      str = str.substring(0, str.length - 1).trim();
    }
    return str;
  }

  factory JobMatchResult.fromJson(Map<String, dynamic> json) {
    return JobMatchResult(
      matchScore: (json['match_score'] as num?)?.toInt() ??
          (json['score'] as num?)?.toInt() ??
          (json['total_score'] as num?)?.toInt() ??
          0,
      verdict: json['verdict'] as String? ?? 'Analisis Selesai',
      fitSummary: json['fit_summary'] as String?,
      matchedKeywords: (json['matched_keywords'] as List<dynamic>?)
              ?.map((e) => _cleanKeyword(e))
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList() ??
          [],
      missingKeywords: (json['missing_keywords'] as List<dynamic>?)
              ?.map((e) => _cleanKeyword(e))
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList() ??
          [],
      tailoringSuggestions: (json['tailoring_suggestions'] as List<dynamic>?)
              ?.map((e) => _cleanKeyword(e))
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
