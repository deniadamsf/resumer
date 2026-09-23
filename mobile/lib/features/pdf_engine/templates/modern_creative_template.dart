import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/utils/social_link_helper.dart';

/// Modern Creative Two-Column Template
/// Visually compelling 2-column layout designed specifically for human recruiters,
/// creative agencies, startups, and direct email/portfolio submissions.
class ModernCreativeTemplate extends CvTemplate {
  @override
  String get id => 'modern_creative';

  @override
  String get nameKey => 'form.template_modern_creative';

  @override
  String get descKey => 'form.template_modern_creative_desc';

  @override
  bool get isAtsFriendly => false;

  @override
  String get atsScoreRange => 'form.template_score_modern_creative';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final sidebarBg = accentColor;
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
                  width: 195,
                  color: sidebarBg,
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
                // Left Sidebar (Contact, Photo, Skills, Languages, Hobbies) - 100% White High Contrast
                pw.Partition(
                  width: 195,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Profile Photo
                        if (photoBytes != null) ...[
                          pw.Center(
                            child: pw.Container(
                              width: 88,
                              height: 88,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                border: pw.Border.all(color: PdfColors.white, width: 2.5),
                                image: pw.DecorationImage(
                                  image: pw.MemoryImage(photoBytes),
                                  fit: pw.BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 18),
                        ],

                        // Contact Info
                        _buildSidebarSectionTitle('CONTACT'),
                        pw.SizedBox(height: 8),
                        if (info.email.isNotEmpty)
                          _buildContactItem('Email', PdfTextSanitizer.clean(info.email)),
                        if (info.phone.isNotEmpty)
                          _buildContactItem('Phone', PdfTextSanitizer.clean(info.phone)),
                        if (info.location.isNotEmpty)
                          _buildContactItem('Location', PdfTextSanitizer.clean(info.location)),
                        if (_buildSocialContactItem(SocialPlatform.linkedin, info.linkedin) != null)
                          _buildSocialContactItem(SocialPlatform.linkedin, info.linkedin)!,
                        if (_buildSocialContactItem(SocialPlatform.github, info.github) != null)
                          _buildSocialContactItem(SocialPlatform.github, info.github)!,
                        if (_buildSocialContactItem(SocialPlatform.website, info.website) != null)
                          _buildSocialContactItem(SocialPlatform.website, info.website)!,
                        if (_buildSocialContactItem(SocialPlatform.whatsapp, info.whatsapp) != null)
                          _buildSocialContactItem(SocialPlatform.whatsapp, info.whatsapp)!,
                        if (_buildSocialContactItem(SocialPlatform.instagram, info.instagram) != null)
                          _buildSocialContactItem(SocialPlatform.instagram, info.instagram)!,
                        if (_buildSocialContactItem(SocialPlatform.facebook, info.facebook) != null)
                          _buildSocialContactItem(SocialPlatform.facebook, info.facebook)!,
                        pw.SizedBox(height: 16),

                        // Skills Section
                        if (cv.showSkills && cv.skills.isNotEmpty) ...[
                          _buildSidebarSectionTitle('SKILLS'),
                          pw.SizedBox(height: 8),
                          pw.Wrap(
                            spacing: 5,
                            runSpacing: 6,
                            children: cv.skills.map((s) {
                              final cleanName = PdfTextSanitizer.clean(s.name);
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.white,
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Text(
                                  cleanName,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          pw.SizedBox(height: 16),
                        ],

                        // Languages
                        if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                          _buildSidebarSectionTitle('LANGUAGES'),
                          pw.SizedBox(height: 8),
                          ...cv.languages.map((l) {
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    PdfTextSanitizer.clean(l.name),
                                    style: pw.TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white,
                                    ),
                                  ),
                                  pw.Text(
                                    PdfTextSanitizer.clean(l.proficiency),
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      color: PdfColor.fromHex('#CBD5E1'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          pw.SizedBox(height: 16),
                        ],

                        // Hobbies
                        if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                          _buildSidebarSectionTitle('INTERESTS'),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            cv.hobbies.map((h) => '- ${PdfTextSanitizer.clean(h)}').join('\n'),
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: PdfColor.fromHex('#F1F5F9'),
                              lineSpacing: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right Main Body (Header, Summary, Experience, Education, Certs)
                pw.Partition(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 26, vertical: 28),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Candidate Title & Name
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
                          pw.SizedBox(height: 3),
                          pw.Text(
                            PdfTextSanitizer.clean(info.professionalTitle),
                            style: pw.TextStyle(
                              fontSize: 12.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey800,
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 10),
                        pw.Container(height: 2, color: accentColor),
                        pw.SizedBox(height: 14),

                        // Executive Summary
                        if (cv.showSummary && cv.summary.isNotEmpty) ...[
                          _buildMainSectionTitle('ABOUT ME', accentColor),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            PdfTextSanitizer.clean(cv.summary),
                            style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.8),
                            textAlign: pw.TextAlign.justify,
                          ),
                          pw.SizedBox(height: 14),
                        ],

                        // Experience
                        if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                          _buildMainSectionTitle('EXPERIENCE', accentColor),
                          pw.SizedBox(height: 7),
                          ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
                          pw.SizedBox(height: 10),
                        ],

                        // Education
                        if (cv.showEducation && cv.educations.isNotEmpty) ...[
                          _buildMainSectionTitle('EDUCATION', accentColor),
                          pw.SizedBox(height: 7),
                          ...cv.educations.map((edu) => _buildEducationItem(edu, accentColor)),
                          pw.SizedBox(height: 10),
                        ],

                        // Certifications
                        if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                          _buildMainSectionTitle('CERTIFICATIONS', accentColor),
                          pw.SizedBox(height: 7),
                          ...cv.certifications.map((c) {
                            final title = PdfTextSanitizer.clean(c.displayTitle);
                            final hasDesc = c.description.trim().isNotEmpty;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 3.5),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  PdfTextSanitizer.buildBulletDot(accentColor, size: 3.5),
                                  pw.Expanded(
                                    child: pw.Text(
                                      hasDesc ? '$title: ${PdfTextSanitizer.clean(c.description)}' : title,
                                      style: const pw.TextStyle(fontSize: 9.5),
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

  pw.Widget _buildSidebarSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            letterSpacing: 1.0,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: 1.2, width: 26, color: PdfColors.white),
      ],
    );
  }

  pw.Widget _buildContactItem(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#CBD5E1'),
              letterSpacing: 0.6,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget? _buildSocialContactItem(SocialPlatform platform, String rawInput) {
    if (rawInput.trim().isEmpty) return null;
    final url = SocialLinkHelper.buildUrl(platform, rawInput);
    final display = SocialLinkHelper.buildDisplayText(platform, rawInput);
    final svg = SocialLinkHelper.getSvgIcon(platform, hexColor: '#FFFFFF', size: 8.0);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
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
                style: const pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildMainSectionTitle(String title, PdfColor accentColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: 1, color: PdfColor.fromHex('#E2E8F0')),
      ],
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor) {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final dateRange = DateFormatHelper.formatDateRange(exp.startDate, exp.endDate, isEnglish: isEn);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
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
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
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
          ...exp.highlights.map(
            (hl) => pw.Padding(
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
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
  }
}

