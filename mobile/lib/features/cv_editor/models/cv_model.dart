import '../../../core/utils/date_format_helper.dart';
import '../../../core/utils/social_link_helper.dart';

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
  List<ProjectItem> projects;
  bool showProjects;
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
    this.projects = const [],
    this.showProjects = true,
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
      projects: [],
      showProjects: true,
      languages: [],
      showLanguages: false,
      hobbies: [],
      showHobbies: false,
    );
  }

  /// Memeriksa apakah CV masih kosong (belum diisi data pokok)
  bool get isEmpty {
    return personalInfo.fullName.trim().isEmpty &&
        personalInfo.email.trim().isEmpty &&
        personalInfo.phone.trim().isEmpty &&
        summary.trim().isEmpty &&
        experiences.isEmpty &&
        educations.isEmpty &&
        skills.isEmpty &&
        projects.isEmpty;
  }

  /// Blueprint Bagian 10: Validasi Pra-Generate AI & ATS Checker (Filter Kelayakan Data)
  /// Wajib mengisi kolom inti (Nama, Kontak, min 1 Riwayat Kerja/Pendidikan, min 3 Keahlian, min 50 karakter teks)
  bool get isEligibleForAi {
    final hasName = personalInfo.fullName.trim().isNotEmpty;
    final hasContact = personalInfo.email.trim().isNotEmpty || personalInfo.phone.trim().isNotEmpty;
    final hasHistory = experiences.isNotEmpty || educations.isNotEmpty;
    final hasSkills = skills.length >= 3;
    final hasMinLength = toPlainText().trim().length >= 50;
    return hasName && hasContact && hasHistory && hasSkills && hasMinLength;
  }

  CvDocument clone() {
    final doc = CvDocument.fromJson(toJson(forLocalPersistence: true));
    doc.personalInfo.localPhotoPath = personalInfo.localPhotoPath;
    return doc;
  }

  Map<String, dynamic> toJson({bool forLocalPersistence = false}) {
    return {
      'template_id': templateId,
      'font_family': fontFamily,
      'accent_color': accentColor,
      'personal_info': personalInfo.toJson(forLocalPersistence: forLocalPersistence),
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
      'projects': projects.map((p) => p.toJson()).toList(),
      'show_projects': showProjects,
      'languages': languages.map((l) => l.toJson()).toList(),
      'show_languages': showLanguages,
      'hobbies': hobbies,
      'show_hobbies': showHobbies,
    };
  }

  /// Map representation for local offline storage (includes localPhotoPath)
  Map<String, dynamic> toLocalMap() => toJson(forLocalPersistence: true);

  /// Ensures all experience and education items have full month names.
  /// Migrates legacy or year-only entries (e.g. "2026" -> "Januari 2026", "2020" -> "Agustus 2020").
  void ensureMonthIntegrity({bool isEnglish = false}) {
    for (final exp in experiences) {
      if (exp.startDate.isNotEmpty) {
        final pStart = DateFormatHelper.parse(exp.startDate);
        if (pStart.hasYear && !pStart.hasMonth) {
          exp.startDate = DateFormatHelper.formatMonthYear(
            1,
            pStart.year,
            isEnglish: isEnglish,
            full: true,
          );
        }
      }
      if (exp.endDate.isNotEmpty) {
        final pEnd = DateFormatHelper.parse(exp.endDate);
        if (pEnd.isPresent) {
          exp.endDate = isEnglish ? 'Present' : 'Sekarang';
        } else if (pEnd.hasYear && !pEnd.hasMonth) {
          exp.endDate = DateFormatHelper.formatMonthYear(
            12,
            pEnd.year,
            isEnglish: isEnglish,
            full: true,
          );
        }
      }
    }

    for (final edu in educations) {
      if (edu.graduationYear.isNotEmpty) {
        final pEdu = DateFormatHelper.parse(edu.graduationYear);
        if (pEdu.hasYear && !pEdu.hasMonth) {
          edu.graduationYear = DateFormatHelper.formatMonthYear(
            8,
            pEdu.year,
            isEnglish: isEnglish,
            full: true,
          );
        }
      }
    }

    for (final proj in projects) {
      if (proj.startDate.isNotEmpty) {
        final pStart = DateFormatHelper.parse(proj.startDate);
        if (pStart.hasYear && !pStart.hasMonth) {
          proj.startDate = DateFormatHelper.formatMonthYear(
            1,
            pStart.year,
            isEnglish: isEnglish,
            full: true,
          );
        }
      }
      if (proj.endDate.isNotEmpty && !proj.isCurrent) {
        final pEnd = DateFormatHelper.parse(proj.endDate);
        if (pEnd.isPresent) {
          proj.endDate = isEnglish ? 'Present' : 'Sekarang';
          proj.isCurrent = true;
        } else if (pEnd.hasYear && !pEnd.hasMonth) {
          proj.endDate = DateFormatHelper.formatMonthYear(
            12,
            pEnd.year,
            isEnglish: isEnglish,
            full: true,
          );
        }
      }
    }
  }

  factory CvDocument.fromJson(Map<String, dynamic> json) {
    final doc = CvDocument(
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
      projects: (json['projects'] as List<dynamic>?)
              ?.map((p) => ProjectItem.fromJson(p))
              .toList() ??
          [],
      showProjects: json['show_projects'] as bool? ?? true,
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
    doc.ensureMonthIntegrity();
    return doc;
  }

  /// Converts CV to pure plain text for ATS Robot Parser simulation
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln(personalInfo.fullName.toUpperCase());
    buffer.writeln(personalInfo.professionalTitle);
    buffer.writeln('${personalInfo.email} | ${personalInfo.phone} | ${personalInfo.location}');
    final socialEntries = <String>[];
    if (personalInfo.linkedin.isNotEmpty) {
      socialEntries.add('LinkedIn: ${SocialLinkHelper.buildDisplayText(SocialPlatform.linkedin, personalInfo.linkedin)}');
    }
    if (personalInfo.github.isNotEmpty) {
      socialEntries.add('GitHub: ${SocialLinkHelper.buildDisplayText(SocialPlatform.github, personalInfo.github)}');
    }
    if (personalInfo.website.isNotEmpty) {
      socialEntries.add('Portfolio: ${SocialLinkHelper.buildDisplayText(SocialPlatform.website, personalInfo.website)}');
    }
    if (personalInfo.whatsapp.isNotEmpty) {
      socialEntries.add('WhatsApp: ${SocialLinkHelper.buildDisplayText(SocialPlatform.whatsapp, personalInfo.whatsapp)}');
    }
    if (personalInfo.instagram.isNotEmpty) {
      socialEntries.add('Instagram: ${SocialLinkHelper.buildDisplayText(SocialPlatform.instagram, personalInfo.instagram)}');
    }
    if (personalInfo.facebook.isNotEmpty) {
      socialEntries.add('Facebook: ${SocialLinkHelper.buildDisplayText(SocialPlatform.facebook, personalInfo.facebook)}');
    }
    if (socialEntries.isNotEmpty) {
      buffer.writeln(socialEntries.join(' | '));
    }
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

    if (showProjects && projects.isNotEmpty) {
      buffer.writeln('PROJECTS & PORTFOLIO');
      buffer.writeln('--------------------');
      for (final p in projects) {
        final titleLine = p.role.isNotEmpty ? '${p.name} | ${p.role}' : p.name;
        buffer.writeln(titleLine);
        final period = p.displayPeriod;
        if (period.isNotEmpty) buffer.writeln(period);
        if (p.description.trim().isNotEmpty) {
          for (final line in p.description.trim().split('\n')) {
            final trimmed = line.trim();
            if (trimmed.isNotEmpty) {
              if (trimmed.startsWith('•') || trimmed.startsWith('-')) {
                buffer.writeln(trimmed);
              } else {
                buffer.writeln('• $trimmed');
              }
            }
          }
        }
        buffer.writeln();
      }
    }

    if (languages.isNotEmpty) {
      buffer.writeln('LANGUAGES');
      buffer.writeln('---------');
      buffer.writeln(languages.map((l) => '${l.name} (${l.proficiency})').join(' • '));
      buffer.writeln();
    }

    if (hobbies.isNotEmpty) {
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
  String github;
  String instagram;
  String facebook;
  String whatsapp;
  String website;
  String? localPhotoPath; // 100% Client-side local path, NEVER sent to server

  PersonalInfo({
    this.fullName = '',
    this.professionalTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedin = '',
    this.github = '',
    this.instagram = '',
    this.facebook = '',
    this.whatsapp = '',
    this.website = '',
    this.localPhotoPath,
  });

  Map<String, dynamic> toJson({bool forLocalPersistence = false}) {
    final map = <String, dynamic>{
      'full_name': fullName,
      'professional_title': professionalTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedin': linkedin,
      'github': github,
      'instagram': instagram,
      'facebook': facebook,
      'whatsapp': whatsapp,
      'website': website,
    };
    // localPhotoPath is strictly excluded from server sync unless explicitly saving locally
    if (forLocalPersistence && localPhotoPath != null) {
      map['local_photo_path'] = localPhotoPath;
    }
    return map;
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['full_name'] as String? ?? '',
      professionalTitle: json['professional_title'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      linkedin: json['linkedin'] as String? ?? '',
      github: json['github'] as String? ?? '',
      instagram: json['instagram'] as String? ?? '',
      facebook: json['facebook'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      website: json['website'] as String? ?? '',
      localPhotoPath: json['local_photo_path'] as String? ?? json['localPhotoPath'] as String?,
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
  String? atsVerdict;
  Map<String, dynamic>? atsBreakdown;
  List<dynamic>? atsFeedback;

  CvProfileMeta({
    required this.profileIndex,
    required this.title,
    this.targetJob = '',
    this.atsScore,
    this.atsVerdict,
    this.atsBreakdown,
    this.atsFeedback,
  });

  Map<String, dynamic> toJson() => {
        'profile_index': profileIndex,
        'title': title,
        'target_job': targetJob,
        'ats_score': atsScore,
        'ats_verdict': atsVerdict,
        'ats_breakdown': atsBreakdown,
        'ats_feedback': atsFeedback,
      };

  factory CvProfileMeta.fromJson(Map<String, dynamic> json) => CvProfileMeta(
        profileIndex: json['profile_index'] as int? ?? 1,
        title: json['title'] as String? ?? 'CV ${json['profile_index'] ?? 1}',
        targetJob: json['target_job'] as String? ?? '',
        atsScore: json['ats_score'] as int?,
        atsVerdict: json['ats_verdict'] as String?,
        atsBreakdown: json['ats_breakdown'] is Map
            ? Map<String, dynamic>.from(json['ats_breakdown'] as Map)
            : null,
        atsFeedback: json['ats_feedback'] is List
            ? List<dynamic>.from(json['ats_feedback'] as List)
            : null,
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

class ProjectItem {
  String name;
  String role;
  String startDate;
  String endDate;
  bool isCurrent;
  String description;

  ProjectItem({
    this.name = '',
    this.role = '',
    this.startDate = '',
    this.endDate = '',
    this.isCurrent = false,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'start_date': startDate,
        'end_date': endDate,
        'is_current': isCurrent,
        'description': description,
      };

  factory ProjectItem.fromJson(dynamic json) {
    if (json is! Map) return ProjectItem();
    final endDateStr = json['end_date']?.toString() ?? json['endDate']?.toString() ?? '';
    final isCurr = json['is_current'] as bool? ??
        (endDateStr.toLowerCase().contains('sekarang') ||
            endDateStr.toLowerCase().contains('present'));
    return ProjectItem(
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      role: json['role'] as String? ?? json['technologies']?.toString() ?? '',
      startDate: json['start_date'] as String? ?? json['startDate'] as String? ?? '',
      endDate: endDateStr,
      isCurrent: isCurr,
      description: json['description'] as String? ?? '',
    );
  }

  String get displayPeriod {
    if (startDate.isEmpty && endDate.isEmpty && !isCurrent) return '';
    final end = endDate.isNotEmpty ? endDate : (isCurrent ? 'Sekarang' : '');
    if (startDate.isNotEmpty && end.isNotEmpty) {
      return '$startDate - $end';
    }
    if (startDate.isNotEmpty) return startDate;
    return end;
  }
}

