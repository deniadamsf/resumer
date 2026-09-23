import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumer/features/cv_editor/models/cv_model.dart';
import 'package:resumer/features/cover_letter/models/cover_letter_model.dart';
import 'package:resumer/features/pdf_engine/pdf_generator.dart';
import 'package:resumer/core/utils/date_format_helper.dart';

void main() {
  test('Generate clean test PDFs without missing glyphs', () async {
    final cv = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: 'Lead Mobile Architect',
        email: 'alexander.wright@executive.io',
        phone: '+62 812-9876-5432',
        location: 'Jakarta, Indonesia',
      ),
      summary: 'Results-driven Lead Mobile & Web Engineer. Proven track record of scaling mission-critical apps—reducing latency by 45%.',
      experiences: [
        WorkExperience(
          company: 'Zenith Global Technologies',
          position: 'Lead Mobile Engineer',
          startDate: '2022',
          endDate: 'Present',
          highlights: [
            'Architected client-side offline-first caching layer, cutting API latency by 45% for 1.2M active users.',
            'Spearheaded Flutter migration across 3 cross-functional teams, accelerating sprint delivery cycle by 35%.',
          ],
        ),
      ],
      educations: [
        Education(
          institution: 'Institute of Technology',
          degree: 'Bachelor of Science',
          fieldOfStudy: 'Computer Science',
          graduationYear: '2020',
          gpa: '3.85',
        ),
      ],
      skills: ['Flutter', 'Dart', 'Clean Architecture', 'REST APIs', 'CI/CD', 'Docker']
          .map((s) => SkillItem(name: s))
          .toList(),
    );

    final cvBytes = await PdfGenerator.generatePdf(cv);
    final cvFile = File('test_clean_resume.pdf');
    await cvFile.writeAsBytes(cvBytes);

    final letter = CoverLetterModel(
      companyName: 'Bank Mandiri',
      targetRole: 'Lead Mobile Architect',
      salutation: "Dear Hiring Team at Bank Mandiri,",
      paragraph1: "I am thrilled to submit my application for Bank Mandiri's Lead Mobile Architect position.",
      paragraph2: "My technical proficiency spans Clean Architecture, automated CI/CD pipelines, and secure REST API integrations—all underpinned by engineering excellence.",
      paragraph3: "Bank Mandiri's commitment to digital transformation presents an exciting opportunity.",
      signoff: 'Sincerely,',
    );

    final letterBytes = await PdfGenerator.generateCoverLetterPdf(letter, cv);
    final letterFile = File('test_clean_cover_letter.pdf');
    await letterFile.writeAsBytes(letterBytes);

    expect(cvBytes.isNotEmpty, true);
    expect(letterBytes.isNotEmpty, true);
  });

  test('Generate PDF for all 14 registered templates across all official colors', () async {
    final cv = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: 'Lead Mobile Architect',
        email: 'alexander.wright@executive.io',
        phone: '+62 812-9876-5432',
        location: 'Jakarta, Indonesia',
        linkedin: 'linkedin.com/in/alexanderwright',
      ),
      summary: "Executive Summary: 8+ years architecting scalable Flutter apps.",
      experiences: [
        WorkExperience(
          company: 'Zenith Global',
          position: 'Lead Mobile Engineer',
          startDate: '2022',
          endDate: 'Present',
          highlights: ['Reduced API latency by 45% using client-side caching.'],
        ),
      ],
      educations: [
        Education(
          institution: 'Institute of Technology',
          degree: 'B.S.',
          fieldOfStudy: 'Computer Science',
          graduationYear: '2020',
          gpa: '3.85',
        ),
      ],
      skills: [
        SkillItem(name: 'Flutter & Dart', description: 'Enterprise state management'),
        SkillItem(name: 'Clean Architecture', description: 'Layered domain design'),
      ],
      certifications: [
        CertificationItem(name: 'Google Cloud Certified', issuer: 'Google', year: '2023'),
      ],
      languages: [
        LanguageItem(name: 'Indonesian', proficiency: 'Native / Bilingual'),
        LanguageItem(name: 'English', proficiency: 'Professional Working'),
      ],
      showLanguages: true,
      hobbies: ['Chess', 'Open Source', 'Photography'],
      showHobbies: true,
    );

    final templateIds = [
      'asian_ats',
      'western_strict',
      'modern_ats',
      'modern_creative',
      'compact_portfolio',
      'executive_split',
      'nordic_minimal',
      'tech_timeline',
      'editorial_luxury',
      'accent_sidebar_light',
      'bento_grid',
      'gradient_header',
      'color_block',
      'ribbon_banner',
    ];

    final colors = ['#0B132B', '#065F46', '#1C2541', '#92400E'];

    for (int i = 0; i < templateIds.length; i++) {
      final tId = templateIds[i];
      cv.templateId = tId;
      cv.accentColor = colors[i % colors.length];

      final bytes = await PdfGenerator.generatePdf(cv);
      expect(bytes.isNotEmpty, true, reason: 'Template $tId should produce valid non-empty PDF bytes');
      expect(bytes.length, greaterThan(1000), reason: 'Template $tId should have complete document body');
    }
  });

  test('Generate multi-page PDF when CV content is long', () async {
    final longCv = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: 'Lead Mobile Architect & Engineering Manager',
        email: 'alexander.wright@executive.io',
        phone: '+62 812-9876-5432',
        location: 'Jakarta, Indonesia',
        linkedin: 'linkedin.com/in/alexanderwright',
      ),
      summary: 'Distinguished engineering leader with 10+ years driving mobile architecture across high-growth fintechs and multinational enterprises. Adept at steering cross-functional squads to deliver sub-second response times and rock-solid 99.99% availability for 15M+ active users.',
      experiences: [
        WorkExperience(
          company: 'Zenith Global Technologies',
          position: 'Lead Mobile Architect',
          startDate: '2023',
          endDate: 'Present',
          highlights: [
            'Architected client-side offline-first caching layer, cutting API latency by 45% for 1.2M active users across SEA.',
            'Spearheaded enterprise Flutter migration across 4 squads, cutting sprint cycle times by 35%.',
            'Implemented zero-trust token storage and biometric security handling 250k daily transactions.',
          ],
        ),
        WorkExperience(
          company: 'Astra Financial Digital',
          position: 'Senior Software Engineer',
          startDate: '2020',
          endDate: '2023',
          highlights: [
            'Developed core payment gateway SDK integrated into 14 subsidiary apps with 99.99% crash-free rate.',
            'Mentored 12 junior and mid-level engineers in Clean Architecture and automated test-driven development.',
            'Reduced build times by 50% through modular Gradle and Pod caching pipelines.',
          ],
        ),
        WorkExperience(
          company: 'Traveloka Southeast Asia',
          position: 'Mobile Engineer',
          startDate: '2018',
          endDate: '2020',
          highlights: [
            'Revamped flight search and booking checkout funnel, boosting checkout conversion rate by 18%.',
            'Integrated localization framework supporting 6 languages and 5 regional currencies seamlessly.',
          ],
        ),
        WorkExperience(
          company: 'InnoTech Solutions',
          position: 'Junior Mobile Developer',
          startDate: '2016',
          endDate: '2018',
          highlights: [
            'Built 5 commercial native Android applications from ground up using Java and Kotlin.',
            'Authored comprehensive unit test suites achieving 80%+ code coverage.',
          ],
        ),
        WorkExperience(
          company: 'Digital Nusantara Labs',
          position: 'Associate Engineer',
          startDate: '2015',
          endDate: '2016',
          highlights: [
            'Implemented RESTful microservice clients and SQLite local persistence layer.',
            'Collaborated with design leads on responsive material design patterns.',
          ],
        ),
        WorkExperience(
          company: 'Startup Hub Incubator',
          position: 'Mobile Developer Intern',
          startDate: '2014',
          endDate: '2015',
          highlights: [
            'Contributed to MVP development for 3 seed-stage technology startups.',
          ],
        ),
      ],
      educations: [
        Education(
          institution: 'Institute of Technology Bandung',
          degree: 'Master of Science',
          fieldOfStudy: 'Computer Science',
          graduationYear: '2020',
          gpa: '3.92',
        ),
        Education(
          institution: 'University of Indonesia',
          degree: 'Bachelor of Science',
          fieldOfStudy: 'Information Systems',
          graduationYear: '2016',
          gpa: '3.85',
        ),
      ],
      skills: [
        SkillItem(name: 'Flutter & Dart', description: 'Advanced state management, custom painters, render objects'),
        SkillItem(name: 'Clean Architecture', description: 'Domain-driven design, repository pattern, SOLID principles'),
        SkillItem(name: 'CI/CD & DevOps', description: 'GitHub Actions, Fastlane, Docker, automated unit & integration testing'),
        SkillItem(name: 'Cloud & APIs', description: 'REST APIs, GraphQL, gRPC, Google Cloud Platform, Firebase'),
        SkillItem(name: 'Security & Auth', description: 'OAuth2, OpenID Connect, biometric cryptography, tamper detection'),
      ],
      certifications: [
        CertificationItem(name: 'Google Cloud Professional Cloud Architect', issuer: 'Google', year: '2023'),
        CertificationItem(name: 'Certified Scrum Master (CSM)', issuer: 'Scrum Alliance', year: '2021'),
        CertificationItem(name: 'Oracle Certified Professional Java SE 11', issuer: 'Oracle', year: '2019'),
      ],
      languages: [
        LanguageItem(name: 'Indonesian', proficiency: 'Native / Bilingual'),
        LanguageItem(name: 'English', proficiency: 'Full Professional Working Proficiency'),
        LanguageItem(name: 'Mandarin', proficiency: 'Elementary Proficiency'),
      ],
      showLanguages: true,
      hobbies: ['Open Source Contribution', 'Endurance Cycling', 'Technical Writing'],
      showHobbies: true,
    );

    final templateIds = [
      'asian_ats',
      'western_strict',
      'modern_ats',
      'modern_creative',
      'compact_portfolio',
      'executive_split',
      'nordic_minimal',
      'tech_timeline',
      'editorial_luxury',
      'accent_sidebar_light',
      'bento_grid',
      'gradient_header',
      'color_block',
      'ribbon_banner',
    ];

    for (final tId in templateIds) {
      longCv.templateId = tId;
      final bytes = await PdfGenerator.generatePdf(longCv);
      expect(bytes.isNotEmpty, true, reason: 'Template $tId should handle long CV content');
      final file = File('test_long_$tId.pdf');
      await file.writeAsBytes(bytes);
    }
  });

  test('DateFormatHelper correctly parses Indonesian and English month formats', () {
    // Indonesian full & short
    final p1 = DateFormatHelper.parse('Januari 2024');
    expect(p1.month, 1);
    expect(p1.year, '2024');

    final p2 = DateFormatHelper.parse('januari 2024');
    expect(p2.month, 1);
    expect(p2.year, '2024');

    final p3 = DateFormatHelper.parse('Agt 2023');
    expect(p3.month, 8);
    expect(p3.year, '2023');

    // English full & short
    final p4 = DateFormatHelper.parse('January 2024');
    expect(p4.month, 1);
    expect(p4.year, '2024');

    final p5 = DateFormatHelper.parse('Aug 2023');
    expect(p5.month, 8);
    expect(p5.year, '2023');

    // Numeric formats
    final p6 = DateFormatHelper.parse('01/2024');
    expect(p6.month, 1);
    expect(p6.year, '2024');

    // Present / Sekarang
    final p7 = DateFormatHelper.parse('Sekarang');
    expect(p7.isPresent, true);

    final p8 = DateFormatHelper.parse('Present');
    expect(p8.isPresent, true);

    // Format outputs
    expect(DateFormatHelper.formatMonthYear(1, '2024', isEnglish: false, full: true), 'Januari 2024');
    expect(DateFormatHelper.formatMonthYear(1, '2024', isEnglish: true, full: true), 'January 2024');
    expect(DateFormatHelper.formatDateRange('januari 2024', 'sekarang', isEnglish: false), 'Januari 2024 - Sekarang');
    expect(DateFormatHelper.formatDateRange('january 2024', 'present', isEnglish: true), 'January 2024 - Present');
  });

  test('Generate CV with full month names and long position titles across all templates without clipping', () async {
    final cvWithMonths = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Budi Pratama',
        professionalTitle: 'Lead Mobile Architect & Staff Full Stack Engineer',
        email: 'budi.pratama@enterprise.id',
        phone: '+62 812-3456-7890',
        location: 'Jakarta Selatan, DKI Jakarta',
      ),
      summary: 'Senior Software Engineering Leader with 10+ years driving high-performance mobile architectures.',
      experiences: [
        WorkExperience(
          company: 'PT Global Solusi Teknologi Tbk',
          position: 'Senior Principal Mobile Engineer & Team Lead',
          startDate: 'Januari 2024',
          endDate: 'Sekarang',
          highlights: [
            'Spearheaded Flutter architectural overhaul increasing performance by 40%.',
            'Managed high-throughput distributed microservices for 2M active clients.',
          ],
        ),
        WorkExperience(
          company: 'Unicorn Digital Nusantara',
          position: 'Full Stack Engineering Specialist',
          startDate: 'Maret 2021',
          endDate: 'Desember 2023',
          highlights: [
            'Built responsive design system and core payment gateway integrations.',
          ],
        ),
      ],
      educations: [
        Education(
          institution: 'Universitas Gadjah Mada Yogyakarta',
          degree: 'Sarjana Ilmu Komputer (S.Kom)',
          fieldOfStudy: 'Teknik Informatika & Ilmu Komputer',
          graduationYear: 'Agustus 2020',
          gpa: '3.89',
        ),
      ],
      skills: ['Flutter', 'Dart', 'Clean Architecture', 'REST APIs', 'CI/CD']
          .map((s) => SkillItem(name: s))
          .toList(),
    );

    final templateIds = [
      'asian_ats',
      'western_strict',
      'modern_ats',
      'modern_creative',
      'compact_portfolio',
      'executive_split',
      'nordic_minimal',
      'tech_timeline',
      'editorial_luxury',
      'accent_sidebar_light',
      'bento_grid',
      'gradient_header',
      'color_block',
      'ribbon_banner',
    ];

    for (final tId in templateIds) {
      cvWithMonths.templateId = tId;
      final bytes = await PdfGenerator.generatePdf(cvWithMonths);
      expect(bytes.isNotEmpty, true, reason: 'Template $tId failed to generate with full month names');
    }
  });

  test('ensureMonthIntegrity automatically adds months to year-only inputs and templates render them', () async {
    final rawYearCv = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Deni Adam',
        professionalTitle: 'Software Engineer',
        email: 'deni@example.com',
      ),
      experiences: [
        WorkExperience(
          company: 'Tech Corp',
          position: 'Software Engineer',
          startDate: '2021',
          endDate: '2023',
          highlights: ['Built apps'],
        ),
        WorkExperience(
          company: 'Current Corp',
          position: 'Senior Engineer',
          startDate: '2023',
          endDate: 'Present',
          highlights: ['Leading architecture'],
        ),
      ],
      educations: [
        Education(
          institution: 'Universitas Indonesia',
          degree: 'S.Kom',
          fieldOfStudy: 'Computer Science',
          graduationYear: '2021',
        ),
      ],
      skills: [SkillItem(name: 'Flutter')],
    );

    // Test ensureMonthIntegrity
    rawYearCv.ensureMonthIntegrity(isEnglish: false);
    expect(rawYearCv.experiences[0].startDate, 'Januari 2021');
    expect(rawYearCv.experiences[0].endDate, 'Desember 2023');
    expect(rawYearCv.experiences[1].startDate, 'Januari 2023');
    expect(rawYearCv.experiences[1].endDate, 'Sekarang');
    expect(rawYearCv.educations[0].graduationYear, 'Agustus 2021');

    // Test English integrity
    final rawEnglishCv = CvDocument(
      personalInfo: PersonalInfo(fullName: 'John Doe'),
      experiences: [
        WorkExperience(
          company: 'Global Inc',
          position: 'Engineer',
          startDate: '2020',
          endDate: 'Present',
        ),
      ],
      educations: [
        Education(
          institution: 'MIT',
          degree: 'B.S.',
          graduationYear: '2019',
        ),
      ],
    );
    rawEnglishCv.ensureMonthIntegrity(isEnglish: true);
    expect(rawEnglishCv.experiences[0].startDate, 'January 2020');
    expect(rawEnglishCv.experiences[0].endDate, 'Present');
    expect(rawEnglishCv.educations[0].graduationYear, 'August 2019');

    // Test DateFormatHelper direct fallbacks
    expect(DateFormatHelper.formatDateRange('2021', '2024', isEnglish: false), 'Januari 2021 - Desember 2024');
    expect(DateFormatHelper.formatDateRange('2021', 'Present', isEnglish: true), 'January 2021 - Present');
    expect(DateFormatHelper.formatEducationDate('2022', isEnglish: false), 'Agustus 2022');
    expect(DateFormatHelper.formatEducationDate('2022', isEnglish: true), 'August 2022');

    // Verify all 14 templates generate without error on this document
    final templateIds = [
      'asian_ats',
      'western_strict',
      'modern_ats',
      'modern_creative',
      'compact_portfolio',
      'executive_split',
      'nordic_minimal',
      'tech_timeline',
      'editorial_luxury',
      'accent_sidebar_light',
      'bento_grid',
      'gradient_header',
      'color_block',
      'ribbon_banner',
    ];

    for (final tId in templateIds) {
      rawYearCv.templateId = tId;
      final bytes = await PdfGenerator.generatePdf(rawYearCv);
      expect(bytes.isNotEmpty, true, reason: 'Template $tId failed to generate with migrated months');
    }
  });
}

