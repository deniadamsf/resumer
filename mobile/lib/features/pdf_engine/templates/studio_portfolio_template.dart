import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../utils/pdf_text_sanitizer.dart';
import '../utils/social_icon_pdf_widget.dart';
import 'cv_template_interface.dart';

/// Studio Portfolio Creative Template.
/// Creative agency & studio design with spacious editorial typography,
/// architectural photo frame, project showcase callouts, and clean portfolio categorization.
class StudioPortfolioTemplate extends CvTemplate {
  @override
  String get id => 'studio_portfolio';

  @override
  String get nameKey => 'form.template_studio_portfolio';

  @override
  String get descKey => 'form.template_studio_portfolio_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'form.template_score_studio_portfolio';

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
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 30),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Architectural Studio Header
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (photoBytes != null) ...[
                  pw.Container(
                    width: 74,
                    height: 84,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: accentColor, width: 2),
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
                          fontSize: 23,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Row(
                        children: [
                          pw.Text(
                            PdfTextSanitizer.clean(info.professionalTitle).toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color: accentColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (info.location.isNotEmpty) ...[
                            pw.Text('  |  ', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600)),
                            pw.Text(
                              PdfTextSanitizer.clean(info.location),
                              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                            ),
                          ],
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          if (info.email.isNotEmpty)
                            _buildMetaBadge(PdfTextSanitizer.clean(info.email)),
                          if (info.phone.isNotEmpty)
                            _buildMetaBadge(PdfTextSanitizer.clean(info.phone)),
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
            pw.SizedBox(height: 12),
            pw.Container(height: 1.2, color: accentColor),
            pw.SizedBox(height: 12),

            // Profile Statement Callout
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: softTint,
                  border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
                ),
                child: pw.Text(
                  PdfTextSanitizer.clean(cv.summary),
                  style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.3, color: PdfColors.grey800),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
              pw.SizedBox(height: 14),
            ],

            // Two-Column Grid Flow
            pw.Partitions(
              children: [
                // Left Column: Skills, Tools, Languages, Certifications, Interests
                pw.Partition(
                  width: 175,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Skills & Stack
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          _buildSectionHeader('TOOLKIT & SKILLS', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.skills.map((s) {
                            final cleanName = PdfTextSanitizer.clean(s.name);
                            final cleanDesc = PdfTextSanitizer.clean(s.description);
                            final hasDesc = cv.showSkillDescription && cleanDesc.isNotEmpty;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 5),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    cleanName,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  if (hasDesc)
                                    pw.Text(
                                      cleanDesc,
                                      style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                                    ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 10),
                        ],

                        // Languages
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          _buildSectionHeader('LANGUAGES', accentColor),
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
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.grey900,
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                    decoration: pw.BoxDecoration(
                                      color: softTint,
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
                          _buildSectionHeader('CREDENTIALS', accentColor),
                          pw.SizedBox(height: 5),
                          ...cv.certifications.map((c) {
                            final title = PdfTextSanitizer.clean(c.displayTitle);
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
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
                          pw.SizedBox(height: 10),
                        ],

                        // Hobbies
                        if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                          _buildSectionHeader('STUDIO INTERESTS', accentColor),
                          pw.SizedBox(height: 5),
                          pw.Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: cv.hobbies.map((h) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: borderTint, width: 0.6),
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

                // Right Column: Projects (Primary Feature), Work History, Education
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Featured Projects
                        if (cv.showProjects && cv.projects.isNotEmpty) ...[
                          _buildSectionHeader('FEATURED PROJECTS & CASE STUDIES', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.projects.map((proj) {
                            final dateRange = DateFormatHelper.formatDateRange(
                              proj.startDate,
                              proj.endDate,
                              isEnglish: isEn,
                            );
                            return pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 8),
                              padding: const pw.EdgeInsets.all(8),
                              decoration: pw.BoxDecoration(
                                color: softTint,
                                borderRadius: pw.BorderRadius.circular(4),
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
                                            fontSize: 9.5,
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
                                    pw.SizedBox(height: 1.5),
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
                                    pw.SizedBox(height: 2.5),
                                    pw.Text(
                                      PdfTextSanitizer.clean(proj.description),
                                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 6),
                        ],

                        // Work Experience
                        if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                          _buildSectionHeader('CAREER TRAJECTORY', accentColor),
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
                          pw.SizedBox(height: 6),
                        ],

                        // Education
                        if (cv.showEducation && cv.educations.isNotEmpty) ...[
                          _buildSectionHeader('ACADEMICS & EDUCATION', accentColor),
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

  pw.Widget _buildMetaBadge(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
      ),
    );
  }

  pw.Widget _buildSectionHeader(String title, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 8,
              height: 2,
              color: accentColor,
            ),
            pw.SizedBox(width: 4),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: accentColor,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.8, color: tintColor(accentColor, 0.25)),
      ],
    );
  }
}
