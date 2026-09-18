import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Editorial Luxury CV Template.
/// High-fashion & C-level executive editorial layout with refined typography,
/// framed portrait, luxury quote callout, and clean 2-column editorial balance.
class EditorialLuxuryTemplate extends CvTemplate {
  @override
  String get id => 'editorial_luxury';

  @override
  String get nameKey => 'form.template_editorial_luxury';

  @override
  String get descKey => 'form.template_editorial_luxury_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'Eksekutif / Editorial';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final luxuryTint = tintColor(accentColor, 0.05);
    final borderTint = tintColor(accentColor, 0.3);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 34),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Luxury Header with Dual Border Frame
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: luxuryTint,
                border: pw.Border.all(color: borderTint, width: 1),
                borderRadius: pw.BorderRadius.circular(6),
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
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          PdfTextSanitizer.clean(info.professionalTitle).toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            if (info.email.isNotEmpty)
                              _buildHeaderContact(PdfTextSanitizer.clean(info.email)),
                            if (info.phone.isNotEmpty) ...[
                              _buildDotSeparator(),
                              _buildHeaderContact(PdfTextSanitizer.clean(info.phone)),
                            ],
                            if (info.location.isNotEmpty) ...[
                              _buildDotSeparator(),
                              _buildHeaderContact(PdfTextSanitizer.clean(info.location)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (photoBytes != null) ...[
                    pw.SizedBox(width: 14),
                    pw.Container(
                      width: 66,
                      height: 78,
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(4),
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
            pw.SizedBox(height: 14),

            // Executive Summary Quote Callout
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
                ),
                child: pw.Text(
                  PdfTextSanitizer.clean(cv.summary),
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontStyle: pw.FontStyle.italic,
                    lineSpacing: 1.6,
                    color: PdfColors.grey900,
                  ),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
              pw.SizedBox(height: 14),
            ],

            // Experience Section
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildSectionTitle('EXPERIENCE & ACHIEVEMENTS', accentColor),
              pw.SizedBox(height: 8),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
              pw.SizedBox(height: 10),
            ],

            // Education & Skills in 2 Column Partition
            pw.Partitions(
              children: [
                // Left: Education & Certs
                pw.Partition(
                  flex: 1,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 14),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (cv.showEducation && cv.educations.isNotEmpty) ...[
                          _buildSectionTitle('EDUCATION', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.educations.map((edu) => _buildEducationItem(edu, accentColor)),
                          pw.SizedBox(height: 10),
                        ],
                        if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                          _buildSectionTitle('CREDENTIALS', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.certifications.map((c) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 3),
                                child: pw.Row(
                                  children: [
                                    PdfTextSanitizer.buildBulletDot(accentColor, size: 3),
                                    pw.Expanded(
                                      child: pw.Text(
                                        PdfTextSanitizer.clean(c.displayTitle),
                                        style: const pw.TextStyle(fontSize: 8.5),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
                // Right: Key Competencies & Languages
                pw.Partition(
                  flex: 1,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 14),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          _buildSectionTitle('AREAS OF EXPERTISE', accentColor),
                          pw.SizedBox(height: 6),
                          pw.Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: cv.skills.map((s) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: pw.BoxDecoration(
                                  color: luxuryTint,
                                  borderRadius: pw.BorderRadius.circular(3),
                                  border: pw.Border.all(color: borderTint, width: 0.6),
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
                          pw.SizedBox(height: 10),
                        ],
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          _buildSectionTitle('LANGUAGES', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.languages.map((l) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 2.5),
                                child: pw.Text(
                                  '${PdfTextSanitizer.clean(l.name)} (${PdfTextSanitizer.clean(l.proficiency)})',
                                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                ),
                              )),
                        ],
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

  pw.Widget _buildHeaderContact(String text) {
    return pw.Text(text, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700));
  }

  pw.Widget _buildDotSeparator() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6),
      child: PdfTextSanitizer.buildBulletDot(PdfColors.grey500, size: 2.5),
    );
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
            letterSpacing: 1.0,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, color: PdfColor.fromHex('#CBD5E1')),
      ],
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
                  style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                '${PdfTextSanitizer.clean(exp.startDate)} - ${PdfTextSanitizer.clean(exp.endDate)}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            PdfTextSanitizer.clean(exp.company).toUpperCase(),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor, letterSpacing: 0.5),
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
                      style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800, lineSpacing: 1.35),
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
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  PdfTextSanitizer.clean(edu.institution),
                  style: pw.TextStyle(fontSize: 8.5, color: accentColor, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                PdfTextSanitizer.clean(edu.graduationYear),
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
