import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Modern Executive ATS Template
/// Single-column contemporary layout with elegant accent geometry,
/// clean metadata badges, and high information density.
/// ATS parser friendly (Skor: 90-98).
class ModernAtsTemplate extends CvTemplate {
  @override
  String get id => 'modern_ats';

  @override
  String get nameKey => 'form.template_modern_ats';

  @override
  String get descKey => 'form.template_modern_ats_desc';

  @override
  bool get isAtsFriendly => true;

  @override
  String get atsScoreRange => 'Skor: 90-98';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final subtleTint = PdfColor(accentColor.red, accentColor.green, accentColor.blue, 0.08);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            // Top accent bar
            pw.Container(
              height: 4,
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(height: 12),

            // Header with candidate details
            _buildHeader(cv, photoBytes, accentColor, subtleTint),
            pw.SizedBox(height: 14),

            // Executive Summary
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              _buildModernSectionTitle('EXECUTIVE SUMMARY', accentColor),
              pw.SizedBox(height: 5),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: subtleTint,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  PdfTextSanitizer.clean(cv.summary),
                  style: const pw.TextStyle(fontSize: 9.5),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // Experience
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildModernSectionTitle('WORK EXPERIENCE', accentColor),
              pw.SizedBox(height: 6),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor, subtleTint)),
              pw.SizedBox(height: 6),
            ],

            // Education
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              _buildModernSectionTitle('EDUCATION', accentColor),
              pw.SizedBox(height: 6),
              ...cv.educations.map((edu) => _buildEducationItem(edu, accentColor)),
              pw.SizedBox(height: 8),
            ],

            // Skills
            if (cv.showSkills && cv.skills.isNotEmpty) ...[
              _buildModernSectionTitle('CORE COMPETENCIES & TECHNICAL SKILLS', accentColor),
              pw.SizedBox(height: 6),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cv.skills.map((skill) {
                  final hasDesc = skill.description.trim().isNotEmpty;
                  final cleanName = PdfTextSanitizer.clean(skill.name);
                  final cleanDesc = PdfTextSanitizer.clean(skill.description);
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        PdfTextSanitizer.buildBulletDot(accentColor, size: 4.0),
                        pw.Expanded(
                          child: hasDesc
                              ? pw.RichText(
                                  text: pw.TextSpan(
                                    children: [
                                      pw.TextSpan(
                                        text: '$cleanName: ',
                                        style: pw.TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.grey900,
                                        ),
                                      ),
                                      pw.TextSpan(
                                        text: cleanDesc,
                                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                                      ),
                                    ],
                                  ),
                                )
                              : pw.Text(cleanName, style: const pw.TextStyle(fontSize: 9.5)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 8),
            ],

            // Certifications
            if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
              _buildModernSectionTitle('CERTIFICATIONS & CREDENTIALS', accentColor),
              pw.SizedBox(height: 6),
              ...cv.certifications.map((cert) {
                final title = PdfTextSanitizer.clean(cert.displayTitle);
                final hasDesc = cert.description.trim().isNotEmpty;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      PdfTextSanitizer.buildBulletDot(accentColor, size: 3.5),
                      pw.Expanded(
                        child: hasDesc
                            ? pw.RichText(
                                text: pw.TextSpan(
                                  children: [
                                    pw.TextSpan(
                                      text: '$title — ',
                                      style: pw.TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.grey900,
                                      ),
                                    ),
                                    pw.TextSpan(
                                      text: PdfTextSanitizer.clean(cert.description),
                                      style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                                    ),
                                  ],
                                ),
                              )
                            : pw.Text(title, style: const pw.TextStyle(fontSize: 9.5)),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 8),
            ],

            // Languages
            if (cv.showLanguages && cv.languages.isNotEmpty) ...[
              _buildModernSectionTitle('LANGUAGES', accentColor),
              pw.SizedBox(height: 6),
              pw.Text(
                cv.languages
                    .map((l) => '${PdfTextSanitizer.clean(l.name)} (${PdfTextSanitizer.clean(l.proficiency)})')
                    .join('   |   '),
                style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 8),
            ],

            // Hobbies
            if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
              _buildModernSectionTitle('AREAS OF INTEREST', accentColor),
              pw.SizedBox(height: 6),
              pw.Text(
                cv.hobbies.map((h) => PdfTextSanitizer.clean(h)).join('   |   '),
                style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 8),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    CvDocument cv,
    Uint8List? photoBytes,
    PdfColor accentColor,
    PdfColor subtleTint,
  ) {
    final info = cv.personalInfo;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(info.fullName).toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 21,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 0.8,
                ),
              ),
              pw.SizedBox(height: 2),
              if (info.professionalTitle.isNotEmpty) ...[
                pw.Text(
                  PdfTextSanitizer.clean(info.professionalTitle),
                  style: pw.TextStyle(
                    fontSize: 11.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 6),
              ],
              pw.Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (info.email.isNotEmpty)
                    pw.Text(PdfTextSanitizer.clean(info.email), style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                  if (info.phone.isNotEmpty)
                    pw.Text(PdfTextSanitizer.clean(info.phone), style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                  if (info.location.isNotEmpty)
                    pw.Text(PdfTextSanitizer.clean(info.location), style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                  if (info.linkedin.isNotEmpty)
                    pw.Text(PdfTextSanitizer.clean(info.linkedin), style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.blue800)),
                ],
              ),
            ],
          ),
        ),
        if (photoBytes != null)
          pw.Container(
            width: 65,
            height: 78,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: accentColor, width: 1.2),
              image: pw.DecorationImage(
                image: pw.MemoryImage(photoBytes),
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  pw.Widget _buildModernSectionTitle(String title, PdfColor accentColor) {
    return pw.Row(
      children: [
        pw.Container(
          width: 3,
          height: 12,
          color: accentColor,
          margin: const pw.EdgeInsets.only(right: 6),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10.5,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Container(height: 0.8, color: PdfColors.grey300),
        ),
      ],
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor, PdfColor subtleTint) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
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
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: subtleTint,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  '${PdfTextSanitizer.clean(exp.startDate)} - ${PdfTextSanitizer.clean(exp.endDate)}',
                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
          pw.Text(
            PdfTextSanitizer.clean(exp.company),
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 3),
          ...exp.highlights.map(
            (hl) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2.5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PdfTextSanitizer.buildBulletDot(accentColor),
                  pw.Expanded(
                    child: pw.Text(
                      PdfTextSanitizer.clean(hl),
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

  pw.Widget _buildEducationItem(Education edu, PdfColor accentColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
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
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(edu.graduationYear),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              if (edu.gpa.trim().isNotEmpty)
                pw.Text(
                  'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
