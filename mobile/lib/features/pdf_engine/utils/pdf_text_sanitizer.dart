import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// High-precision text sanitizer and vector element builder for PDF generation.
/// Guarantees that AI-generated text never produces missing glyph boxes ('☒' or '󰀀')
/// or typography corruption in any PDF viewer.
class PdfTextSanitizer {
  /// Normalizes Unicode typographic characters (curly quotes, dashes, bullets,
  /// zero-width spaces) to safe standard ASCII characters.
  static String clean(String? text) {
    if (text == null || text.isEmpty) return '';

    return text
        .replaceAll('\u2018', "'") // ‘ Left single quotation mark
        .replaceAll('\u2019', "'") // ’ Right single quotation mark
        .replaceAll('\u201A', "'") // ‚ Single low-9 quotation mark
        .replaceAll('\u201B', "'") // ‛ Single high-reversed-9 quotation mark
        .replaceAll('\u201C', '"') // “ Left double quotation mark
        .replaceAll('\u201D', '"') // ” Right double quotation mark
        .replaceAll('\u201E', '"') // „ Double low-9 quotation mark
        .replaceAll('\u201F', '"') // ‟ Double high-reversed-9 quotation mark
        .replaceAll('\u2014', ' - ') // — Em-dash
        .replaceAll('\u2013', '-') // – En-dash
        .replaceAll('\u2022', '-') // • Bullet
        .replaceAll('\u2023', '-') // ‣ Triangular bullet
        .replaceAll('\u2043', '-') // ⁃ Hyphen bullet
        .replaceAll('\u25E6', '-') // ◦ White bullet
        .replaceAll('\u2026', '...') // … Ellipsis
        .replaceAll('\u00A0', ' ') // Non-breaking space
        .replaceAll('\u200B', '') // Zero-width space
        .replaceAll('\u200C', '') // Zero-width non-joiner
        .replaceAll('\u200D', '') // Zero-width joiner
        .replaceAll('\uFEFF', '') // Zero-width no-break space (BOM)
        .replaceAll('\u00AD', '') // Soft hyphen
        .trim();
  }

  /// Resolution-independent vector bullet dot.
  /// Eliminates font-encoding issues (like Helvetica missing glyph boxes).
  static pw.Widget buildBulletDot(
    PdfColor color, {
    double size = 3.5,
    double topMargin = 4.5,
    double rightMargin = 6.0,
  }) {
    return pw.Container(
      width: size,
      height: size,
      margin: pw.EdgeInsets.only(top: topMargin, right: rightMargin),
      decoration: pw.BoxDecoration(
        color: color,
        shape: pw.BoxShape.circle,
      ),
    );
  }

  /// Consistent section title with an accent underline bar.
  static pw.Widget buildSectionTitle(
    String title,
    PdfColor accentColor, {
    double fontSize = 11.0,
    double underlineThickness = 1.0,
    bool uppercase = true,
  }) {
    final cleanTitle = clean(uppercase ? title.toUpperCase() : title);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          cleanTitle,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
            letterSpacing: 0.5,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(
          height: underlineThickness,
          color: accentColor,
        ),
      ],
    );
  }

  /// Mathematically blends a color with white for PDF background tints.
  /// (factor 0.0 = pure white, 1.0 = full accent color).
  /// Fixes PDF engine bug where alpha channel in PdfColor is ignored by RGB operators.
  static PdfColor tint(PdfColor color, double factor) {
    final f = factor.clamp(0.0, 1.0);
    return PdfColor(
      1.0 - (1.0 - color.red) * f,
      1.0 - (1.0 - color.green) * f,
      1.0 - (1.0 - color.blue) * f,
    );
  }

  /// Mathematically darkens a color towards black for high-contrast deep text.
  static PdfColor shade(PdfColor color, double factor) {
    final f = (1.0 - factor).clamp(0.0, 1.0);
    return PdfColor(
      color.red * f,
      color.green * f,
      color.blue * f,
    );
  }

  /// Build a star/dot rating row for language proficiency visualization.
  /// Uses vector circles instead of Unicode star characters for font safety.
  /// [filled] = number of filled dots (0-5), [total] = max dots.
  static pw.Widget buildStarRating(
    int filled,
    PdfColor accentColor, {
    int total = 5,
    double size = 4.0,
    double spacing = 2.0,
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: List.generate(total, (i) {
        return pw.Container(
          width: size,
          height: size,
          margin: pw.EdgeInsets.only(right: i < total - 1 ? spacing : 0),
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: i < filled ? accentColor : PdfColors.grey300,
          ),
        );
      }),
    );
  }

  /// Convert language proficiency text to a numeric star level (1-5).
  /// Handles common AI-generated proficiency labels.
  static int proficiencyToStars(String proficiency) {
    final lower = proficiency.toLowerCase().trim();
    if (lower.contains('native') || lower.contains('bilingual') || lower.contains('c2')) return 5;
    if (lower.contains('full professional') || lower.contains('fluent') || lower.contains('c1')) return 4;
    if (lower.contains('professional') || lower.contains('advanced') || lower.contains('b2')) return 3;
    if (lower.contains('limited') || lower.contains('intermediate') || lower.contains('b1')) return 2;
    if (lower.contains('elementary') || lower.contains('basic') || lower.contains('a1') || lower.contains('a2')) return 1;
    return 2; // Default fallback
  }
}

