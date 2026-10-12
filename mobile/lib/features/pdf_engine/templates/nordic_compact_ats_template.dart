import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../utils/pdf_text_sanitizer.dart';
import '../utils/social_icon_pdf_widget.dart';
import 'cv_template_interface.dart';

/// Nordic Compact ATS Template
/// Minimalist Scandinavian aesthetic with a compact portrait photo badge,
/// high space efficiency, and crisp ATS-optimized typography.
/// 100% ATS parser compliant (Expected score: 94-98).
class NordicCompactAtsTemplate extends CvTemplate {
  @override
  String get id => 'nordic_compact_ats';

  @override
  String get nameKey => 'form.template_nordic_compact_ats';

  @override
  String get descKey => 'form.template_nordic_compact_ats_desc';

  @override
  bool get isAtsFriendly => true;

  @override
  String get atsScoreRange => 'form.template_score_nordic_compact_ats';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 34, vertical: 32),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Candidate Header with Compact Photo
            _buildHeader(cv, photoBytes, accentColor),
            pw.SizedBox(height: 8),

            // Subtle Minimalist Hairline Divider
            pw.Container(height: 0.8, color: accentColor),
            pw.SizedBox(height: 10),

            // Executive Summary
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              _buildSectionTitle('PROFESSIONAL PROFILE', accentColor),
              pw.SizedBox(height: 4),
              pw.Text(
                PdfTextSanitizer.clean(cv.summary),
                style: const pw.TextStyle(fontSize: 9.2, lineSpacing: 1.25),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 9),
            ],

            // Work Experience
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildSectionTitle('EXPERIENCE', accentColor),
              pw.SizedBox(height: 4),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
              pw.SizedBox(height: 6),
            ],

            // Education
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              _buildSectionTitle('EDUCATION', accentColor),
              pw.SizedBox(height: 4),
              ...cv.educations.map((edu) => _buildEducationItem(edu, accentColor)),
              pw.SizedBox(height: 6),
            ],

            // Core Competencies & Skills
            if (cv.showSkills && cv.skills.isNotEmpty) ...[
              _buildSectionTitle('SKILLS & EXPERTISE', accentColor),
              pw.SizedBox(height: 4),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cv.skills.map((skill) {
                  final hasDesc = cv.showSkillDescription && skill.description.trim().isNotEmpty;
                  final cleanName = PdfTextSanitizer.clean(skill.name);
                  final cleanDesc = PdfTextSanitizer.clean(skill.description);
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2.5),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        PdfTextSanitizer.buildBulletDot(accentColor, size: 3.0),
                        pw.Expanded(
                          child: hasDesc
                              ? pw.RichText(
                                  text: pw.TextSpan(
                                    children: [
                                      pw.TextSpan(
                                        text: '$cleanName: ',
                                        style: pw.TextStyle(
                                          fontSize: 9.2,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.grey900,
                                        ),
                                      ),
                                      pw.TextSpan(
                                        text: cleanDesc,
                                        style: const pw.TextStyle(fontSize: 9.2, color: PdfColors.grey800),
                                      ),
                                    ],
                                  ),
                                )
                              : pw.Text(cleanName, style: const pw.TextStyle(fontSize: 9.2)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 6),
            ],

            // Certifications
            if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
              _buildSectionTitle('CERTIFICATIONS', accentColor),
              pw.SizedBox(height: 4),
              ...cv.certifications.map((cert) {
                final title = PdfTextSanitizer.clean(cert.displayTitle);
                final hasDesc = cv.showCertificationDescription && cert.description.trim().isNotEmpty;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2.5),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      PdfTextSanitizer.buildBulletDot(accentColor, size: 3.0),
                      pw.Expanded(
                        child: hasDesc
                            ? pw.RichText(
                                text: pw.TextSpan(
                                  children: [
                                    pw.TextSpan(
                                      text: '$title - ',
                                      style: pw.TextStyle(
                                        fontSize: 9.2,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.grey900,
                                      ),
                                    ),
                                    pw.TextSpan(
                                      text: PdfTextSanitizer.clean(cert.description),
                                      style: const pw.TextStyle(fontSize: 9.2, color: PdfColors.grey800),
                                    ),
                                  ],
                                ),
                              )
                            : pw.Text(title, style: const pw.TextStyle(fontSize: 9.2)),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 6),
            ],

            // Projects
            if (cv.showProjects && cv.projects.isNotEmpty) ...[
              _buildSectionTitle('PROJECTS', accentColor),
              pw.SizedBox(height: 4),
              ...cv.projects.map((proj) => _buildProjectItem(proj, accentColor, cv.showProjectDescription)),
              pw.SizedBox(height: 6),
            ],

            // Languages
            if (cv.showLanguages && cv.languages.isNotEmpty) ...[
              _buildSectionTitle('LANGUAGES', accentColor),
              pw.SizedBox(height: 3),
              pw.Text(
                cv.languages
                    .map((l) => '${PdfTextSanitizer.clean(l.name)} (${PdfTextSanitizer.clean(l.proficiency)})')
                    .join('   |   '),
                style: const pw.TextStyle(fontSize: 9.2, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 6),
            ],

            // Hobbies & Interests
            if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
              _buildSectionTitle('INTERESTS', accentColor),
              pw.SizedBox(height: 3),
              pw.Text(
                cv.hobbies.map((h) => PdfTextSanitizer.clean(h)).join('   |   '),
                style: const pw.TextStyle(fontSize: 9.2, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 6),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(CvDocument cv, Uint8List? photoBytes, PdfColor accentColor) {
    final info = cv.personalInfo;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(info.fullName).toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1.1,
                ),
              ),
              if (info.professionalTitle.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  PdfTextSanitizer.clean(info.professionalTitle),
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Text(
                [
                  if (info.location.isNotEmpty) PdfTextSanitizer.clean(info.location),
                  if (info.phone.isNotEmpty) PdfTextSanitizer.clean(info.phone),
                  if (info.email.isNotEmpty) PdfTextSanitizer.clean(info.email),
                ].join('   *   '),
                style: const pw.TextStyle(fontSize: 8.8, color: PdfColors.grey700),
              ),
              if (cv.showSocialLinks) ...[
                pw.SizedBox(height: 2.5),
                SocialIconPdfWidget.buildWrapList(
                  info: info,
                  isAtsMode: true,
                  textColor: PdfColors.blue800,
                  fontSize: 8.3,
                  spacing: 7.0,
                  runSpacing: 2.0,
                ),
              ],
            ],
          ),
        ),
        if (photoBytes != null) ...[
          pw.SizedBox(width: 12),
          pw.Container(
            width: 58,
            height: 68,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
              image: pw.DecorationImage(
                image: pw.MemoryImage(photoBytes),
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          PdfTextSanitizer.clean(title).toUpperCase(),
          style: pw.TextStyle(
            fontSize: 10.2,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 1.0,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.7, color: PdfColors.grey400),
      ],
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor) {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final dateRange = DateFormatHelper.formatDateRange(exp.startDate, exp.endDate, isEnglish: isEn);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
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
                dateRange,
                style: const pw.TextStyle(fontSize: 8.8, color: PdfColors.grey700),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.Text(
            PdfTextSanitizer.clean(exp.company),
            style: const pw.TextStyle(
              fontSize: 9.2,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 2),
          ...exp.highlights.map(
            (hl) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PdfTextSanitizer.buildBulletDot(accentColor, size: 3.0),
                  pw.Expanded(
                    child: pw.Text(
                      PdfTextSanitizer.clean(hl),
                      style: const pw.TextStyle(fontSize: 9.2, lineSpacing: 1.2),
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
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final eduDate = DateFormatHelper.formatEducationDate(edu.graduationYear, isEnglish: isEn);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
                  style: pw.TextStyle(fontSize: 9.8, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  PdfTextSanitizer.clean(edu.institution),
                  style: const pw.TextStyle(fontSize: 8.8, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                eduDate,
                style: const pw.TextStyle(fontSize: 8.8, color: PdfColors.grey700),
                textAlign: pw.TextAlign.right,
              ),
              if (edu.gpa.trim().isNotEmpty)
                pw.Text(
                  'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                  style: const pw.TextStyle(fontSize: 8.3, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.right,
                ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectItem(ProjectItem proj, PdfColor accentColor, bool showDesc) {
    final cleanName = PdfTextSanitizer.clean(proj.name);
    final cleanRole = PdfTextSanitizer.clean(proj.role);
    final period = PdfTextSanitizer.clean(proj.displayPeriod);
    final cleanDesc = PdfTextSanitizer.clean(proj.description);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4.5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: cleanName,
                        style: pw.TextStyle(
                          fontSize: 9.8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey900,
                        ),
                      ),
                      if (cleanRole.isNotEmpty)
                        pw.TextSpan(
                          text: ' | $cleanRole',
                          style: const pw.TextStyle(
                            fontSize: 9.2,
                            color: PdfColors.grey800,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (period.isNotEmpty) ...[
                pw.SizedBox(width: 8),
                pw.Text(
                  period,
                  style: const pw.TextStyle(fontSize: 8.8, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.right,
                ),
              ],
            ],
          ),
          if (showDesc && cleanDesc.isNotEmpty) ...[
            pw.SizedBox(height: 1.5),
            pw.Text(
              cleanDesc,
              style: const pw.TextStyle(fontSize: 9.2, color: PdfColors.grey800),
              textAlign: pw.TextAlign.justify,
            ),
          ],
        ],
      ),
    );
  }
}
