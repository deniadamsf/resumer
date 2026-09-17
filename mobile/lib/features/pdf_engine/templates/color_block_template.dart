import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Color Block Mosaic CV Template.
/// Modern modular layout with colorful card blocks, soft pastel backgrounds,
/// vivid section accent stripes, and star-rated language proficiency.
class ColorBlockTemplate extends CvTemplate {
  @override
  String get id => 'color_block';

  @override
  String get nameKey => 'form.template_color_block';

  @override
  String get descKey => 'form.template_color_block_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'Desain Modular';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final softTint = tintColor(accentColor, 0.05);
    final mediumTint = tintColor(accentColor, 0.12);
    final borderTint = tintColor(accentColor, 0.25);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Top Candidate Hero Block
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: softTint,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderTint, width: 1),
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
                            fontSize: 21,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (info.professionalTitle.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            PdfTextSanitizer.clean(info.professionalTitle),
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 6),
                        pw.Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (info.email.isNotEmpty)
                              _buildContactPill(info.email, mediumTint, accentColor),
                            if (info.phone.isNotEmpty)
                              _buildContactPill(info.phone, mediumTint, accentColor),
                            if (info.location.isNotEmpty)
                              _buildContactPill(info.location, mediumTint, accentColor),
                            if (info.linkedin.isNotEmpty)
                              _buildContactPill(info.linkedin, mediumTint, accentColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (photoBytes != null) ...[
                    pw.SizedBox(width: 14),
                    pw.Container(
                      width: 64,
                      height: 64,
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: accentColor, width: 2),
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
            pw.SizedBox(height: 12),

            // Summary Block
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              _buildBlockContainer(
                title: 'PROFESSIONAL SUMMARY',
                accentColor: accentColor,
                child: pw.Text(
                  PdfTextSanitizer.clean(cv.summary),
                  style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800, lineSpacing: 1.4),
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // Work Experience Block
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildBlockContainer(
                title: 'WORK EXPERIENCE',
                accentColor: accentColor,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor, softTint)).toList(),
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // Education Block
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              _buildBlockContainer(
                title: 'EDUCATION',
                accentColor: accentColor,
                child: pw.Column(
                  children: cv.educations.map((edu) => _buildEducationItem(edu, accentColor)).toList(),
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // 2-Column Split: Skills on Left, Languages & Certifications on Right
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Skills Block (58%)
                pw.Expanded(
                  flex: 58,
                  child: cv.showSkills && cv.skills.isNotEmpty
                      ? _buildBlockContainer(
                          title: 'SKILLS & COMPETENCIES',
                          accentColor: accentColor,
                          child: pw.Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: cv.skills.map((s) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: pw.BoxDecoration(
                                  color: softTint,
                                  borderRadius: pw.BorderRadius.circular(4),
                                  border: pw.Border.all(color: borderTint, width: 0.8),
                                ),
                                child: pw.Text(
                                  PdfTextSanitizer.clean(s.name),
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : pw.SizedBox(),
                ),

                pw.SizedBox(width: 12),

                // Right Column: Languages (with stars) + Certifications (42%)
                pw.Expanded(
                  flex: 42,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                        _buildBlockContainer(
                          title: 'LANGUAGES',
                          accentColor: accentColor,
                          child: pw.Column(
                            children: cv.languages.map((l) {
                              final cleanName = PdfTextSanitizer.clean(l.name);
                              final cleanProf = PdfTextSanitizer.clean(l.proficiency);
                              final stars = PdfTextSanitizer.proficiencyToStars(cleanProf);
                              return pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 4),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      cleanName,
                                      style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                                    ),
                                    PdfTextSanitizer.buildStarRating(stars, accentColor, size: 4.5),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                      ],

                      if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                        _buildBlockContainer(
                          title: 'CERTIFICATIONS',
                          accentColor: accentColor,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: cv.certifications.map((c) {
                              return pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 3),
                                child: pw.Row(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    PdfTextSanitizer.buildBulletDot(accentColor, size: 3),
                                    pw.Expanded(
                                      child: pw.Text(
                                        PdfTextSanitizer.clean(c.displayTitle),
                                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                      ],

                      if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                        _buildBlockContainer(
                          title: 'INTERESTS',
                          accentColor: accentColor,
                          child: pw.Text(
                            cv.hobbies.map((h) => PdfTextSanitizer.clean(h)).join(' - '),
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildBlockContainer({
    required String title,
    required PdfColor accentColor,
    required pw.Widget child,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 3.5,
                height: 11,
                color: accentColor,
                margin: const pw.EdgeInsets.only(right: 6),
              ),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  pw.Widget _buildContactPill(String text, PdfColor bg, PdfColor textCol) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        PdfTextSanitizer.clean(text),
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textCol),
      ),
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor, PdfColor softTint) {
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
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: pw.BoxDecoration(
                  color: softTint,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  '${PdfTextSanitizer.clean(exp.startDate)} - ${PdfTextSanitizer.clean(exp.endDate)}',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            PdfTextSanitizer.clean(exp.company),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor),
          ),
          pw.SizedBox(height: 3),
          ...exp.highlights.map(
            (hl) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PdfTextSanitizer.buildBulletDot(accentColor, size: 3),
                  pw.Expanded(
                    child: pw.Text(
                      PdfTextSanitizer.clean(hl),
                      style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800, lineSpacing: 1.3),
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
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
              ),
              pw.Text(
                PdfTextSanitizer.clean(edu.institution),
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(edu.graduationYear),
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              if (edu.gpa.trim().isNotEmpty)
                pw.Text(
                  'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                  style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
