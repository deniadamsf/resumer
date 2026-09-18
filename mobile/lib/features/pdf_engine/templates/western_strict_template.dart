import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Western Strict ATS Template
/// Minimalist 1-column layout without photo for strict anti-bias compliance (US, UK, Europe).
/// Yields flawless 95-100 ATS machine parser readability score.
class WesternStrictTemplate extends CvTemplate {
  @override
  String get id => 'western_strict';

  @override
  String get nameKey => 'form.template_western_strict';

  @override
  String get descKey => 'form.template_western_strict_desc';

  @override
  bool get isAtsFriendly => true;

  @override
  String get atsScoreRange => 'Skor: 95-100';

  @override
  bool get supportsPhoto => false;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Center-aligned clean candidate header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    PdfTextSanitizer.clean(info.fullName).toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  if (info.professionalTitle.isNotEmpty) ...[
                    pw.Text(
                      PdfTextSanitizer.clean(info.professionalTitle),
                      style: pw.TextStyle(
                        fontSize: 11.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                  ],
                  pw.Text(
                    [
                      if (info.location.isNotEmpty) PdfTextSanitizer.clean(info.location),
                      if (info.phone.isNotEmpty) PdfTextSanitizer.clean(info.phone),
                      if (info.email.isNotEmpty) PdfTextSanitizer.clean(info.email),
                    ].join('   |   '),
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                  if (info.linkedin.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      PdfTextSanitizer.clean(info.linkedin),
                      style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.blue800),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(height: 1.2, color: accentColor),
            pw.SizedBox(height: 10),

            // Summary
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              _buildSectionTitle('PROFESSIONAL SUMMARY', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                PdfTextSanitizer.clean(cv.summary),
                style: const pw.TextStyle(fontSize: 9.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 10),
            ],

            // Experience
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildSectionTitle('PROFESSIONAL EXPERIENCE', accentColor),
              pw.SizedBox(height: 4),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
              pw.SizedBox(height: 8),
            ],

            // Education
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              _buildSectionTitle('EDUCATION', accentColor),
              pw.SizedBox(height: 4),
              ...cv.educations.map((edu) => _buildEducationItem(edu)),
              pw.SizedBox(height: 8),
            ],

            // Skills
            if (cv.showSkills && cv.skills.isNotEmpty) ...[
              _buildSectionTitle('KEY COMPETENCIES & TECHNICAL SKILLS', accentColor),
              pw.SizedBox(height: 4),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cv.skills.map((skill) {
                  final hasDesc = skill.description.trim().isNotEmpty;
                  final cleanName = PdfTextSanitizer.clean(skill.name);
                  final cleanDesc = PdfTextSanitizer.clean(skill.description);
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2.5),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        PdfTextSanitizer.buildBulletDot(accentColor),
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
              _buildSectionTitle('CERTIFICATIONS & LICENSES', accentColor),
              pw.SizedBox(height: 4),
              ...cv.certifications.map((cert) {
                final title = PdfTextSanitizer.clean(cert.displayTitle);
                final hasDesc = cert.description.trim().isNotEmpty;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2.5),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      PdfTextSanitizer.buildBulletDot(accentColor),
                      pw.Expanded(
                        child: hasDesc
                            ? pw.RichText(
                                text: pw.TextSpan(
                                  children: [
                                    pw.TextSpan(
                                      text: '$title - ',
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
              _buildSectionTitle('LANGUAGES', accentColor),
              pw.SizedBox(height: 4),
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
              _buildSectionTitle('AREAS OF INTEREST', accentColor),
              pw.SizedBox(height: 4),
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

  pw.Widget _buildSectionTitle(String title, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10.5,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.8, color: PdfColors.grey400),
      ],
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
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
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
          pw.SizedBox(height: 2.5),
          ...exp.highlights.map(
            (hl) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2.0),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PdfTextSanitizer.buildBulletDot(accentColor, size: 3.0),
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

  pw.Widget _buildEducationItem(Education edu) {
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
