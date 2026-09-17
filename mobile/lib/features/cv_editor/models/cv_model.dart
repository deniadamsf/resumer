class CvDocument {
  String templateId; // 'asian_ats' or 'western_strict'
  String fontFamily; // 'Outfit', 'Calibri', 'Arial', 'Garamond'
  String accentColor; // '#0B132B'
  PersonalInfo personalInfo;
  String summary;
  bool showSummary;
  List<WorkExperience> experiences;
  bool showExperience;
  List<Education> educations;
  bool showEducation;
  List<SkillItem> skills;
  bool showSkills;
  List<CertificationItem> certifications;
  bool showCertifications;
  List<LanguageItem> languages;
  bool showLanguages;
  List<String> hobbies;
  bool showHobbies;

  CvDocument({
    this.templateId = 'asian_ats',
    this.fontFamily = 'Outfit',
    this.accentColor = '#0B132B',
    required this.personalInfo,
    this.summary = '',
    this.showSummary = true,
    this.experiences = const [],
    this.showExperience = true,
    this.educations = const [],
    this.showEducation = true,
    this.skills = const [],
    this.showSkills = true,
    this.certifications = const [],
    this.showCertifications = true,
    this.languages = const [],
    this.showLanguages = false,
    this.hobbies = const [],
    this.showHobbies = false,
  });

  factory CvDocument.empty() {
    return CvDocument(
      personalInfo: PersonalInfo(),
      experiences: [],
      educations: [],
      skills: [],
      certifications: [],
      languages: [],
      showLanguages: false,
      hobbies: [],
      showHobbies: false,
    );
  }

  CvDocument clone() {
    final doc = CvDocument.fromJson(toJson());
    doc.personalInfo.localPhotoPath = personalInfo.localPhotoPath;
    return doc;
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'font_family': fontFamily,
      'accent_color': accentColor,
      'personal_info': personalInfo.toJson(),
      'summary': summary,
      'show_summary': showSummary,
      'experiences': experiences.map((e) => e.toJson()).toList(),
      'show_experience': showExperience,
      'educations': educations.map((e) => e.toJson()).toList(),
      'show_education': showEducation,
      'skills': skills.map((s) => s.toJson()).toList(),
      'show_skills': showSkills,
      'certifications': certifications.map((c) => c.toJson()).toList(),
      'show_certifications': showCertifications,
      'languages': languages.map((l) => l.toJson()).toList(),
      'show_languages': showLanguages,
      'hobbies': hobbies,
      'show_hobbies': showHobbies,
    };
  }

  factory CvDocument.fromJson(Map<String, dynamic> json) {
    return CvDocument(
      templateId: json['template_id'] as String? ?? 'asian_ats',
      fontFamily: json['font_family'] as String? ?? 'Outfit',
      accentColor: json['accent_color'] as String? ?? '#0B132B',
      personalInfo: json['personal_info'] != null
          ? PersonalInfo.fromJson(json['personal_info'] as Map<String, dynamic>)
          : PersonalInfo(),
      summary: json['summary'] as String? ?? '',
      showSummary: json['show_summary'] as bool? ?? true,
      experiences: (json['experiences'] as List<dynamic>?)
              ?.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      showExperience: json['show_experience'] as bool? ?? true,
      educations: (json['educations'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      showEducation: json['show_education'] as bool? ?? true,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((s) => SkillItem.fromJson(s))
              .toList() ??
          [],
      showSkills: json['show_skills'] as bool? ?? true,
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((c) => CertificationItem.fromJson(c))
              .toList() ??
          [],
      showCertifications: json['show_certifications'] as bool? ?? true,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((l) => LanguageItem.fromJson(l))
              .toList() ??
          [],
      showLanguages: json['show_languages'] as bool? ?? false,
      hobbies: (json['hobbies'] as List<dynamic>?)
              ?.map((h) => h.toString())
              .toList() ??
          [],
      showHobbies: json['show_hobbies'] as bool? ?? false,
    );
  }

  /// Converts CV to pure plain text for ATS Robot Parser simulation
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln(personalInfo.fullName.toUpperCase());
    buffer.writeln(personalInfo.professionalTitle);
    buffer.writeln('${personalInfo.email} | ${personalInfo.phone} | ${personalInfo.location}');
    if (personalInfo.linkedin.isNotEmpty) buffer.writeln(personalInfo.linkedin);
    buffer.writeln();

    if (showSummary && summary.isNotEmpty) {
      buffer.writeln('PROFESSIONAL SUMMARY');
      buffer.writeln('--------------------');
      buffer.writeln(summary);
      buffer.writeln();
    }

    if (showExperience && experiences.isNotEmpty) {
      buffer.writeln('WORK EXPERIENCE');
      buffer.writeln('---------------');
      for (final exp in experiences) {
        buffer.writeln('${exp.position} | ${exp.company}');
        buffer.writeln('${exp.startDate} - ${exp.endDate}');
        for (final highlight in exp.highlights) {
          buffer.writeln('• $highlight');
        }
        buffer.writeln();
      }
    }

    if (showEducation && educations.isNotEmpty) {
      buffer.writeln('EDUCATION');
      buffer.writeln('---------');
      for (final edu in educations) {
        buffer.writeln('${edu.degree} in ${edu.fieldOfStudy}');
        buffer.writeln('${edu.institution} (${edu.graduationYear})');
        if (edu.gpa.trim().isNotEmpty) buffer.writeln('GPA: ${edu.gpa.trim()}');
        buffer.writeln();
      }
    }

    if (showSkills && skills.isNotEmpty) {
      buffer.writeln('CORE COMPETENCIES & SKILLS');
      buffer.writeln('--------------------------');
      for (final s in skills) {
        if (s.description.trim().isNotEmpty) {
          buffer.writeln('• ${s.name}: ${s.description.trim()}');
        } else {
          buffer.writeln('• ${s.name}');
        }
      }
      buffer.writeln();
    }

    if (showCertifications && certifications.isNotEmpty) {
      buffer.writeln('CERTIFICATIONS');
      buffer.writeln('--------------');
      for (final cert in certifications) {
        final title = cert.displayTitle;
        if (cert.description.trim().isNotEmpty) {
          buffer.writeln('• $title - ${cert.description.trim()}');
        } else {
          buffer.writeln('• $title');
        }
      }
      buffer.writeln();
    }

    if (showLanguages && languages.isNotEmpty) {
      buffer.writeln('LANGUAGES');
      buffer.writeln('---------');
      buffer.writeln(languages.map((l) => '${l.name} (${l.proficiency})').join(' • '));
      buffer.writeln();
    }

    if (showHobbies && hobbies.isNotEmpty) {
      buffer.writeln('HOBBIES & INTERESTS');
      buffer.writeln('-------------------');
      buffer.writeln(hobbies.join(' • '));
      buffer.writeln();
    }

    return buffer.toString();
  }
}

class PersonalInfo {
  String fullName;
  String professionalTitle;
  String email;
  String phone;
  String location;
  String linkedin;
  String? localPhotoPath; // 100% Client-side local path, NEVER sent to server

  PersonalInfo({
    this.fullName = '',
    this.professionalTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedin = '',
    this.localPhotoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'professional_title': professionalTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedin': linkedin,
      // localPhotoPath is strictly excluded from server sync
    };
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['full_name'] as String? ?? '',
      professionalTitle: json['professional_title'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      linkedin: json['linkedin'] as String? ?? '',
    );
  }
}

class WorkExperience {
  String company;
  String position;
  String startDate;
  String endDate;
  List<String> highlights;

  WorkExperience({
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.highlights = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'position': position,
      'start_date': startDate,
      'end_date': endDate,
      'highlights': highlights,
    };
  }

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      company: json['company'] as String? ?? '',
      position: json['position'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class Education {
  String institution;
  String degree;
  String fieldOfStudy;
  String graduationYear;
  String gpa;

  Education({
    this.institution = '',
    this.degree = '',
    this.fieldOfStudy = '',
    this.graduationYear = '',
    this.gpa = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'graduation_year': graduationYear,
      'gpa': gpa,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      fieldOfStudy: json['field_of_study'] as String? ?? '',
      graduationYear: json['graduation_year'] as String? ?? '',
      gpa: json['gpa'] as String? ?? '',
    );
  }
}

class CvProfileMeta {
  final int profileIndex;
  String title;
  String targetJob;
  int? atsScore;

  CvProfileMeta({
    required this.profileIndex,
    required this.title,
    this.targetJob = '',
    this.atsScore,
  });

  Map<String, dynamic> toJson() => {
        'profile_index': profileIndex,
        'title': title,
        'target_job': targetJob,
        'ats_score': atsScore,
      };

  factory CvProfileMeta.fromJson(Map<String, dynamic> json) => CvProfileMeta(
        profileIndex: json['profile_index'] as int? ?? 1,
        title: json['title'] as String? ?? 'CV ${json['profile_index'] ?? 1}',
        targetJob: json['target_job'] as String? ?? '',
        atsScore: json['ats_score'] as int?,
      );
}

class SkillItem {
  String name;
  String description;

  SkillItem({
    this.name = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  factory SkillItem.fromJson(dynamic json) {
    if (json is String) {
      return SkillItem(name: json);
    }
    if (json is Map) {
      return SkillItem(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
    }
    return SkillItem(name: json?.toString() ?? '');
  }
}

class CertificationItem {
  String name;
  String issuer;
  String year;
  String description;

  CertificationItem({
    this.name = '',
    this.issuer = '',
    this.year = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'issuer': issuer,
        'year': year,
        'description': description,
      };

  factory CertificationItem.fromJson(dynamic json) {
    if (json is String) {
      return CertificationItem(name: json);
    }
    if (json is Map) {
      return CertificationItem(
        name: json['name'] as String? ?? '',
        issuer: json['issuer'] as String? ?? '',
        year: json['year'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
    }
    return CertificationItem(name: json?.toString() ?? '');
  }

  String get displayTitle {
    final parts = <String>[];
    if (name.isNotEmpty) parts.add(name);
    if (issuer.isNotEmpty) parts.add(issuer);
    if (year.isNotEmpty) parts.add('($year)');
    return parts.join(' — ');
  }
}

class LanguageItem {
  String name;
  String proficiency; // 'Native / Bilingual', 'Fluent', 'Professional Working', 'Intermediate', 'Elementary / Basic'

  LanguageItem({
    this.name = '',
    this.proficiency = 'Native / Bilingual',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'proficiency': proficiency,
      };

  factory LanguageItem.fromJson(dynamic json) {
    if (json is String) {
      return LanguageItem(name: json);
    }
    if (json is Map) {
      return LanguageItem(
        name: json['name'] as String? ?? '',
        proficiency: json['proficiency'] as String? ?? 'Native / Bilingual',
      );
    }
    return LanguageItem(name: json?.toString() ?? '');
  }
}

