import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../cv_editor/models/cv_model.dart';
import '../cover_letter/models/cover_letter_model.dart';

class PdfGenerator {
  /// Generate 100% Client-Side ATS Compliant PDF Document
  static Future<Uint8List> generatePdf(CvDocument cv) async {
    final pdf = pw.Document();

    // Resolve Accent Color
    PdfColor accentColor = PdfColor.fromHex(cv.accentColor);

    // Read local photo bytes if Asian ATS template and photo exists
    Uint8List? photoBytes;
    if (cv.templateId == 'asian_ats' && cv.personalInfo.localPhotoPath != null) {
      final file = File(cv.personalInfo.localPhotoPath!);
      if (await file.exists()) {
        photoBytes = await file.readAsBytes();
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            _buildHeader(cv, photoBytes, accentColor),
            pw.SizedBox(height: 12),
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              _buildSectionTitle('EXECUTIVE SUMMARY', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                cv.summary,
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),
            ],
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildSectionTitle('WORK EXPERIENCE', accentColor),
              pw.SizedBox(height: 4),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
              pw.SizedBox(height: 8),
            ],
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              _buildSectionTitle('EDUCATION', accentColor),
              pw.SizedBox(height: 4),
              ...cv.educations.map((edu) => _buildEducationItem(edu)),
              pw.SizedBox(height: 8),
            ],
            if (cv.showSkills && cv.skills.isNotEmpty) ...[
              _buildSectionTitle('CORE COMPETENCIES & SKILLS', accentColor),
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 6,
                runSpacing: 4,
                children: cv.skills
                    .map((skill) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.circular(3),
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                          ),
                          child: pw.Text(
                            skill,
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                          ),
                        ))
                    .toList(),
              ),
              pw.SizedBox(height: 12),
            ],
            if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
              _buildSectionTitle('CERTIFICATIONS', accentColor),
              pw.SizedBox(height: 4),
              ...cv.certifications.map(
                (cert) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                      pw.Expanded(
                        child: pw.Text(cert, style: const pw.TextStyle(fontSize: 9.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(CvDocument cv, Uint8List? photoBytes, PdfColor accentColor) {
    final info = cv.personalInfo;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                info.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 0.5,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                info.professionalTitle,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '${info.email}  |  ${info.phone}  |  ${info.location}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              if (info.linkedin.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  info.linkedin,
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.blue800),
                ),
              ],
            ],
          ),
        ),
        // Isolated Photo slot for Asian ATS Standard
        if (photoBytes != null)
          pw.Container(
            width: 65,
            height: 80,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 1),
              borderRadius: pw.BorderRadius.circular(4),
              image: pw.DecorationImage(
                image: pw.MemoryImage(photoBytes),
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.5,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(
          height: 1,
          color: accentColor,
        ),
      ],
    );
  }

  static pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.position,
                style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${exp.startDate} - ${exp.endDate}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Text(
            exp.company,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 3),
          ...exp.highlights.map(
            (hl) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                  pw.Expanded(
                    child: pw.Text(
                      hl,
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildEducationItem(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${edu.degree} in ${edu.fieldOfStudy}',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                edu.institution,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                edu.graduationYear,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              if (edu.gpa.isNotEmpty)
                pw.Text(
                  'GPA: ${edu.gpa}',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Generate 100% Client-Side Formal Executive Cover Letter PDF
  static Future<Uint8List> generateCoverLetterPdf(
    CoverLetterModel letter,
    CvDocument cv, {
    Uint8List? signatureBytes,
  }) async {
    final pdf = pw.Document();
    final accentColor = PdfColor.fromHex(cv.accentColor);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          final signoffText = letter.signoff.split('\n').first.trim();
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Candidate Header
              pw.Text(
                cv.personalInfo.fullName.toUpperCase(),
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
                  cv.personalInfo.professionalTitle,
                  style: const pw.TextStyle(fontSize: 10.5, color: PdfColors.grey700),
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  if (cv.personalInfo.email.isNotEmpty)
                    pw.Text(cv.personalInfo.email, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  if (cv.personalInfo.phone.isNotEmpty) ...[
                    pw.Text('  |  ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
                    pw.Text(cv.personalInfo.phone, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                  if (cv.personalInfo.location.isNotEmpty) ...[
                    pw.Text('  |  ', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
                    pw.Text(cv.personalInfo.location, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, color: accentColor),
              pw.SizedBox(height: 16),

              // Recipient & Role Details
              pw.Text('To:', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.Text('Hiring Committee & Recruitment Team', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              pw.Text(letter.companyName, style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('RE: Application for ${letter.targetRole}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accentColor)),
              pw.SizedBox(height: 16),

              // Salutation
              pw.Text(
                letter.salutation,
                style: const pw.TextStyle(fontSize: 10.5, color: PdfColors.black),
              ),
              pw.SizedBox(height: 12),

              // Paragraph 1
              pw.Text(
                letter.paragraph1,
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),

              // Paragraph 2
              pw.Text(
                letter.paragraph2,
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),

              // Paragraph 3
              pw.Text(
                letter.paragraph3,
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
                cv.personalInfo.fullName,
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

