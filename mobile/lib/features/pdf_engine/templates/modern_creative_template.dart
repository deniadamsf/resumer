import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../cv_editor/models/cv_model.dart';
import '../utils/pdf_text_sanitizer.dart';
import 'cv_template_interface.dart';

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
  String get atsScoreRange => 'Portofolio / HR Langsung';

  @override
  bool get supportsPhoto => true;

  @override
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes}) async {
    final pdf = pw.Document();
    final accentColor = resolveAccentColor(cv.accentColor);
    final sidebarBg = PdfColor(accentColor.red, accentColor.green, accentColor.blue, 0.07);
    final info = cv.personalInfo;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Left Sidebar (Contact, Photo, Skills, Languages, Hobbies)
              pw.Container(
                width: 185,
                color: sidebarBg,
                padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Photo
                    if (photoBytes != null) ...[
                      pw.Center(
                        child: pw.Container(
                          width: 84,
                          height: 84,
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
                      pw.SizedBox(height: 16),
                    ],

                    // Contact Info
                    _buildSidebarSectionTitle('CONTACT', accentColor),
                    pw.SizedBox(height: 6),
                    if (info.email.isNotEmpty)
                      _buildContactItem('Email', PdfTextSanitizer.clean(info.email)),
                    if (info.phone.isNotEmpty)
                      _buildContactItem('Phone', PdfTextSanitizer.clean(info.phone)),
                    if (info.location.isNotEmpty)
                      _buildContactItem('Location', PdfTextSanitizer.clean(info.location)),
                    if (info.linkedin.isNotEmpty)
                      _buildContactItem('Portfolio', PdfTextSanitizer.clean(info.linkedin)),
                    pw.SizedBox(height: 14),

                    // Skills Section
                    if (cv.showSkills && cv.skills.isNotEmpty) ...[
                      _buildSidebarSectionTitle('SKILLS', accentColor),
                      pw.SizedBox(height: 6),
                      pw.Wrap(
                        spacing: 4,
                        runSpacing: 5,
                        children: cv.skills.map((s) {
                          final cleanName = PdfTextSanitizer.clean(s.name);
                          return pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              border: pw.Border.all(color: accentColor, width: 0.6),
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
                      pw.SizedBox(height: 14),
                    ],

                    // Languages
                    if (cv.showLanguages && cv.languages.isNotEmpty) ...[
                      _buildSidebarSectionTitle('LANGUAGES', accentColor),
                      pw.SizedBox(height: 6),
                      ...cv.languages.map((l) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                PdfTextSanitizer.clean(l.name),
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                PdfTextSanitizer.clean(l.proficiency),
                                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                              ),
                            ],
                          ),
                        );
                      }),
                      pw.SizedBox(height: 14),
                    ],

                    // Hobbies
                    if (cv.showHobbies && cv.hobbies.isNotEmpty) ...[
                      _buildSidebarSectionTitle('INTERESTS', accentColor),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        cv.hobbies.map((h) => '- ${PdfTextSanitizer.clean(h)}').join('\n'),
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                      ),
                    ],
                  ],
                ),
              ),

              // Right Main Body (Header, Summary, Experience, Education, Certs)
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Candidate Title & Name
                      pw.Text(
                        PdfTextSanitizer.clean(info.fullName).toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 22,
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
                      pw.SizedBox(height: 10),
                      pw.Container(height: 1.5, color: accentColor),
                      pw.SizedBox(height: 12),

                      // Executive Summary
                      if (cv.showSummary && cv.summary.isNotEmpty) ...[
                        _buildMainSectionTitle('ABOUT ME', accentColor),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          PdfTextSanitizer.clean(cv.summary),
                          style: const pw.TextStyle(fontSize: 9.5),
                          textAlign: pw.TextAlign.justify,
                        ),
                        pw.SizedBox(height: 12),
                      ],

                      // Experience
                      if (cv.showExperience && cv.experiences.isNotEmpty) ...[
                        _buildMainSectionTitle('EXPERIENCE', accentColor),
                        pw.SizedBox(height: 5),
                        ...cv.experiences.map((exp) => _buildExperienceItem(exp, accentColor)),
                        pw.SizedBox(height: 8),
                      ],

                      // Education
                      if (cv.showEducation && cv.educations.isNotEmpty) ...[
                        _buildMainSectionTitle('EDUCATION', accentColor),
                        pw.SizedBox(height: 5),
                        ...cv.educations.map((edu) => _buildEducationItem(edu)),
                        pw.SizedBox(height: 8),
                      ],

                      // Certifications
                      if (cv.showCertifications && cv.certifications.isNotEmpty) ...[
                        _buildMainSectionTitle('CERTIFICATIONS', accentColor),
                        pw.SizedBox(height: 5),
                        ...cv.certifications.map((c) {
                          final title = PdfTextSanitizer.clean(c.displayTitle);
                          final hasDesc = c.description.trim().isNotEmpty;
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 2.5),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                PdfTextSanitizer.buildBulletDot(accentColor, size: 3.5),
                                pw.Expanded(
                                  child: pw.Text(
                                    hasDesc ? '$title: ${PdfTextSanitizer.clean(c.description)}' : title,
                                    style: const pw.TextStyle(fontSize: 9),
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
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSidebarSectionTitle(String title, PdfColor accentColor) {
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
        pw.Container(height: 1, width: 28, color: accentColor),
      ],
    );
  }

  pw.Widget _buildContactItem(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
          ),
        ],
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
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, color: PdfColors.grey300),
      ],
    );
  }

  pw.Widget _buildExperienceItem(WorkExperience exp, PdfColor accentColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(exp.position),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${PdfTextSanitizer.clean(exp.startDate)} - ${PdfTextSanitizer.clean(exp.endDate)}',
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Text(
            PdfTextSanitizer.clean(exp.company),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
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
                      style: const pw.TextStyle(fontSize: 9),
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

  pw.Widget _buildEducationItem(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${PdfTextSanitizer.clean(edu.degree)} in ${PdfTextSanitizer.clean(edu.fieldOfStudy)}',
                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                PdfTextSanitizer.clean(edu.institution),
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
              ),
            ],
          ),
          pw.Text(
            PdfTextSanitizer.clean(edu.graduationYear),
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
}
