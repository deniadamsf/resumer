import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../cv_editor/models/cv_model.dart';
import '../cover_letter/models/cover_letter_model.dart';
import 'templates/template_registry.dart';
import 'utils/pdf_text_sanitizer.dart';

/// Clean Orchestrator for 100% Client-Side PDF Generation.
/// Adheres strictly to GEMINI.md Section 7 & K.2 (Separation of Concerns).
/// Delegates template rendering to isolated template modules via [TemplateRegistry].
class PdfGenerator {
  /// Generate 100% Client-Side PDF Document using selected template
  static Future<Uint8List> generatePdf(CvDocument cv) async {
    final template = TemplateRegistry.getTemplate(cv.templateId);

    // Read local photo bytes if the chosen template supports photos and a path is set
    Uint8List? photoBytes;
    if (template.supportsPhoto && cv.personalInfo.localPhotoPath != null) {
      final file = File(cv.personalInfo.localPhotoPath!);
      if (await file.exists()) {
        photoBytes = await file.readAsBytes();
      }
    }

    return template.generate(cv, photoBytes: photoBytes);
  }

  /// Generate 100% Client-Side Formal Executive Cover Letter PDF
  static Future<Uint8List> generateCoverLetterPdf(
    CoverLetterModel letter,
    CvDocument cv, {
    Uint8List? signatureBytes,
  }) async {
    final pdf = pw.Document();
    final template = TemplateRegistry.getTemplate(cv.templateId);
    final accentColor = template.resolveAccentColor(cv.accentColor);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          final signoffText = PdfTextSanitizer.clean(letter.signoff.split('\n').first);
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Candidate Header
              pw.Text(
                PdfTextSanitizer.clean(cv.personalInfo.fullName).toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1.2,
                ),
              ),
              if (cv.personalInfo.professionalTitle.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  PdfTextSanitizer.clean(cv.personalInfo.professionalTitle),
                  style: const pw.TextStyle(fontSize: 10.5, color: PdfColors.grey700),
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  if (cv.personalInfo.email.isNotEmpty)
                    pw.Text(PdfTextSanitizer.clean(cv.personalInfo.email), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  if (cv.personalInfo.phone.isNotEmpty) ...[
                    pw.Text('  |  ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
                    pw.Text(PdfTextSanitizer.clean(cv.personalInfo.phone), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                  if (cv.personalInfo.location.isNotEmpty) ...[
                    pw.Text('  |  ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
                    pw.Text(PdfTextSanitizer.clean(cv.personalInfo.location), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, color: accentColor),
              pw.SizedBox(height: 16),

              // Recipient & Role Details
              pw.Text('To:', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.Text('Hiring Committee & Recruitment Team', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              pw.Text(PdfTextSanitizer.clean(letter.companyName), style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('RE: Application for ${PdfTextSanitizer.clean(letter.targetRole)}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accentColor)),
              pw.SizedBox(height: 16),

              // Salutation
              pw.Text(
                PdfTextSanitizer.clean(letter.salutation),
                style: const pw.TextStyle(fontSize: 10.5, color: PdfColors.black),
              ),
              pw.SizedBox(height: 12),

              // Paragraph 1
              pw.Text(
                PdfTextSanitizer.clean(letter.paragraph1),
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),

              // Paragraph 2
              pw.Text(
                PdfTextSanitizer.clean(letter.paragraph2),
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),

              // Paragraph 3
              pw.Text(
                PdfTextSanitizer.clean(letter.paragraph3),
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 18),

              // Signoff & Signature
              pw.Text(
                signoffText.isNotEmpty ? signoffText : 'Hormat saya,',
                style: const pw.TextStyle(fontSize: 10.5, color: PdfColors.black),
              ),
              pw.SizedBox(height: 6),
              if (signatureBytes != null && signatureBytes.isNotEmpty) ...[
                pw.Container(
                  height: 44,
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Image(
                    pw.MemoryImage(signatureBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(height: 4),
              ] else ...[
                pw.SizedBox(height: 38),
              ],
              pw.Text(
                PdfTextSanitizer.clean(cv.personalInfo.fullName),
                style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
