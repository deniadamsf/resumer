import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Executive Split & Serif Template
/// Luxury corporate magazine / editorial layout with distinguished typography
/// and delicate hairline borders.
/// Ideal for senior leadership, finance, corporate counsel, and creative directors.
class ExecutiveSplitTemplate extends CvTemplate {
  @override
  String get id => 'executive_split';

  @override
  String get nameKey => 'form.template_executive_split';

  @override
  String get descKey => 'form.template_executive_split_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'Eksekutif / C-Level';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 34),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Executive Header with Left Accent Pillar
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 5,
                  height: 50,
                  color: accentColor,
                  margin: const pw.EdgeInsets.only(right: 14),
                ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          PdfTextSanitizer.clean(info.fullName).toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          PdfTextSanitizer.clean(info.professionalTitle),
                          style: pw.TextStyle(
                            fontSize: 11.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          [
                            if (info.email.isNotEmpty) PdfTextSanitizer.clean(info.email),
                            if (info.phone.isNotEmpty) PdfTextSanitizer.clean(info.phone),
                            if (info.location.isNotEmpty) PdfTextSanitizer.clean(info.location),
                            if (info.linkedin.isNotEmpty) PdfTextSanitizer.clean(info.linkedin),
                          ].join('   |   '),
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                  if (photoBytes != null) ...[
                    pw.SizedBox(width: 12),
                    pw.Container(
                      width: 68,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: accentColor, width: 1.5),
                        image: pw.DecorationImage(
                          image: pw.MemoryImage(photoBytes),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            pw.SizedBox(height: 12),
            pw.Divider(thickness: 0.8, color: PdfColors.grey300),
            pw.SizedBox(height: 10),

            // Executive Summary
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              _buildSectionTitle('LEADERSHIP PROFILE', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                PdfTextSanitizer.clean(cv.summary),
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.2),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),
            ],

            // Professional Experience
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildSectionTitle('CAREER TRAJECTORY & EXPERIENCE', accentColor),
              pw.SizedBox(height: 5),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
              pw.SizedBox(height: 8),
            ],

            // Education
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              _buildSectionTitle('ACADEMIC BACKGROUND', accentColor),
              pw.SizedBox(height: 5),
              ...cv.educations.map((edu) => _buildEducationItem(edu)),
              pw.SizedBox(height: 8),
            ],

            // Core Competencies
            if (cv.showSkills && cv.skills.isNotEmpty) ...[
              _buildSectionTitle('EXECUTIVE COMPETENCIES & DOMAINS', accentColor),
              pw.SizedBox(height: 5),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cv.skills.map((skill) {
                  final cleanName = PdfTextSanitizer.clean(skill.name);
                  final hasDesc = skill.description.trim().isNotEmpty;
                  final cleanDesc = PdfTextSanitizer.clean(skill.description);
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2.5),
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
              _buildSectionTitle('BOARD & PROFESSIONAL CERTIFICATIONS', accentColor),
              pw.SizedBox(height: 5),
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
                          hasDesc ? '$title — ${PdfTextSanitizer.clean(c.description)}' : title,
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
            if (cv.showLanguages && cv.languages.isNotEmpty) ...[
              _buildSectionTitle('LANGUAGES', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                cv.languages
                    .map((l) => '${PdfTextSanitizer.clean(l.name)} (${PdfTextSanitizer.clean(l.proficiency)})')
                    .join('   |   '),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 8),
            ],

            if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
              _buildSectionTitle('AFFILIATIONS & INTERESTS', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                cv.hobbies.map((h) => PdfTextSanitizer.clean(h)).join('   |   '),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
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
        pw.Container(height: 1, width: 40, color: accentColor),
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

  pw.Widget _buildEducationItem(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
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
          pw.Text(
            PdfTextSanitizer.clean(edu.graduationYear),
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
}
