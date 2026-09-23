import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/core/constants/colors.dart';
import 'package:resumer/core/services/signature_service.dart';
import 'package:resumer/features/cover_letter/models/cover_letter_model.dart';
import 'package:resumer/features/cv_editor/models/cv_model.dart';
import 'package:resumer/features/pdf_engine/pdf_generator.dart';
import 'package:resumer/features/pdf_engine/templates/template_registry.dart';

void main() {
  test('CvDocument model serialization and plain text export', () {
    final doc = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: 'Lead Mobile Architect',
        email: 'alex@example.com',
        phone: '08123456789',
        location: 'Jakarta',
      ),
      summary: 'Experienced mobile engineer specializing in Flutter.',
      skills: ['Flutter', 'Dart', 'Clean Architecture'].map((s) => SkillItem(name: s)).toList(),
    );

    final json = doc.toJson();
    expect(json['personal_info']['full_name'], 'Alexander Wright');
    expect((json['skills'] as List).any((s) => s['name'] == 'Flutter'), true);

    final plainText = doc.toPlainText();
    expect(plainText, contains('ALEXANDER WRIGHT'));
    expect(plainText, contains('Lead Mobile Architect'));
    expect(plainText, contains('Flutter'));
  });

  test('PdfGenerator produces valid non-empty PDF bytes client-side', () async {
    final doc = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: 'Lead Mobile Architect',
        email: 'alex@example.com',
        phone: '08123456789',
        location: 'Jakarta',
      ),
      summary: 'Executive Summary for ATS review.',
      skills: ['Flutter', 'Dart'].map((s) => SkillItem(name: s)).toList(),
    );

    final pdfBytes = await PdfGenerator.generatePdf(doc);
    expect(pdfBytes.isNotEmpty, true);
    // PDF files start with "%PDF-" signature
    final header = String.fromCharCodes(pdfBytes.take(5));
    expect(header, '%PDF-');
  });

  test('AppColors resolves proper ATS palette based on score', () {
    expect(AppColors.getScoreColor(95), AppColors.forestPine);
    expect(AppColors.getScoreColor(70), AppColors.antiqueBronze);
    expect(AppColors.getScoreColor(45), AppColors.crimsonBordeaux);
  });

  test('CoverLetterModel parses and formats text accurately', () {
    final model = CoverLetterModel(
      companyName: 'Tech Corp',
      targetRole: 'Staff Flutter Engineer',
      salutation: 'Dear Hiring Committee,',
      paragraph1: 'I am excited to apply for Staff Flutter Engineer at Tech Corp.',
      paragraph2: 'With deep expertise in Flutter and clean architecture, I have scaled systems.',
      paragraph3: 'I look forward to discussing how my skills align with your vision.',
      signoff: 'Sincerely,',
    );

    final formatted = model.toFormattedText();
    expect(formatted, contains('Dear Hiring Committee,'));
    expect(formatted, contains('Staff Flutter Engineer at Tech Corp'));
    expect(formatted, contains('Sincerely,'));
  });

  test('SignatureService correctly persists, loads, and deletes local signatures', () async {
    SharedPreferences.setMockInitialValues({});

    final service = SignatureService.instance;
    await service.init();
    expect(service.hasSignature, false);

    // Mock 1x1 PNG bytes
    final mockPngBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    await service.saveSignature(mockPngBytes);
    expect(service.hasSignature, true);
    expect(service.cachedSignatureBytes, isNotNull);
    expect(service.cachedSignatureBytes!.length, mockPngBytes.length);

    // Verify retrieval after fresh instance reload
    final retrieved = await service.getSignature();
    expect(retrieved, isNotNull);
    expect(retrieved, equals(mockPngBytes));

    // Delete signature
    await service.deleteSignature();
    expect(service.hasSignature, false);
    expect(service.cachedSignatureBytes, isNull);
  });

  test('PdfGenerator generates Cover Letter PDF with embedded digital signature', () async {
    final doc = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: 'Lead Mobile Architect',
        email: 'alex@example.com',
        phone: '08123456789',
        location: 'Jakarta',
      ),
      summary: 'Executive Summary.',
      skills: ['Flutter'].map((s) => SkillItem(name: s)).toList(),
    );

    final letter = CoverLetterModel(
      companyName: 'Alpha Corp',
      targetRole: 'Principal Mobile Architect',
      salutation: 'Dear Hiring Team,',
      paragraph1: 'Opening test paragraph.',
      paragraph2: 'Body test paragraph.',
      paragraph3: 'Closing test paragraph.',
      signoff: 'Sincerely,',
    );

    // Mock 1x1 PNG bytes
    final mockSignature = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    // Test without signature
    final pdfWithoutSig = await PdfGenerator.generateCoverLetterPdf(letter, doc);
    expect(pdfWithoutSig.isNotEmpty, true);
    expect(String.fromCharCodes(pdfWithoutSig.take(5)), '%PDF-');

    // Test with signature
    final pdfWithSig = await PdfGenerator.generateCoverLetterPdf(letter, doc, signatureBytes: mockSignature);
    expect(pdfWithSig.isNotEmpty, true);
    expect(String.fromCharCodes(pdfWithSig.take(5)), '%PDF-');
  });

  test('ProjectItem serialization and CvDocument projects plain text export', () {
    final project = ProjectItem(
      name: 'Resumer AI Mobile Platform',
      role: 'Lead Architect',
      startDate: 'Januari 2024',
      endDate: 'Present',
      isCurrent: true,
      description: 'Engineered ATS CV maker and client-side PDF rendering system.',
    );

    final pJson = project.toJson();
    expect(pJson['name'], 'Resumer AI Mobile Platform');
    expect(pJson['role'], 'Lead Architect');
    expect(pJson['is_current'], true);

    final pRestored = ProjectItem.fromJson(pJson);
    expect(pRestored.name, 'Resumer AI Mobile Platform');
    expect(pRestored.displayPeriod, 'Januari 2024 - Present');

    final doc = CvDocument(
      personalInfo: PersonalInfo(fullName: 'Alexander Wright'),
      projects: [project],
      showProjects: true,
    );

    final plainText = doc.toPlainText();
    expect(plainText, contains('PROJECTS & PORTFOLIO'));
    expect(plainText, contains('Resumer AI Mobile Platform | Lead Architect'));
    expect(plainText, contains('Engineered ATS CV maker'));
  });

  test('PdfGenerator renders projects across templates successfully', () async {
    final doc = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: 'Lead Mobile Architect',
        email: 'alex@example.com',
        phone: '08123456789',
        location: 'Jakarta',
      ),
      summary: 'Executive Summary.',
      skills: ['Flutter', 'Dart'].map((s) => SkillItem(name: s)).toList(),
      projects: [
        ProjectItem(
          name: 'Enterprise Cloud Portal',
          role: 'Fullstack Lead',
          startDate: 'Maret 2023',
          endDate: 'Desember 2023',
          isCurrent: false,
          description: 'Architected scalable multi-tenant services.',
        ),
      ],
      showProjects: true,
    );

    for (final template in TemplateRegistry.all) {
      doc.templateId = template.id;
      final bytes = await PdfGenerator.generatePdf(doc);
      expect(bytes.isNotEmpty, true);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    }
  });
}

