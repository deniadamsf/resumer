/// Immutable data model for AI Cover Letter
class CoverLetterModel {
  final String companyName;
  final String targetRole;
  final String salutation;
  final String paragraph1;
  final String paragraph2;
  final String paragraph3;
  final String signoff;

  const CoverLetterModel({
    required this.companyName,
    required this.targetRole,
    required this.salutation,
    required this.paragraph1,
    required this.paragraph2,
    required this.paragraph3,
    required this.signoff,
  });

  factory CoverLetterModel.fromJson(
    Map<String, dynamic> json, {
    String company = '',
    String role = '',
  }) {
    final companyName = json['company_name'] as String? ?? (company.isNotEmpty ? company : 'Perusahaan Target');
    final targetRole = json['target_role'] as String? ?? (role.isNotEmpty ? role : 'Posisi Target');

    return CoverLetterModel(
      companyName: companyName,
      targetRole: targetRole,
      salutation: (json['salutation'] as String?)?.isNotEmpty == true
          ? json['salutation']
          : 'Kepada Tim Rekrutmen yang Terhormat di $companyName,',
      paragraph1: (json['paragraph_1'] as String?)?.isNotEmpty == true
          ? json['paragraph_1']
          : 'Saya menulis surat ini untuk menyampaikan ketertarikan mendalam saya terhadap posisi $targetRole di $companyName. Dengan latar belakang yang kuat dalam arsitektur analitika data enterprise, perancangan data pipeline, serta visualisasi eksekutif, saya berkeyakinan dapat memberikan kontribusi nyata dan terukur terhadap target strategis perusahaan.',
      paragraph2: (json['paragraph_2'] as String?)?.isNotEmpty == true
          ? json['paragraph_2']
          : 'Sepanjang perjalanan karir profesional, saya telah terbukti memimpin inisiatif optimasi query database berskala besar, mengotomatisasi pipeline integrasi terpadu, dan merancang dashboard intelijen bisnis yang mendongkrak efisiensi operasional lebih dari 35%. Prinsip kerja berbasis formula dampak terukur Google XYZ selalu saya kedepankan.',
      paragraph3: (json['paragraph_3'] as String?)?.isNotEmpty == true
          ? json['paragraph_3']
          : 'Saya menyambut baik kesempatan untuk berdiskusi secara langsung mengenai bagaimana kapabilitas analitis dan komitmen kerja saya dapat memperkuat visi inovasi di $companyName. Terima kasih banyak atas waktu dan pertimbangan yang diberikan.',
      signoff: (json['signoff'] as String?)?.isNotEmpty == true
          ? json['signoff']
          : 'Hormat saya,\nAlexander Wright',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'target_role': targetRole,
      'salutation': salutation,
      'paragraph_1': paragraph1,
      'paragraph_2': paragraph2,
      'paragraph_3': paragraph3,
      'signoff': signoff,
    };
  }

  /// Formatted continuous text suitable for clipboard copy or plain text viewer
  String toFormattedText({String? candidateName}) {
    final buffer = StringBuffer();
    buffer.writeln(salutation);
    buffer.writeln();
    buffer.writeln(paragraph1);
    buffer.writeln();
    buffer.writeln(paragraph2);
    buffer.writeln();
    buffer.writeln(paragraph3);
    buffer.writeln();
    final cleanSignoff = signoff.split('\n').first.trim();
    buffer.writeln(cleanSignoff.isNotEmpty ? cleanSignoff : 'Sincerely,');
    if (candidateName != null && candidateName.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(candidateName);
    }
    return buffer.toString();
  }
}
