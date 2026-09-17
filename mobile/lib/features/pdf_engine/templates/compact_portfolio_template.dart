import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Compact Slate Portfolio Template
/// High-contrast colored hero header block with structured competency cards.
/// Designed for developers, engineering leads, designers, and independent consultants.
class CompactPortfolioTemplate extends CvTemplate {
  @override
  String get id => 'compact_portfolio';

  @override
  String get nameKey => 'form.template_compact_portfolio';

  @override
  String get descKey => 'form.template_compact_portfolio_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'Portofolio / Proyek';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final cardBg = PdfColors.grey100;
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Hero Header Card
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          PdfTextSanitizer.clean(info.fullName).toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          PdfTextSanitizer.clean(info.professionalTitle),
                          style: const pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey200,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (info.email.isNotEmpty)
                              pw.Text(PdfTextSanitizer.clean(info.email), style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.white)),
                            if (info.phone.isNotEmpty)
                              pw.Text(PdfTextSanitizer.clean(info.phone), style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.white)),
                            if (info.location.isNotEmpty)
                              pw.Text(PdfTextSanitizer.clean(info.location), style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey300)),
                            if (info.linkedin.isNotEmpty)
                              pw.Text(PdfTextSanitizer.clean(info.linkedin), style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey300)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (photoBytes != null) ...[
                    pw.SizedBox(width: 14),
                    pw.Container(
                      width: 64,
                      height: 76,
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColors.white, width: 2),
                        image: pw.DecorationImage(
                          image: pw.MemoryImage(photoBytes),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Executive Summary
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              _buildSectionBar('EXECUTIVE SUMMARY', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                PdfTextSanitizer.clean(cv.summary),
                style: const pw.TextStyle(fontSize: 9.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),
            ],

            // Work Experience
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildSectionBar('WORK EXPERIENCE', accentColor),
              pw.SizedBox(height: 4),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
              pw.SizedBox(height: 8),
            ],

            // Education & Certifications (Grid-like card presentation)
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              _buildSectionBar('EDUCATION', accentColor),
              pw.SizedBox(height: 4),
              ...cv.educations.map((edu) => _buildEducationItem(edu, cardBg)),
              pw.SizedBox(height: 8),
            ],

            // Skills & Competencies (Visual Grid Cards)
            if (cv.showSkills && cv.skills.isNotEmpty) ...[
              _buildSectionBar('KEY COMPETENCIES & EXPERTISE', accentColor),
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cv.skills.map((skill) {
                  final cleanName = PdfTextSanitizer.clean(skill.name);
                  final hasDesc = skill.description.trim().isNotEmpty;
                  final cleanDesc = PdfTextSanitizer.clean(skill.description);
                  return pw.Container(
                    width: 245,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: cardBg,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          cleanName,
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor),
                        ),
                        if (hasDesc) ...[
                          pw.SizedBox(height: 1),
                          pw.Text(
                            cleanDesc,
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 8),
            ],

            // Certifications
            if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
              _buildSectionBar('CERTIFICATIONS & LICENSES', accentColor),
              pw.SizedBox(height: 4),
              ...cv.certifications.map((c) {
                final title = PdfTextSanitizer.clean(c.displayTitle);
                final hasDesc = c.description.trim().isNotEmpty;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2.5),
                  child: pw.Row(
                    children: [
                      PdfTextSanitizer.buildBulletDot(accentColor),
                      pw.Expanded(
                        child: pw.Text(
                          hasDesc ? '$title - ${PdfTextSanitizer.clean(c.description)}' : title,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 8),
            ],

            // Languages & Interests
            if ((cv.showLanguages && cv.languages.isNotEmpty) || (cv.showHobbies && cv.hobbies.isNotEmpty)) ...[
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (cv.showLanguages && cv.languages.isNotEmpty)
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildSectionBar('LANGUAGES', accentColor),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            cv.languages
                                .map((l) => '${PdfTextSanitizer.clean(l.name)} (${PdfTextSanitizer.clean(l.proficiency)})')
                                .join('\n'),
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                  if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildSectionBar('INTERESTS', accentColor),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            cv.hobbies.map((h) => PdfTextSanitizer.clean(h)).join('   |   '),
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSectionBar(String title, PdfColor accentColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: tintColor(accentColor, 0.10),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 9.5,
          fontWeight: pw.FontWeight.bold,
          color: accentColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(exp.position),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${PdfTextSanitizer.clean(exp.startDate)} - ${PdfTextSanitizer.clean(exp.endDate)}',
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Text(
            PdfTextSanitizer.clean(exp.company),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
          ),
          pw.SizedBox(height: 2),
          ...exp.highlights.map(
            (hl) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PdfTextSanitizer.buildBulletDot(accentColor, size: 3.5),
                  pw.Expanded(
                    child: pw.Text(
                      PdfTextSanitizer.clean(hl),
                      style: const pw.TextStyle(fontSize: 9),
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

  pw.Widget _buildEducationItem(Education edu, PdfColor cardBg) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: pw.BoxDecoration(
        color: cardBg,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                PdfTextSanitizer.clean(edu.institution),
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(edu.graduationYear),
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
              ),
              if (edu.gpa.trim().isNotEmpty)
                pw.Text(
                  'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
