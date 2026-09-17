import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import '../../cv_editor/models/cv_model.dart';

/// Category of CV Template: Machine ATS-Friendly vs Visual Creative Non-ATS
enum CvTemplateCategory {
  atsFriendly,
  creativeNonAts,
}

/// Abstract contract for all isolated PDF templates in Resumer.
/// Adheres 100% to GEMINI.md section 7 (Separation of Concerns).
abstract class CvTemplate {
  /// Unique identifier stored in [CvDocument.templateId]
  String get id;

  /// Localization key for template title
  String get nameKey;

  /// Localization key for template description
  String get descKey;

  /// Whether this template is 1-column ATS machine parser compliant
  bool get isAtsFriendly;

  /// Expected ATS parser score range (e.g. '95-100', '85-95', 'Portofolio / Visual')
  String get atsScoreRange;

  /// Whether this template supports an executive profile photo
  bool get supportsPhoto;

  /// Category filter
  CvTemplateCategory get category =>
      isAtsFriendly ? CvTemplateCategory.atsFriendly : CvTemplateCategory.creativeNonAts;

  /// Generates the PDF document bytes client-side
  Future<Uint8List> generate(CvDocument cv, {Uint8List? photoBytes});

  /// Helper to resolve accent color with fallback
  PdfColor resolveAccentColor(String hex) {
    try {
      return PdfColor.fromHex(hex);
    } catch (_) {
      return const PdfColor(11 / 255, 19 / 255, 43 / 255); // #0B132B
    }
  }
}
