import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Bento Grid Executive CV Template.
/// Modern modular card grid layout inspired by high-end tech & product design.
/// High contrast, crisp borders, and balanced visual sections.
class BentoGridTemplate extends CvTemplate {
  @override
  String get id => 'bento_grid';

  @override
  String get nameKey => 'form.template_bento_grid';

  @override
  String get descKey => 'form.template_bento_grid_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'Modern Tech / Startup';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final cardBg = tintColor(accentColor, 0.04);
    final borderCol = tintColor(accentColor, 0.22);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Hero Bento Card
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: cardBg,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderCol, width: 1),
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
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 0.8,
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
                        pw.SizedBox(height: 10),
                        pw.Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (info.email.isNotEmpty)
                              _buildPill(PdfTextSanitizer.clean(info.email)),
                            if (info.phone.isNotEmpty)
                              _buildPill(PdfTextSanitizer.clean(info.phone)),
                            if (info.location.isNotEmpty)
                              _buildPill(PdfTextSanitizer.clean(info.location)),
                            if (info.linkedin.isNotEmpty)
                              _buildPill(PdfTextSanitizer.clean(info.linkedin)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (photoBytes != null) ...[
                    pw.SizedBox(width: 14),
                    pw.Container(
                      width: 66,
                      height: 76,
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(8),
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
            ),
            pw.SizedBox(height: 12),

            // About Me Bento Card
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('ABOUT', accentColor),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      PdfTextSanitizer.clean(cv.summary),
                      style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.5, color: PdfColors.grey900),
                      textAlign: pw.TextAlign.justify,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // Experience Bento Card
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('EXPERIENCE', accentColor),
                    pw.SizedBox(height: 8),
                    ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // Bottom Bento Grid: Skills & Education
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Skills Bento
                if (cv.showSkills && cv.skills.isNotEmpty)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: cardBg,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderCol, width: 0.8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildCardTitle('SKILLS & TOOLS', accentColor),
                          pw.SizedBox(height: 6),
                          pw.Wrap(
                            spacing: 4,
                            runSpacing: 5,
                            children: cv.skills.map((s) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.white,
                                  borderRadius: pw.BorderRadius.circular(4),
                                  border: pw.Border.all(color: borderCol, width: 0.6),
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
                        ],
                      ),
                    ),
                  ),
                if (cv.showSkills && cv.skills.isNotEmpty && cv.showEducation && cv.educations.isNotEmpty)
                  pw.SizedBox(width: 12),
                // Education Bento
                if (cv.showEducation && cv.educations.isNotEmpty)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildCardTitle('EDUCATION', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.educations.map((edu) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
                                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                                    ),
                                    pw.Text(
                                      '${PdfTextSanitizer.clean(edu.institution)} (${PdfTextSanitizer.clean(edu.graduationYear)})',
                                      style: pw.TextStyle(fontSize: 8, color: accentColor, fontWeight: pw.FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
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

  pw.Widget _buildCardTitle(String title, PdfColor accentColor) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 10.5,
        fontWeight: pw.FontWeight.bold,
        color: accentColor,
        letterSpacing: 0.8,
      ),
    );
  }

  pw.Widget _buildPill(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  PdfTextSanitizer.clean(exp.position),
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                '${PdfTextSanitizer.clean(exp.startDate)} - ${PdfTextSanitizer.clean(exp.endDate)}',
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.Text(
            PdfTextSanitizer.clean(exp.company),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor),
          ),
          pw.SizedBox(height: 2),
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
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800, lineSpacing: 1.3),
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
}
