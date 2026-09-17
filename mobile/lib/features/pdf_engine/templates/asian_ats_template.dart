import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Asian ATS Classic Template
/// Single-column format with an isolated professional photo slot in the header.
/// Ideal for corporate standards in Indonesia, Singapore, and Asian regional markets.
class AsianAtsTemplate extends CvTemplate {
  @override
  String get id => 'asian_ats';

  @override
  String get nameKey => 'form.template_asian';

  @override
  String get descKey => 'form.template_asian_desc';

  @override
  bool get isAtsFriendly => true;

  @override
  String get atsScoreRange => 'Skor: 85-95';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            _buildHeader(cv, photoBytes, accentColor),
            pw.SizedBox(height: 12),
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              PdfTextSanitizer.buildSectionTitle('EXECUTIVE SUMMARY', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                PdfTextSanitizer.clean(cv.summary),
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),
            ],
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              PdfTextSanitizer.buildSectionTitle('WORK EXPERIENCE', accentColor),
              pw.SizedBox(height: 4),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
              pw.SizedBox(height: 8),
            ],
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              PdfTextSanitizer.buildSectionTitle('EDUCATION', accentColor),
              pw.SizedBox(height: 4),
              ...cv.educations.map((edu) => _buildEducationItem(edu)),
              pw.SizedBox(height: 8),
            ],
            if (cv.showSkills && cv.skills.isNotEmpty) ...[
              PdfTextSanitizer.buildSectionTitle('CORE COMPETENCIES & SKILLS', accentColor),
              pw.SizedBox(height: 4),
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
            if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
              PdfTextSanitizer.buildSectionTitle('CERTIFICATIONS', accentColor),
              pw.SizedBox(height: 4),
              ...cv.certifications.map((cert) {
                final title = PdfTextSanitizer.clean(cert.displayTitle);
                final hasDesc = cert.description.trim().isNotEmpty;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
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
            if (cv.showLanguages && cv.languages.isNotEmpty) ...[
              PdfTextSanitizer.buildSectionTitle('LANGUAGES', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                cv.languages
                    .map((l) => '${PdfTextSanitizer.clean(l.name)} (${PdfTextSanitizer.clean(l.proficiency)})')
                    .join('   |   '),
                style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 8),
            ],
            if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
              PdfTextSanitizer.buildSectionTitle('HOBBIES & INTERESTS', accentColor),
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

  pw.Widget _buildHeader(CvDocument cv, Uint8List? photoBytes, PdfColor accentColor) {
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
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 0.5,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                PdfTextSanitizer.clean(info.professionalTitle),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '${PdfTextSanitizer.clean(info.email)}  |  ${PdfTextSanitizer.clean(info.phone)}  |  ${PdfTextSanitizer.clean(info.location)}',
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

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor) {
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
                style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold),
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

  pw.Widget _buildEducationItem(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
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
