import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import '../utils/social_icon_pdf_widget.dart';
import 'cv_template_interface.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';

/// Ribbon Banner Professional CV Template.
/// Eye-catching executive layout featuring full-width accent ribbon banners,
/// high-contrast white-on-accent section tags, and star-rated language proficiency.
class RibbonBannerTemplate extends CvTemplate {
  @override
  String get id => 'ribbon_banner';

  @override
  String get nameKey => 'form.template_ribbon_banner';

  @override
  String get descKey => 'form.template_ribbon_banner_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'form.template_score_ribbon_banner';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final softTint = tintColor(accentColor, 0.05);
    final mediumTint = tintColor(accentColor, 0.15);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            // Top Ribbon Banner Container
            pw.Container(
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                          pw.SizedBox(height: 2),
                          pw.Text(
                            PdfTextSanitizer.clean(info.professionalTitle),
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: tintColor(accentColor, 0.7),
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (info.email.isNotEmpty)
                              _buildBannerContact(info.email),
                            if (info.phone.isNotEmpty)
                              _buildBannerContact(info.phone),
                            if (info.location.isNotEmpty)
                              _buildBannerContact(info.location),
                            ...SocialIconPdfWidget.buildAllItems(
                              info: info,
                              isAtsMode: false,
                              accentColor: PdfColors.white,
                              textColor: PdfColors.white,
                              fontSize: 8.0,
                              iconSize: 8.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (photoBytes != null) ...[
                    pw.SizedBox(width: 16),
                    pw.Container(
                      width: 65,
                      height: 65,
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
              _buildRibbonHeader('EXECUTIVE SUMMARY', accentColor),
              pw.SizedBox(height: 5),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: softTint,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  PdfTextSanitizer.clean(cv.summary),
                  style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800, lineSpacing: 1.4),
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // 2-Column Split: Experience + Education on Left (64%), Skills + Languages on Right (36%)
            pw.Partitions(
              children: [
                // Left Column: Experience & Education
                pw.Partition(
                  width: 325,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Experience
                      if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                        _buildRibbonHeader('EXPERIENCE', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor, mediumTint)),
                        pw.SizedBox(height: 10),
                      ],

                      // Education
                      if (cv.showEducation && cv.educations.isNotEmpty) ...[
                        _buildRibbonHeader('EDUCATION', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.educations.map((edu) => _buildEducationItem(edu, accentColor)),
                      ],
                    ],
                  ),
                ),

                pw.Partition(width: 14, child: pw.SizedBox()),

                // Right Column: Skills, Certifications, Languages with Stars, Hobbies
                pw.Partition(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Skills
                      if (cv.showSkills && cv.skills.isNotEmpty) ...[
                        _buildRibbonHeader('CORE SKILLS', accentColor),
                        pw.SizedBox(height: 8),
                        pw.Wrap(
                          spacing: 4,
                          runSpacing: 5,
                          children: cv.skills.map((s) {
                            return pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                              decoration: pw.BoxDecoration(
                                color: softTint,
                                borderRadius: pw.BorderRadius.circular(4),
                                border: pw.Border.all(color: tintColor(accentColor, 0.25), width: 0.8),
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
                        pw.SizedBox(height: 12),
                      ],

                      // Certifications
                      if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                        _buildRibbonHeader('CERTIFICATIONS', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.certifications.map((cert) {
                          final title = PdfTextSanitizer.clean(cert.displayTitle);
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
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
                        _buildRibbonHeader('LANGUAGES', accentColor),
                        pw.SizedBox(height: 8),
                        ...cv.languages.map((l) {
                          final cleanName = PdfTextSanitizer.clean(l.name);
                          final cleanProf = PdfTextSanitizer.clean(l.proficiency);
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
                        _buildRibbonHeader('INTERESTS', accentColor),
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

  pw.Widget _buildBannerContact(String text) {
    return pw.Text(
      PdfTextSanitizer.clean(text),
      style: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
    );
  }

  pw.Widget _buildRibbonHeader(String title, PdfColor accentColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: pw.BoxDecoration(
        color: accentColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor, PdfColor badgeBg) {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final dateRange = DateFormatHelper.formatDateRange(exp.startDate, exp.endDate, isEnglish: isEn);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
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
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: pw.BoxDecoration(
                  color: badgeBg,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  dateRange,
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: accentColor),
                  textAlign: pw.TextAlign.right,
                ),
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
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                ),
                pw.Text(
                  PdfTextSanitizer.clean(edu.institution),
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
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
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                textAlign: pw.TextAlign.right,
              ),
              if (edu.gpa.trim().isNotEmpty)
                pw.Text(
                  'GPA: ${PdfTextSanitizer.clean(edu.gpa)}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.right,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
