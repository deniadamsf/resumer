import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../utils/pdf_text_sanitizer.dart';
import '../utils/social_icon_pdf_widget.dart';
import 'cv_template_interface.dart';

/// Infographic Modern Creative Template.
/// Modern visual timeline layout featuring milestone node dots,
/// visual proficiency meters, metric highlight cards, and rich visual data hierarchy.
class InfographicModernTemplate extends CvTemplate {
  @override
  String get id => 'infographic_modern';

  @override
  String get nameKey => 'form.template_infographic_modern';

  @override
  String get descKey => 'form.template_infographic_modern_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'form.template_score_infographic_modern';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final softTint = tintColor(accentColor, 0.05);
    final borderTint = tintColor(accentColor, 0.22);
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Top Infographic Header Card
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: softTint,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderTint, width: 1),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (photoBytes != null) ...[
                    pw.Container(
                      width: 68,
                      height: 78,
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
                              _buildHeaderPill(PdfTextSanitizer.clean(info.email), accentColor),
                            if (info.phone.isNotEmpty)
                              _buildHeaderPill(PdfTextSanitizer.clean(info.phone), accentColor),
                            if (info.location.isNotEmpty)
                              _buildHeaderPill(PdfTextSanitizer.clean(info.location), accentColor),
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
            pw.SizedBox(height: 14),

            // Two-Column Infographic Layout
            pw.Partitions(
              children: [
                // Left Column: Skills Progress, Languages, Certifications, Hobbies
                pw.Partition(
                  width: 175,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Skills & Visual Meters
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          _buildSectionTitle('CORE COMPETENCIES', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.skills.map((s) {
                            final cleanName = PdfTextSanitizer.clean(s.name);
                            final cleanDesc = PdfTextSanitizer.clean(s.description);
                            final hasDesc = cv.showSkillDescription && cleanDesc.isNotEmpty;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Text(
                                          cleanName,
                                          style: pw.TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.grey900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (hasDesc) ...[
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      cleanDesc,
                                      style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                                    ),
                                  ] else ...[
                                    pw.SizedBox(height: 3),
                                    // Visual 5-segment rating dots
                                    pw.Row(
                                      children: List.generate(5, (index) {
                                        final isFilled = index < 4; // 80-100% aesthetic rating
                                        return pw.Container(
                                          width: 6,
                                          height: 6,
                                          margin: const pw.EdgeInsets.only(right: 3),
                                          decoration: pw.BoxDecoration(
                                            shape: pw.BoxShape.circle,
                                            color: isFilled ? accentColor : tintColor(accentColor, 0.2),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 10),
                        ],

                        // Languages with Visual Badges
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          _buildSectionTitle('LANGUAGES', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.languages.map((l) {
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 5),
                              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                              decoration: pw.BoxDecoration(
                                color: softTint,
                                borderRadius: pw.BorderRadius.circular(4),
                                border: pw.Border.all(color: borderTint, width: 0.6),
                              ),
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
                          pw.SizedBox(height: 10),
                        ],

                        // Certifications Cards
                        if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                          _buildSectionTitle('CREDENTIALS', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.certifications.map((c) {
                            final title = PdfTextSanitizer.clean(c.displayTitle);
                            final hasDesc = cv.showCertificationDescription && c.description.trim().isNotEmpty;
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 5),
                              padding: const pw.EdgeInsets.all(5),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(4),
                                border: pw.Border.all(color: borderTint, width: 0.8),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    title,
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.grey900,
                                    ),
                                  ),
                                  if (hasDesc) ...[
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      PdfTextSanitizer.clean(c.description),
                                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 10),
                        ],

                        // Interests / Hobbies
                        if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                          _buildSectionTitle('INTERESTS', accentColor),
                          pw.SizedBox(height: 5),
                          pw.Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: cv.hobbies.map((h) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  color: softTint,
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                                child: pw.Text(
                                  PdfTextSanitizer.clean(h),
                                  style: pw.TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accentColor,
                                  ),
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

                // Right Column: Summary & Visual Milestone Timeline
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Executive Summary
                        if (cv.showSummary && cv.summary.isNotEmpty) ...[
                          _buildSectionTitle('EXECUTIVE PROFILE', accentColor),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: softTint,
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Text(
                              PdfTextSanitizer.clean(cv.summary),
                              style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.3, color: PdfColors.grey800),
                              textAlign: pw.TextAlign.justify,
                            ),
                          ),
                          pw.SizedBox(height: 12),
                        ],

                        // Experience Timeline
                        if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                          _buildSectionTitle('CAREER MILESTONES', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.experiences.map((exp) {
                            final dateRange = DateFormatHelper.formatDateRange(
                              exp.startDate,
                              exp.endDate,
                              isEnglish: isEn,
                            );
                            return pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Timeline Node Pillar
                                pw.Column(
                                  children: [
                                    pw.Container(
                                      width: 8,
                                      height: 8,
                                      margin: const pw.EdgeInsets.only(top: 2),
                                      decoration: pw.BoxDecoration(
                                        shape: pw.BoxShape.circle,
                                        color: accentColor,
                                      ),
                                    ),
                                    pw.Container(
                                      width: 1.5,
                                      height: 40,
                                      color: borderTint,
                                    ),
                                  ],
                                ),
                                pw.SizedBox(width: 8),
                                // Timeline Content
                                pw.Expanded(
                                  child: pw.Padding(
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
                                            pw.Container(
                                              padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: pw.BoxDecoration(
                                                color: softTint,
                                                borderRadius: pw.BorderRadius.circular(3),
                                              ),
                                              child: pw.Text(
                                                dateRange,
                                                style: pw.TextStyle(
                                                  fontSize: 7.5,
                                                  fontWeight: pw.FontWeight.bold,
                                                  color: accentColor,
                                                ),
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
                                                  PdfTextSanitizer.buildBulletDot(accentColor, size: 2.5),
                                                  pw.Expanded(
                                                    child: pw.Text(
                                                      PdfTextSanitizer.clean(h),
                                                      style: const pw.TextStyle(
                                                        fontSize: 8,
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
                                  ),
                                ),
                              ],
                            );
                          }),
                          pw.SizedBox(height: 4),
                        ],

                        // Projects
                        if (cv.showProjects && cv.projects.isNotEmpty) ...[
                          _buildSectionTitle('KEY INITIATIVES & PROJECTS', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.projects.map((proj) {
                            final dateRange = DateFormatHelper.formatDateRange(
                              proj.startDate,
                              proj.endDate,
                              isEnglish: isEn,
                            );
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 7),
                              padding: const pw.EdgeInsets.all(7),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(5),
                                border: pw.Border.all(color: borderTint, width: 0.8),
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
                          _buildSectionTitle('EDUCATION & ACADEMICS', accentColor),
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

  pw.Widget _buildHeaderPill(String text, PdfColor accentColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: tintColor(accentColor, 0.2), width: 0.8),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 7.5,
          color: PdfColors.grey800,
        ),
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: accentColor,
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: accentColor,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: 0.8, color: tintColor(accentColor, 0.2)),
      ],
    );
  }
}
