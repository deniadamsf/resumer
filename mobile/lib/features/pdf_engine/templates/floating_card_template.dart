import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../utils/pdf_text_sanitizer.dart';
import '../utils/social_icon_pdf_widget.dart';
import 'cv_template_interface.dart';

/// Floating Card Creative Template.
/// Neo-modern card architecture with layered soft containers,
/// floating modular elements, subtle borders, and balanced visual padding.
class FloatingCardTemplate extends CvTemplate {
  @override
  String get id => 'floating_card';

  @override
  String get nameKey => 'form.template_floating_card';

  @override
  String get descKey => 'form.template_floating_card_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'form.template_score_floating_card';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final cardBg = tintColor(accentColor, 0.035);
    final cardBorder = tintColor(accentColor, 0.2);
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Floating Hero Header Card
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: cardBg,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: cardBorder, width: 1),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (photoBytes != null) ...[
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
                    pw.SizedBox(width: 14),
                  ],
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
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (info.email.isNotEmpty)
                              _buildPillBadge(PdfTextSanitizer.clean(info.email)),
                            if (info.phone.isNotEmpty)
                              _buildPillBadge(PdfTextSanitizer.clean(info.phone)),
                            if (info.location.isNotEmpty)
                              _buildPillBadge(PdfTextSanitizer.clean(info.location)),
                            if (cv.showSocialLinks)
                              SocialIconPdfWidget.buildWrapList(
                                info: info,
                                isAtsMode: false,
                                accentColor: accentColor,
                                textColor: PdfColors.grey800,
                                fontSize: 7.5,
                                iconSize: 8,
                                spacing: 8,
                                runSpacing: 4,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Summary Card
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: cardBorder, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('EXECUTIVE SUMMARY', accentColor),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      PdfTextSanitizer.clean(cv.summary),
                      style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.3, color: PdfColors.grey800),
                      textAlign: pw.TextAlign.justify,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
            ],

            // Work Experience Section
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: cardBg,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: cardBorder, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildCardTitle('WORK EXPERIENCE', accentColor),
                    pw.SizedBox(height: 6),
                    ...cv.experiences.map((exp) {
                      final dateRange = DateFormatHelper.formatDateRange(
                        exp.startDate,
                        exp.endDate,
                        isEnglish: isEn,
                      );
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(5),
                          border: pw.Border.all(color: cardBorder, width: 0.6),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    PdfTextSanitizer.clean(exp.position),
                                    style: pw.TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                pw.Text(
                                  dateRange,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 1.5),
                            pw.Text(
                              PdfTextSanitizer.clean(exp.company),
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700,
                              ),
                            ),
                            if (exp.highlights.isNotEmpty) ...[
                              pw.SizedBox(height: 4),
                              ...exp.highlights.map((h) {
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 2),
                                  child: pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      PdfTextSanitizer.buildBulletDot(accentColor, size: 2.5),
                                      pw.Expanded(
                                        child: pw.Text(
                                          PdfTextSanitizer.clean(h),
                                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
            ],

            // Two Column Modular Cards: Left = Skills & Languages, Right = Projects & Education
            pw.Partitions(
              children: [
                // Left Partition: Skills, Languages, Certifications, Hobbies
                pw.Partition(
                  width: 185,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Skills Card
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: cardBg,
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(color: cardBorder, width: 0.8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildCardTitle('SKILLS & COMPETENCIES', accentColor),
                                pw.SizedBox(height: 6),
                                pw.Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: cv.skills.map((s) {
                                    final cleanName = PdfTextSanitizer.clean(s.name);
                                    final cleanDesc = PdfTextSanitizer.clean(s.description);
                                    final hasDesc = cv.showSkillDescription && cleanDesc.isNotEmpty;
                                    return pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.white,
                                        borderRadius: pw.BorderRadius.circular(4),
                                        border: pw.Border.all(color: cardBorder, width: 0.6),
                                      ),
                                      child: pw.Text(
                                        hasDesc ? '$cleanName: $cleanDesc' : cleanName,
                                        style: pw.TextStyle(
                                          fontSize: 7.5,
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
                          pw.SizedBox(height: 8),
                        ],

                        // Languages Card
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(color: cardBorder, width: 0.8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildCardTitle('LANGUAGES', accentColor),
                                pw.SizedBox(height: 5),
                                ...cv.languages.map((l) {
                                  return pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 3),
                                    child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          PdfTextSanitizer.clean(l.name),
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.grey900,
                                          ),
                                        ),
                                        pw.Text(
                                          PdfTextSanitizer.clean(l.proficiency),
                                          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 8),
                        ],

                        // Certifications Card
                        if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: cardBg,
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(color: cardBorder, width: 0.8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildCardTitle('CERTIFICATIONS', accentColor),
                                pw.SizedBox(height: 5),
                                ...cv.certifications.map((c) {
                                  final title = PdfTextSanitizer.clean(c.displayTitle);
                                  return pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 3),
                                    child: pw.Text(
                                      title,
                                      style: pw.TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.grey900,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 8),
                        ],

                        // Hobbies Card
                        if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(color: cardBorder, width: 0.8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildCardTitle('INTERESTS', accentColor),
                                pw.SizedBox(height: 5),
                                pw.Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: cv.hobbies.map((h) {
                                    return pw.Text(
                                      PdfTextSanitizer.clean(h),
                                      style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right Partition: Projects & Education
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Projects Card
                        if (cv.showProjects && cv.projects.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(color: cardBorder, width: 0.8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildCardTitle('PROJECTS', accentColor),
                                pw.SizedBox(height: 6),
                                ...cv.projects.map((proj) {
                                  final dateRange = DateFormatHelper.formatDateRange(
                                    proj.startDate,
                                    proj.endDate,
                                    isEnglish: isEn,
                                  );
                                  return pw.Container(
                                    margin: const pw.EdgeInsets.only(bottom: 6),
                                    padding: const pw.EdgeInsets.all(6),
                                    decoration: pw.BoxDecoration(
                                      color: cardBg,
                                      borderRadius: pw.BorderRadius.circular(4),
                                    ),
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Row(
                                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Expanded(
                                              child: pw.Text(
                                                PdfTextSanitizer.clean(proj.name),
                                                style: pw.TextStyle(
                                                  fontSize: 8.5,
                                                  fontWeight: pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                            ),
                                            if (dateRange.isNotEmpty)
                                              pw.Text(
                                                dateRange,
                                                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                                              ),
                                          ],
                                        ),
                                        if (proj.role.isNotEmpty) ...[
                                          pw.SizedBox(height: 1),
                                          pw.Text(
                                            PdfTextSanitizer.clean(proj.role),
                                            style: pw.TextStyle(
                                              fontSize: 7.5,
                                              fontWeight: pw.FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                        ],
                                        if (cv.showProjectDescription && proj.description.isNotEmpty) ...[
                                          pw.SizedBox(height: 2),
                                          pw.Text(
                                            PdfTextSanitizer.clean(proj.description),
                                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 8),
                        ],

                        // Education Card
                        if (cv.showEducation && cv.educations.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: cardBg,
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(color: cardBorder, width: 0.8),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildCardTitle('EDUCATION', accentColor),
                                pw.SizedBox(height: 6),
                                ...cv.educations.map((edu) {
                                  final eduDate = DateFormatHelper.formatEducationDate(
                                    edu.graduationYear,
                                    isEnglish: isEn,
                                  );
                                  return pw.Container(
                                    margin: const pw.EdgeInsets.only(bottom: 5),
                                    padding: const pw.EdgeInsets.all(6),
                                    decoration: pw.BoxDecoration(
                                      color: PdfColors.white,
                                      borderRadius: pw.BorderRadius.circular(4),
                                    ),
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Row(
                                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Expanded(
                                              child: pw.Text(
                                                '${PdfTextSanitizer.clean(edu.degree)}${edu.fieldOfStudy.isNotEmpty ? ' in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}' : ''}',
                                                style: pw.TextStyle(
                                                  fontSize: 8.5,
                                                  fontWeight: pw.FontWeight.bold,
                                                  color: PdfColors.black,
                                                ),
                                              ),
                                            ),
                                            pw.Text(
                                              eduDate,
                                              style: pw.TextStyle(
                                                fontSize: 7.5,
                                                fontWeight: pw.FontWeight.bold,
                                                color: accentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        pw.Text(
                                          PdfTextSanitizer.clean(edu.institution),
                                          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                                        ),
                                        if (edu.gpa.isNotEmpty)
                                          pw.Text(
                                            'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                                            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
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

  pw.Widget _buildPillBadge(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
      ),
    );
  }

  pw.Widget _buildCardTitle(String title, PdfColor accentColor) {
    return pw.Row(
      children: [
        pw.Container(
          width: 3.5,
          height: 10,
          color: accentColor,
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
