import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../utils/pdf_text_sanitizer.dart';
import '../utils/social_icon_pdf_widget.dart';
import 'cv_template_interface.dart';

/// Swiss High Contrast Creative Template.
/// Inspired by the International Typographic Style (Swiss Style):
/// Asymmetric 2-column grid, bold geometric rules, high visual contrast,
/// and razor-sharp typographic hierarchy.
class SwissHighContrastTemplate extends CvTemplate {
  @override
  String get id => 'swiss_high_contrast';

  @override
  String get nameKey => 'form.template_swiss_high_contrast';

  @override
  String get descKey => 'form.template_swiss_high_contrast_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'form.template_score_swiss_high_contrast';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Top Swiss Header
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                          color: PdfColors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        PdfTextSanitizer.clean(info.professionalTitle).toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (photoBytes != null) ...[
                  pw.SizedBox(width: 16),
                  pw.Container(
                    width: 72,
                    height: 82,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(2),
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
            pw.SizedBox(height: 8),
            // Heavy Solid Accent Rule
            pw.Container(height: 3.5, color: accentColor),
            pw.SizedBox(height: 14),

            // Asymmetric 2-Column Body
            pw.Partitions(
              children: [
                // Left Column: Metadata, Contact, Skills, Languages, Hobbies
                pw.Partition(
                  width: 175,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 14),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Contact Section
                        _buildLeftHeading('CONTACT', accentColor),
                        pw.SizedBox(height: 5),
                        if (info.email.isNotEmpty)
                          _buildLeftMetaItem('EMAIL', PdfTextSanitizer.clean(info.email)),
                        if (info.phone.isNotEmpty)
                          _buildLeftMetaItem('PHONE', PdfTextSanitizer.clean(info.phone)),
                        if (info.location.isNotEmpty)
                          _buildLeftMetaItem('LOCATION', PdfTextSanitizer.clean(info.location)),
                        if (cv.showSocialLinks) ...[
                          pw.SizedBox(height: 4),
                          SocialIconPdfWidget.buildWrapList(
                            info: info,
                            isAtsMode: false,
                            accentColor: accentColor,
                            textColor: PdfColors.grey900,
                            fontSize: 8,
                            iconSize: 8.5,
                            spacing: 6,
                            runSpacing: 4,
                          ),
                          pw.SizedBox(height: 10),
                        ],

                        // Core Skills
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          _buildLeftHeading('EXPERTISE & SKILLS', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.skills.map((s) {
                            final cleanName = PdfTextSanitizer.clean(s.name);
                            final cleanDesc = PdfTextSanitizer.clean(s.description);
                            final hasDesc = cv.showSkillDescription && cleanDesc.isNotEmpty;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 5),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 4,
                                    height: 4,
                                    margin: const pw.EdgeInsets.only(top: 3.5, right: 5),
                                    color: accentColor,
                                  ),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          cleanName,
                                          style: pw.TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.grey900,
                                          ),
                                        ),
                                        if (hasDesc)
                                          pw.Text(
                                            cleanDesc,
                                            style: const pw.TextStyle(
                                              fontSize: 7.5,
                                              color: PdfColors.grey700,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 10),
                        ],

                        // Languages
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          _buildLeftHeading('LANGUAGES', accentColor),
                          pw.SizedBox(height: 5),
                          ...cv.languages.map((l) {
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    PdfTextSanitizer.clean(l.name),
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.grey900,
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                    decoration: pw.BoxDecoration(
                                      color: tintColor(accentColor, 0.08),
                                      borderRadius: pw.BorderRadius.circular(2),
                                    ),
                                    child: pw.Text(
                                      PdfTextSanitizer.clean(l.proficiency),
                                      style: pw.TextStyle(
                                        fontSize: 7,
                                        fontWeight: pw.FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 10),
                        ],

                        // Certifications
                        if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                          _buildLeftHeading('CERTIFICATIONS', accentColor),
                          pw.SizedBox(height: 5),
                          ...cv.certifications.map((cert) {
                            final title = PdfTextSanitizer.clean(cert.displayTitle);
                            final hasDesc = cv.showCertificationDescription && cert.description.trim().isNotEmpty;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 5),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    title,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.grey900,
                                    ),
                                  ),
                                  if (hasDesc)
                                    pw.Text(
                                      PdfTextSanitizer.clean(cert.description),
                                      style: const pw.TextStyle(
                                        fontSize: 7.5,
                                        color: PdfColors.grey700,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 10),
                        ],

                        // Hobbies
                        if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                          _buildLeftHeading('INTERESTS', accentColor),
                          pw.SizedBox(height: 5),
                          pw.Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: cv.hobbies.map((h) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                                  borderRadius: pw.BorderRadius.circular(2),
                                ),
                                child: pw.Text(
                                  PdfTextSanitizer.clean(h),
                                  style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                ),
                              );
                            }).toList(),
                          ),
                          pw.SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right Column: Summary, Work Experience, Projects, Education
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Professional Summary
                        if (cv.showSummary && cv.summary.isNotEmpty) ...[
                          _buildRightHeading('EXECUTIVE SUMMARY', accentColor),
                          pw.SizedBox(height: 5),
                          pw.Container(
                            padding: const pw.EdgeInsets.only(left: 8),
                            decoration: pw.BoxDecoration(
                              border: pw.Border(left: pw.BorderSide(color: accentColor, width: 2.5)),
                            ),
                            child: pw.Text(
                              PdfTextSanitizer.clean(cv.summary),
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey800,
                                lineSpacing: 1.3,
                              ),
                              textAlign: pw.TextAlign.justify,
                            ),
                          ),
                          pw.SizedBox(height: 14),
                        ],

                        // Work Experience
                        if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                          _buildRightHeading('PROFESSIONAL EXPERIENCE', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.experiences.map((exp) {
                            final dateRange = DateFormatHelper.formatDateRange(
                              exp.startDate,
                              exp.endDate,
                              isEnglish: isEn,
                            );
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 11),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          PdfTextSanitizer.clean(exp.position).toUpperCase(),
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ),
                                      pw.Text(
                                        dateRange,
                                        style: pw.TextStyle(
                                          fontSize: 8.5,
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
                                        padding: const pw.EdgeInsets.only(bottom: 2.5),
                                        child: pw.Row(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(
                                              width: 3.5,
                                              height: 3.5,
                                              margin: const pw.EdgeInsets.only(top: 3.5, right: 6),
                                              color: accentColor,
                                            ),
                                            pw.Expanded(
                                              child: pw.Text(
                                                PdfTextSanitizer.clean(h),
                                                style: const pw.TextStyle(
                                                  fontSize: 8.5,
                                                  color: PdfColors.grey800,
                                                  lineSpacing: 1.2,
                                                ),
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
                          pw.SizedBox(height: 6),
                        ],

                        // Projects
                        if (cv.showProjects && cv.projects.isNotEmpty) ...[
                          _buildRightHeading('KEY PROJECTS & PORTFOLIO', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.projects.map((proj) {
                            final dateRange = DateFormatHelper.formatDateRange(
                              proj.startDate,
                              proj.endDate,
                              isEnglish: isEn,
                            );
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 9),
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
                                            fontSize: 9.5,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ),
                                      if (dateRange.isNotEmpty)
                                        pw.Text(
                                          dateRange,
                                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                                        ),
                                    ],
                                  ),
                                  if (proj.role.isNotEmpty) ...[
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      PdfTextSanitizer.clean(proj.role),
                                      style: pw.TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                  if (cv.showProjectDescription && proj.description.isNotEmpty) ...[
                                    pw.SizedBox(height: 2),
                                    pw.Text(
                                      PdfTextSanitizer.clean(proj.description),
                                      style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 6),
                        ],

                        // Education
                        if (cv.showEducation && cv.educations.isNotEmpty) ...[
                          _buildRightHeading('EDUCATION', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.educations.map((edu) {
                            final eduDate = DateFormatHelper.formatEducationDate(
                              edu.graduationYear,
                              isEnglish: isEn,
                            );
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          '${PdfTextSanitizer.clean(edu.degree)}${edu.fieldOfStudy.isNotEmpty ? ' in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}' : ''}',
                                          style: pw.TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          PdfTextSanitizer.clean(edu.institution),
                                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                                        ),
                                        if (edu.gpa.isNotEmpty)
                                          pw.Text(
                                            'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              fontWeight: pw.FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  pw.Text(
                                    eduDate,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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

  pw.Widget _buildLeftHeading(String text, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, color: PdfColors.grey300),
      ],
    );
  }

  pw.Widget _buildLeftMetaItem(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 6.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRightHeading(String text, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(width: 4, height: 11, color: accentColor),
            pw.SizedBox(width: 5),
            pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: 0.8, color: PdfColors.grey300),
      ],
    );
  }
}
