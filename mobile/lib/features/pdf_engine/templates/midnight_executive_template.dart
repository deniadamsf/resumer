import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../utils/pdf_text_sanitizer.dart';
import '../utils/social_icon_pdf_widget.dart';
import 'cv_template_interface.dart';

/// Midnight Executive Creative Template.
/// Commanding full-bleed dark accent hero header block transitioning
/// into an elegant dual-column body with a delicately tinted sidebar.
class MidnightExecutiveTemplate extends CvTemplate {
  @override
  String get id => 'midnight_executive';

  @override
  String get nameKey => 'form.template_midnight_executive';

  @override
  String get descKey => 'form.template_midnight_executive_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'form.template_score_midnight_executive';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final sidebarTint = tintColor(accentColor, 0.04);
    final borderTint = tintColor(accentColor, 0.22);
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Dark Accent Hero Banner
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (photoBytes != null) ...[
                    pw.Container(
                      width: 72,
                      height: 82,
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColors.white, width: 2),
                        image: pw.DecorationImage(
                          image: pw.MemoryImage(photoBytes),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),
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
                            color: PdfColors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          PdfTextSanitizer.clean(info.professionalTitle),
                          style: pw.TextStyle(
                            fontSize: 11.5,
                            fontWeight: pw.FontWeight.bold,
                            color: tintColor(accentColor, 0.8),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            if (info.email.isNotEmpty)
                              _buildWhiteHeaderPill(PdfTextSanitizer.clean(info.email)),
                            if (info.phone.isNotEmpty)
                              _buildWhiteHeaderPill(PdfTextSanitizer.clean(info.phone)),
                            if (info.location.isNotEmpty)
                              _buildWhiteHeaderPill(PdfTextSanitizer.clean(info.location)),
                            if (cv.showSocialLinks)
                              SocialIconPdfWidget.buildWrapList(
                                info: info,
                                isAtsMode: false,
                                accentColor: PdfColors.white,
                                textColor: PdfColors.white,
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
            pw.SizedBox(height: 14),

            // Two-Column Body Layout
            pw.Partitions(
              children: [
                // Left Column: Tinted Sidebar
                pw.Partition(
                  width: 180,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: sidebarTint,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: borderTint, width: 0.8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Skills
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          _buildSidebarHeading('CORE EXPERTISE', accentColor),
                          pw.SizedBox(height: 5),
                          ...cv.skills.map((s) {
                            final cleanName = PdfTextSanitizer.clean(s.name);
                            final cleanDesc = PdfTextSanitizer.clean(s.description);
                            final hasDesc = cv.showSkillDescription && cleanDesc.isNotEmpty;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4.5),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 4,
                                    height: 4,
                                    margin: const pw.EdgeInsets.only(top: 3.5, right: 5),
                                    decoration: pw.BoxDecoration(
                                      shape: pw.BoxShape.circle,
                                      color: accentColor,
                                    ),
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
                                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 8),
                        ],

                        // Languages
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          _buildSidebarHeading('LANGUAGES', accentColor),
                          pw.SizedBox(height: 5),
                          ...cv.languages.map((l) {
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3.5),
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
                                    style: pw.TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 8),
                        ],

                        // Certifications
                        if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                          _buildSidebarHeading('CERTIFICATIONS', accentColor),
                          pw.SizedBox(height: 5),
                          ...cv.certifications.map((c) {
                            final title = PdfTextSanitizer.clean(c.displayTitle);
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3.5),
                              child: pw.Text(
                                title,
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey900,
                                ),
                              ),
                            );
                          }),
                          pw.SizedBox(height: 8),
                        ],

                        // Hobbies
                        if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                          _buildSidebarHeading('INTERESTS', accentColor),
                          pw.SizedBox(height: 5),
                          pw.Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: cv.hobbies.map((h) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.white,
                                  borderRadius: pw.BorderRadius.circular(3),
                                  border: pw.Border.all(color: borderTint, width: 0.6),
                                ),
                                child: pw.Text(
                                  PdfTextSanitizer.clean(h),
                                  style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right Column: Summary, Experience, Projects, Education
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 14),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Executive Summary
                        if (cv.showSummary && cv.summary.isNotEmpty) ...[
                          _buildBodyHeading('EXECUTIVE SUMMARY', accentColor),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            PdfTextSanitizer.clean(cv.summary),
                            style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.3, color: PdfColors.grey800),
                            textAlign: pw.TextAlign.justify,
                          ),
                          pw.SizedBox(height: 12),
                        ],

                        // Experience
                        if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                          _buildBodyHeading('PROFESSIONAL EXPERIENCE', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.experiences.map((exp) {
                            final dateRange = DateFormatHelper.formatDateRange(
                              exp.startDate,
                              exp.endDate,
                              isEnglish: isEn,
                            );
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 10),
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
                                    pw.SizedBox(height: 3),
                                    ...exp.highlights.map((h) {
                                      return pw.Padding(
                                        padding: const pw.EdgeInsets.only(bottom: 2),
                                        child: pw.Row(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Container(
                                              width: 3,
                                              height: 3,
                                              margin: const pw.EdgeInsets.only(top: 3.5, right: 5),
                                              color: accentColor,
                                            ),
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
                          pw.SizedBox(height: 4),
                        ],

                        // Projects
                        if (cv.showProjects && cv.projects.isNotEmpty) ...[
                          _buildBodyHeading('KEY INITIATIVES & PROJECTS', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.projects.map((proj) {
                            final dateRange = DateFormatHelper.formatDateRange(
                              proj.startDate,
                              proj.endDate,
                              isEnglish: isEn,
                            );
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 7),
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
                                            fontSize: 9,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ),
                                      if (dateRange.isNotEmpty)
                                        pw.Text(
                                          dateRange,
                                          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                                        ),
                                    ],
                                  ),
                                  if (proj.role.isNotEmpty) ...[
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      PdfTextSanitizer.clean(proj.role),
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        fontWeight: pw.FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                  if (cv.showProjectDescription && proj.description.isNotEmpty) ...[
                                    pw.SizedBox(height: 2),
                                    pw.Text(
                                      PdfTextSanitizer.clean(proj.description),
                                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 4),
                        ],

                        // Education
                        if (cv.showEducation && cv.educations.isNotEmpty) ...[
                          _buildBodyHeading('EDUCATION', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.educations.map((edu) {
                            final eduDate = DateFormatHelper.formatEducationDate(
                              edu.graduationYear,
                              isEnglish: isEn,
                            );
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
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
                                            fontSize: 9,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                        pw.Text(
                                          PdfTextSanitizer.clean(edu.institution),
                                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                                        ),
                                        if (edu.gpa.isNotEmpty)
                                          pw.Text(
                                            'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                                            style: pw.TextStyle(
                                              fontSize: 7.5,
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
                                      fontSize: 8,
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

  pw.Widget _buildWhiteHeaderPill(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: pw.BoxDecoration(
        color: const PdfColor(1, 1, 1, 0.15),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.white),
      ),
    );
  }

  pw.Widget _buildSidebarHeading(String text, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, color: tintColor(accentColor, 0.3)),
      ],
    );
  }

  pw.Widget _buildBodyHeading(String text, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(width: 4, height: 10, color: accentColor),
            pw.SizedBox(width: 5),
            pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: 9.5,
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
