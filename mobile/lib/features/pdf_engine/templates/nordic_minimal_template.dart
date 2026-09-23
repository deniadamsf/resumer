import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import '../utils/social_icon_pdf_widget.dart';
import 'cv_template_interface.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';

/// Nordic Minimalist CV Template.
/// Asymmetric Scandinavian clean grid with generous whitespace, hairline rules,
/// and razor-sharp high-contrast typography.
class NordicMinimalTemplate extends CvTemplate {
  @override
  String get id => 'nordic_minimal';

  @override
  String get nameKey => 'form.template_nordic_minimal';

  @override
  String get descKey => 'form.template_nordic_minimal_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'form.template_score_nordic_minimal';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final info = cv.personalInfo;
    final hairlineColor = PdfColor.fromHex('#E2E8F0');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 38, vertical: 36),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Nordic Header: Name on left, photo & contact on right
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
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        PdfTextSanitizer.clean(info.professionalTitle),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      // Inline metadata badges
                      pw.Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (info.email.isNotEmpty)
                            _buildMetaPill(PdfTextSanitizer.clean(info.email)),
                          if (info.phone.isNotEmpty)
                            _buildMetaPill(PdfTextSanitizer.clean(info.phone)),
                          if (info.location.isNotEmpty)
                            _buildMetaPill(PdfTextSanitizer.clean(info.location)),
                          ...SocialIconPdfWidget.buildAllItems(
                            info: info,
                            isAtsMode: false,
                            accentColor: accentColor,
                            textColor: PdfColors.grey700,
                            fontSize: 9.0,
                            iconSize: 8.5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (photoBytes != null) ...[
                  pw.SizedBox(width: 20),
                  pw.Container(
                    width: 72,
                    height: 82,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(6),
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
            pw.SizedBox(height: 16),
            pw.Container(height: 1, color: hairlineColor),
            pw.SizedBox(height: 14),

            // Executive Summary
            if (cv.showSummary && cv.summary.isNotEmpty) ...[
              _buildSectionHeading('PROFILE & SUMMARY', accentColor),
              pw.SizedBox(height: 6),
              pw.Text(
                PdfTextSanitizer.clean(cv.summary),
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.6, color: PdfColors.grey900),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 14),
            ],

            // Work Experience
            if (cv.showExperience && cv.experiences.isNotEmpty) ...[
              _buildSectionHeading('PROFESSIONAL EXPERIENCE', accentColor),
              pw.SizedBox(height: 8),
              ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor, hairlineColor)),
              pw.SizedBox(height: 10),
            ],

            // Education
            if (cv.showEducation && cv.educations.isNotEmpty) ...[
              _buildSectionHeading('EDUCATION & ACADEMICS', accentColor),
              pw.SizedBox(height: 8),
              ...cv.educations.map((edu) => _buildEducationItem(edu, accentColor)),
              pw.SizedBox(height: 10),
            ],

            // Skills & Competencies
            if (cv.showSkills && cv.skills.isNotEmpty) ...[
              _buildSectionHeading('CORE COMPETENCIES & EXPERTISE', accentColor),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cv.skills.map((s) {
                  final cleanName = PdfTextSanitizer.clean(s.name);
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                    ),
                    child: pw.Text(
                      cleanName,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            // Certifications
            if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
              _buildSectionHeading('CERTIFICATIONS & CREDENTIALS', accentColor),
              pw.SizedBox(height: 6),
              ...cv.certifications.map((c) {
                final title = PdfTextSanitizer.clean(c.displayTitle);
                final hasDesc = c.description.trim().isNotEmpty;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      PdfTextSanitizer.buildBulletDot(accentColor, size: 3.5),
                      pw.Expanded(
                        child: pw.Text(
                          hasDesc ? '$title - ${PdfTextSanitizer.clean(c.description)}' : title,
                          style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey900),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 10),
            ],

            // Languages & Hobbies (Clean bottom row)
            if ((cv.showLanguages && cv.languages.isNotEmpty) || (cv.showHobbies && cv.hobbies.isNotEmpty)) ...[
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (cv.showLanguages && cv.languages.isNotEmpty)
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeading('LANGUAGES', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.languages.map((l) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 3),
                                child: pw.Text(
                                  '${PdfTextSanitizer.clean(l.name)} (${PdfTextSanitizer.clean(l.proficiency)})',
                                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                                ),
                              )),
                        ],
                      ),
                    ),
                  if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeading('INTERESTS', accentColor),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            cv.hobbies.map((h) => PdfTextSanitizer.clean(h)).join(' | '),
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSectionHeading(String title, PdfColor accentColor) {
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
        pw.Expanded(
          child: pw.Container(height: 0.8, color: PdfColor.fromHex('#E2E8F0')),
        ),
      ],
    );
  }

  pw.Widget _buildMetaPill(String text) {
    return pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor, PdfColor hairlineColor) {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final dateRange = DateFormatHelper.formatDateRange(exp.startDate, exp.endDate, isEnglish: isEn);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
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
                dateRange,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            PdfTextSanitizer.clean(exp.company),
            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: accentColor),
          ),
          pw.SizedBox(height: 3),
          ...exp.highlights.map((hl) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2.5),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    PdfTextSanitizer.buildBulletDot(accentColor, size: 3.5),
                    pw.Expanded(
                      child: pw.Text(
                        PdfTextSanitizer.clean(hl),
                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800, lineSpacing: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  pw.Widget _buildEducationItem(Education edu, PdfColor accentColor) {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final eduDate = DateFormatHelper.formatEducationDate(edu.graduationYear, isEnglish: isEn);

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
                  '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                ),
                pw.Text(
                  PdfTextSanitizer.clean(edu.institution),
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            eduDate,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }
}
