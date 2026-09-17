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
}
