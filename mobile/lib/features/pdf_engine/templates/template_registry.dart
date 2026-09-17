import 'asian_ats_template.dart';
import 'compact_portfolio_template.dart';
import 'cv_template_interface.dart';
import 'executive_split_template.dart';
import 'modern_ats_template.dart';
import 'modern_creative_template.dart';
import 'western_strict_template.dart';

/// Metadata definition for Executive Color Palette
class AccentColorOption {
  final String hex;
  final String nameKey;

  const AccentColorOption({required this.hex, required this.nameKey});
}

/// Central catalog registry for all CV Templates in Resumer.
/// Adheres 100% to GEMINI.md modular separation and zero-god-file policy.
class TemplateRegistry {
  static final List<CvTemplate> _templates = [
    // ATS-Friendly Category
    AsianAtsTemplate(),
    WesternStrictTemplate(),
    ModernAtsTemplate(),

    // Creative Non-ATS Category
    ModernCreativeTemplate(),
    CompactPortfolioTemplate(),
    ExecutiveSplitTemplate(),
  ];

  /// 4 Official Executive Accent Colors according to blueprint Section I.5 & J.2
  static const List<AccentColorOption> officialColors = [
    AccentColorOption(hex: '#0B132B', nameKey: 'form.color_navy'), // Midnight Oxford Navy
    AccentColorOption(hex: '#065F46', nameKey: 'form.color_emerald'), // Deep Forest Emerald
    AccentColorOption(hex: '#1C2541', nameKey: 'form.color_slate'), // Muted Steel Slate
    AccentColorOption(hex: '#92400E', nameKey: 'form.color_bronze'), // Antique Bronze
  ];

  /// 4 Official Standard ATS Fonts according to blueprint Section I.5
  static const List<String> officialFonts = [
    'Outfit',
    'Calibri',
    'Arial',
    'Garamond',
  ];

  /// Return all registered templates
  static List<CvTemplate> get all => List.unmodifiable(_templates);

  /// Return templates filtered by category
  static List<CvTemplate> byCategory(CvTemplateCategory category) {
    return _templates.where((t) => t.category == category).toList();
  }

  /// Get template by id with graceful fallback to Asian ATS
  static CvTemplate getTemplate(String id) {
    return _templates.firstWhere(
      (t) => t.id == id,
      orElse: () => _templates.first,
    );
  }

  /// Check whether template supports photo
  static bool supportsPhoto(String id) {
    return getTemplate(id).supportsPhoto;
  }
}
