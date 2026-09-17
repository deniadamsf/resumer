import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Gradient Vivid Header CV Template.
/// High-end creative resume featuring a vibrant colored header banner,
/// crisp white typography, executive photo frame, and visual star-rated language proficiency.
class GradientHeaderTemplate extends CvTemplate {
  @override
  String get id => 'gradient_header';

  @override
  String get nameKey => 'form.template_gradient_header';

  @override
  String get descKey => 'form.template_gradient_header_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'Desain Berwarna';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final secondaryAccent = tintColor(accentColor, 0.45);
    final softTint = tintColor(accentColor, 0.06);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Vibrant Header Banner
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [accentColor, secondaryAccent],
                  begin: pw.Alignment.centerLeft,
                  end: pw.Alignment.centerRight,
                ),
                borderRadius: pw.BorderRadius.circular(10),
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
                            color: PdfColors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (info.professionalTitle.isNotEmpty) ...[
                          pw.SizedBox(height: 3),
                          pw.Text(
                            PdfTextSanitizer.clean(info.professionalTitle),
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey200,
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (info.email.isNotEmpty)
                              _buildHeaderContact(info.email),
                            if (info.phone.isNotEmpty)
                              _buildHeaderContact(info.phone),
                            if (info.location.isNotEmpty)
                              _buildHeaderContact(info.location),
                            if (info.linkedin.isNotEmpty)
                              _buildHeaderContact(info.linkedin),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (photoBytes != null) ...[
                    pw.SizedBox(width: 16),
                    pw.Container(
                      width: 66,
                      height: 66,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: PdfColors.white, width: 2.5),
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

            // Summary
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: softTint,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: tintColor(accentColor, 0.25), width: 0.8),
                ),
                child: pw.Text(
                  PdfTextSanitizer.clean(cv.summary),
                  style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800, lineSpacing: 1.4),
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // 2-Column Split Body
            pw.Partitions(
              children: [
                // Left Column: Work Experience & Education (width 320)
                pw.Partition(
                  width: 320,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Experience
                      if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                        _buildSectionTitle('EXPERIENCE', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
                        pw.SizedBox(height: 10),
                      ],

                      // Education
                      if (cv.showEducation && cv.educations.isNotEmpty) ...[
                        _buildSectionTitle('EDUCATION', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.educations.map((edu) => _buildEducationItem(edu, accentColor)),
                      ],
                    ],
                  ),
                ),

                pw.Partition(width: 14, child: pw.SizedBox()),

                // Right Column: Skills, Certifications, Languages (with stars), Hobbies
                pw.Partition(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Skills
                      if (cv.showSkills && cv.skills.isNotEmpty) ...[
                        _buildSectionTitle('SKILLS & EXPERTISE', accentColor),
                        pw.SizedBox(height: 8),
                        pw.Wrap(
                          spacing: 4,
                          runSpacing: 5,
                          children: cv.skills.map((skill) {
                            return pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                              decoration: pw.BoxDecoration(
                                color: softTint,
                                borderRadius: pw.BorderRadius.circular(4),
                                border: pw.Border.all(color: tintColor(accentColor, 0.25), width: 0.8),
                              ),
                              child: pw.Text(
                                PdfTextSanitizer.clean(skill.name),
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        pw.SizedBox(height: 12),
                      ],

                      // Certifications
                      if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                        _buildSectionTitle('CERTIFICATIONS', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.certifications.map((cert) {
                          final title = PdfTextSanitizer.clean(cert.displayTitle);
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 5),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                PdfTextSanitizer.buildBulletDot(accentColor, size: 3.5),
                                pw.Expanded(
                                  child: pw.Text(
                                    title,
                                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 12),
                      ],

                      // Languages with Star Rating Dots
                      if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                        _buildSectionTitle('LANGUAGES', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.languages.map((lang) {
                          final cleanName = PdfTextSanitizer.clean(lang.name);
                          final cleanProf = PdfTextSanitizer.clean(lang.proficiency);
                          final stars = PdfTextSanitizer.proficiencyToStars(cleanProf);
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 5),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      cleanName,
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.grey900,
                                      ),
                                    ),
                                    if (cleanProf.isNotEmpty)
                                      pw.Text(
                                        cleanProf,
                                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                                      ),
                                  ],
                                ),
                                PdfTextSanitizer.buildStarRating(stars, accentColor, size: 4.5, spacing: 2.5),
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 12),
                      ],

                      // Hobbies
                      if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                        _buildSectionTitle('INTERESTS', accentColor),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          cv.hobbies.map((h) => PdfTextSanitizer.clean(h)).join(' - '),
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
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

  pw.Widget _buildHeaderContact(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(
        PdfTextSanitizer.clean(text),
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, PdfColor accentColor) {
    return pw.Row(
      children: [
        pw.Container(
          width: 3.5,
          height: 12,
          color: accentColor,
          margin: const pw.EdgeInsets.only(right: 6),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.5,
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
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
              ),
              pw.Text(
                '${PdfTextSanitizer.clean(exp.startDate)} - ${PdfTextSanitizer.clean(exp.endDate)}',
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
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
              padding: const pw.EdgeInsets.only(bottom: 2.5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PdfTextSanitizer.buildBulletDot(accentColor),
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

  pw.Widget _buildEducationItem(Education edu, PdfColor accentColor) {
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
                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
              ),
              pw.Text(
                PdfTextSanitizer.clean(edu.institution),
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(edu.graduationYear),
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
              ),
              if (edu.gpa.trim().isNotEmpty)
                pw.Text(
                  'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
