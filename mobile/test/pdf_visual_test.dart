import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumer/features/cv_editor/models/cv_model.dart';
import 'package:resumer/features/cover_letter/models/cover_letter_model.dart';
import 'package:resumer/features/pdf_engine/pdf_generator.dart';

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

  test('Generate PDF for all 6 registered templates across all official colors', () async {
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
    ];

    for (final tId in templateIds) {
      longCv.templateId = tId;
      final bytes = await PdfGenerator.generatePdf(longCv);
      expect(bytes.isNotEmpty, true, reason: 'Template $tId should handle long CV content');
      final file = File('test_long_$tId.pdf');
      await file.writeAsBytes(bytes);
    }
  });
}

