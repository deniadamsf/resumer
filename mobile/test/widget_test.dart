import 'package:flutter_test/flutter_test.dart';
import 'package:resumer/core/constants/colors.dart';
import 'package:resumer/features/cv_editor/models/cv_model.dart';
import 'package:resumer/features/pdf_engine/pdf_generator.dart';

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
      skills: ['Flutter', 'Dart', 'Clean Architecture'],
    );

    final json = doc.toJson();
    expect(json['personal_info']['full_name'], 'Alexander Wright');
    expect(json['skills'], contains('Flutter'));

    final plainText = doc.toPlainText();
    expect(plainText, contains('ALEXANDER WRIGHT'));
    expect(plainText, contains('Lead Mobile Architect'));
    expect(plainText, contains('Flutter • Dart • Clean Architecture'));
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
      skills: ['Flutter', 'Dart'],
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
}
