import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Tech Timeline CV Template.
/// Modern engineering & tech layout with a visual vertical chronological line,
/// milestone node dots, skill pills, and ultra-high readability.
class TechTimelineTemplate extends CvTemplate {
  @override
  String get id => 'tech_timeline';

  @override
  String get nameKey => 'form.template_tech_timeline';

  @override
  String get descKey => 'form.template_tech_timeline_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'Tech Lead / Startup';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final softTint = tintColor(accentColor, 0.06);
    final borderTint = tintColor(accentColor, 0.25);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Top Modern Header
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (photoBytes != null) ...[
                  pw.Container(
                    width: 68,
                    height: 68,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: accentColor, width: 2),
                      image: pw.DecorationImage(
                        image: pw.MemoryImage(photoBytes),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 18),
                ],
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        PdfTextSanitizer.clean(info.fullName).toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 0.8,
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
                      pw.Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (info.email.isNotEmpty)
                            _buildIconText(PdfTextSanitizer.clean(info.email)),
                          if (info.phone.isNotEmpty)
                            _buildIconText(PdfTextSanitizer.clean(info.phone)),
                          if (info.location.isNotEmpty)
                            _buildIconText(PdfTextSanitizer.clean(info.location)),
                          if (info.linkedin.isNotEmpty)
                            _buildIconText(PdfTextSanitizer.clean(info.linkedin)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Container(height: 1.5, color: borderTint),
            pw.SizedBox(height: 14),

            // 2-Column Split: Left Side-Rail (Skills, Certs, Edu) & Right Main (Summary, Timeline Experience)
            pw.Partitions(
              children: [
                // Left Column: Skills, Education, Languages (175pt)
                pw.Partition(
                  width: 175,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 18),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Skills Pills
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          _buildLeftTitle('CORE STACK', accentColor),
                          pw.SizedBox(height: 6),
                          pw.Wrap(
                            spacing: 4,
                            runSpacing: 5,
                            children: cv.skills.map((s) {
                              final cleanName = PdfTextSanitizer.clean(s.name);
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: pw.BoxDecoration(
                                  color: softTint,
                                  borderRadius: pw.BorderRadius.circular(4),
                                  border: pw.Border.all(color: borderTint, width: 0.8),
                                ),
                                child: pw.Text(
                                  cleanName,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          pw.SizedBox(height: 16),
                        ],

                        // Education Card
                        if (cv.showEducation && cv.educations.isNotEmpty) ...[
                          _buildLeftTitle('EDUCATION', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.educations.map((edu) {
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 8),
                              padding: const pw.EdgeInsets.all(8),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(6),
                                border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
                                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                                  ),
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    PdfTextSanitizer.clean(edu.institution),
                                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentColor),
                                  ),
                                  pw.Text(
                                    PdfTextSanitizer.clean(edu.graduationYear),
                                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                                  ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 10),
                        ],

                        // Certifications
                        if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                          _buildLeftTitle('CERTIFICATIONS', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.certifications.map((c) {
                            final title = PdfTextSanitizer.clean(c.displayTitle);
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  PdfTextSanitizer.buildBulletDot(accentColor, size: 3),
                                  pw.Expanded(
                                    child: pw.Text(title, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                                  ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 10),
                        ],

                        // Languages
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          _buildLeftTitle('LANGUAGES', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.languages.map((l) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 3),
                                child: pw.Text(
                                  '${PdfTextSanitizer.clean(l.name)} - ${PdfTextSanitizer.clean(l.proficiency)}',
                                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right Column: Summary & Chronological Experience Timeline
                pw.Partition(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Executive Summary
                      if (cv.showSummary && cv.summary.isNotEmpty) ...[
                        _buildRightTitle('CAREER OVERVIEW', accentColor),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          PdfTextSanitizer.clean(cv.summary),
                          style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.6, color: PdfColors.grey900),
                          textAlign: pw.TextAlign.justify,
                        ),
                        pw.SizedBox(height: 16),
                      ],

                      // Experience Timeline
                      if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                        _buildRightTitle('WORK TIMELINE', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.experiences.map((exp) => _buildTimelineItem(exp, accentColor, borderTint)),
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

  pw.Widget _buildLeftTitle(String title, PdfColor accentColor) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 9.5,
        fontWeight: pw.FontWeight.bold,
        color: accentColor,
        letterSpacing: 0.8,
      ),
    );
  }

  pw.Widget _buildRightTitle(String title, PdfColor accentColor) {
    return pw.Row(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(child: pw.Container(height: 1, color: PdfColor.fromHex('#E2E8F0'))),
      ],
    );
  }

  pw.Widget _buildIconText(String text) {
    return pw.Text(text, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700));
  }

  pw.Widget _buildTimelineItem(WorkExperience exp, PdfColor accentColor, PdfColor timelineLineColor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Vertical Timeline Node & Line
        pw.Column(
          children: [
            pw.Container(
              width: 9,
              height: 9,
              margin: const pw.EdgeInsets.only(top: 2),
              decoration: pw.BoxDecoration(
                color: accentColor,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.Container(
              width: 1.5,
              height: 60,
              color: timelineLineColor,
            ),
          ],
        ),
        pw.SizedBox(width: 12),
        // Content
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      PdfTextSanitizer.clean(exp.position),
                      style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F1F5F9'),
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        '${PdfTextSanitizer.clean(exp.startDate)} - ${PdfTextSanitizer.clean(exp.endDate)}',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  PdfTextSanitizer.clean(exp.company),
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: accentColor),
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
                            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800, lineSpacing: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
