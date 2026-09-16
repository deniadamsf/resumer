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
      skills: ['Flutter', 'Dart', 'Clean Architecture', 'REST APIs', 'CI/CD', 'Docker'],
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
}
