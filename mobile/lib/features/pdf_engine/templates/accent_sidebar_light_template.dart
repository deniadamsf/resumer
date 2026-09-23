import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/utils/social_link_helper.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

/// Corporate Clean Light Rail CV Template.
/// 2-Column layout with a light pearl side-rail (#F8FAFC) bounded by a vertical
/// accent color stripe, ensuring 100% daylight legibility and zero contrast bugs.
class AccentSidebarLightTemplate extends CvTemplate {
  @override
  String get id => 'accent_sidebar_light';

  @override
  String get nameKey => 'form.template_accent_sidebar_light';

  @override
  String get descKey => 'form.template_accent_sidebar_light_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'Korporat / Konsultan';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final lightSidebarBg = PdfColor.fromHex('#F8FAFC');
    final stripeColor = accentColor;
    final info = cv.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          buildBackground: (pw.Context context) {
            return pw.Row(
              children: [
                pw.Container(
                  width: 190,
                  color: lightSidebarBg,
                ),
                pw.Container(
                  width: 3.5,
                  color: stripeColor,
                ),
              ],
            );
          },
        ),
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            pw.Partitions(
              children: [
                // Left Column: Light Side-Rail (Photo, Contact, Skills, Languages, Hobbies)
                pw.Partition(
                  width: 190,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Profile Photo
                        if (photoBytes != null) ...[
                          pw.Center(
                            child: pw.Container(
                              width: 86,
                              height: 86,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                border: pw.Border.all(color: accentColor, width: 2),
                                image: pw.DecorationImage(
                                  image: pw.MemoryImage(photoBytes),
                                  fit: pw.BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 18),
                        ],

                        // Contact Details
                        _buildSectionLabel('CONTACT INFO', accentColor),
                        pw.SizedBox(height: 6),
                        if (info.email.isNotEmpty)
                          _buildContactRow('Email', PdfTextSanitizer.clean(info.email)),
                        if (info.phone.isNotEmpty)
                          _buildContactRow('Phone', PdfTextSanitizer.clean(info.phone)),
                        if (info.location.isNotEmpty)
                          _buildContactRow('Location', PdfTextSanitizer.clean(info.location)),
                        if (_buildSocialContactRow(SocialPlatform.linkedin, info.linkedin, accentColor) != null)
                          _buildSocialContactRow(SocialPlatform.linkedin, info.linkedin, accentColor)!,
                        if (_buildSocialContactRow(SocialPlatform.github, info.github, accentColor) != null)
                          _buildSocialContactRow(SocialPlatform.github, info.github, accentColor)!,
                        if (_buildSocialContactRow(SocialPlatform.website, info.website, accentColor) != null)
                          _buildSocialContactRow(SocialPlatform.website, info.website, accentColor)!,
                        if (_buildSocialContactRow(SocialPlatform.whatsapp, info.whatsapp, accentColor) != null)
                          _buildSocialContactRow(SocialPlatform.whatsapp, info.whatsapp, accentColor)!,
                        if (_buildSocialContactRow(SocialPlatform.instagram, info.instagram, accentColor) != null)
                          _buildSocialContactRow(SocialPlatform.instagram, info.instagram, accentColor)!,
                        if (_buildSocialContactRow(SocialPlatform.facebook, info.facebook, accentColor) != null)
                          _buildSocialContactRow(SocialPlatform.facebook, info.facebook, accentColor)!,
                        pw.SizedBox(height: 16),

                        // Skills
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          _buildSectionLabel('EXPERTISE', accentColor),
                          pw.SizedBox(height: 6),
                          pw.Wrap(
                            spacing: 4,
                            runSpacing: 5,
                            children: cv.skills.map((s) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.white,
                                  borderRadius: pw.BorderRadius.circular(4),
                                  border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.8),
                                ),
                                child: pw.Text(
                                  PdfTextSanitizer.clean(s.name),
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey900,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          pw.SizedBox(height: 16),
                        ],

                        // Languages
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          _buildSectionLabel('LANGUAGES', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.languages.map((l) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 3),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      PdfTextSanitizer.clean(l.name),
                                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                                    ),
                                    pw.Text(
                                      PdfTextSanitizer.clean(l.proficiency),
                                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                                    ),
                                  ],
                                ),
                              )),
                          pw.SizedBox(height: 14),
                        ],

                        // Hobbies
                        if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                          _buildSectionLabel('INTERESTS', accentColor),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            cv.hobbies.map((h) => '- ${PdfTextSanitizer.clean(h)}').join('\n'),
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700, lineSpacing: 1.6),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right Column: Main Body (Header, Summary, Experience, Education)
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Name & Title
                        pw.Text(
                          PdfTextSanitizer.clean(info.fullName).toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (info.professionalTitle.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            PdfTextSanitizer.clean(info.professionalTitle),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 12),

                        // Executive Summary
                        if (cv.showSummary && cv.summary.isNotEmpty) ...[
                          _buildMainHeading('EXECUTIVE SUMMARY', accentColor),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            PdfTextSanitizer.clean(cv.summary),
                            style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.6, color: PdfColors.grey900),
                            textAlign: pw.TextAlign.justify,
                          ),
                          pw.SizedBox(height: 14),
                        ],

                        // Experience
                        if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                          _buildMainHeading('WORK EXPERIENCE', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
                          pw.SizedBox(height: 10),
                        ],

                        // Education
                        if (cv.showEducation && cv.educations.isNotEmpty) ...[
                          _buildMainHeading('EDUCATION', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.educations.map((edu) => _buildEducationItem(edu, accentColor)),
                          pw.SizedBox(height: 10),
                        ],

                        // Certifications
                        if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                          _buildMainHeading('CERTIFICATIONS', accentColor),
                          pw.SizedBox(height: 6),
                          ...cv.certifications.map((c) {
                            final title = PdfTextSanitizer.clean(c.displayTitle);
                            final hasDesc = c.description.trim().isNotEmpty;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  PdfTextSanitizer.buildBulletDot(accentColor, size: 3.5),
                                  pw.Expanded(
                                    child: pw.Text(
                                      hasDesc ? '$title - ${PdfTextSanitizer.clean(c.description)}' : title,
                                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
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

  pw.Widget _buildSectionLabel(String title, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, width: 22, color: accentColor),
      ],
    );
  }

  pw.Widget _buildContactRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label.toUpperCase(), style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
          pw.Text(value, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
        ],
      ),
    );
  }

  pw.Widget? _buildSocialContactRow(SocialPlatform platform, String rawInput, PdfColor accentColor) {
    if (rawInput.trim().isEmpty) return null;
    final url = SocialLinkHelper.buildUrl(platform, rawInput);
    final display = SocialLinkHelper.buildDisplayText(platform, rawInput);
    final hex = '#${(accentColor.red * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${(accentColor.green * 255).toInt().toRadixString(16).padLeft(2, '0')}'
        '${(accentColor.blue * 255).toInt().toRadixString(16).padLeft(2, '0')}';
    final svg = SocialLinkHelper.getSvgIcon(platform, hexColor: hex, size: 8.0);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.UrlLink(
        destination: url,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SvgImage(svg: svg, width: 8.0, height: 8.0),
            pw.SizedBox(width: 4),
            pw.Expanded(
              child: pw.Text(
                display,
                style: pw.TextStyle(fontSize: 8.0, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildMainHeading(String title, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, color: PdfColor.fromHex('#E2E8F0')),
      ],
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor) {
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
              pw.Text(
                dateRange,
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            PdfTextSanitizer.clean(exp.company),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor),
          ),
          pw.SizedBox(height: 2),
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
                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: accentColor),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            eduDate,
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }
}
