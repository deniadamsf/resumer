import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/utils/social_link_helper.dart';
import '../../cv_editor/models/cv_model.dart';
import 'pdf_text_sanitizer.dart';

/// PDF renderer for candidate social media and portfolio links.
/// Strictly enforces ATS Best Practices:
/// - ATS Mode (Asian, Western, Modern ATS): Clean linear text to ensure 100% parser compatibility without encoding boxes.
/// - Non-ATS Creative Mode: Crisp vector SVG brand icons alongside handles/links with interactive clickable hyperlinks.
class SocialIconPdfWidget {
  /// Converts a single social entry into a clickable PDF widget.
  static pw.Widget? buildLinkItem({
    required SocialPlatform platform,
    required String rawInput,
    required bool isAtsMode,
    PdfColor? accentColor,
    PdfColor? textColor,
    double fontSize = 8.5,
    double iconSize = 9.0,
    bool showLabelInAts = false,
  }) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return null;

    final url = SocialLinkHelper.buildUrl(platform, trimmed);
    final displayText = PdfTextSanitizer.clean(SocialLinkHelper.buildDisplayText(platform, trimmed));
    final resolvedText = textColor ?? PdfColors.grey800;
    final resolvedAccent = accentColor ?? PdfColors.blueGrey800;

    if (isAtsMode) {
      // In ATS mode: Avoid vector images to keep parser extraction linear and pure
      final label = showLabelInAts ? '${_getAtsPlatformLabel(platform)}: ' : '';
      return pw.UrlLink(
        destination: url,
        child: pw.Text(
          '$label$displayText',
          style: pw.TextStyle(
            fontSize: fontSize,
            color: resolvedText,
          ),
        ),
      );
    } else {
      // In Creative Non-ATS mode: Use crisp vector SVG icon + compact handle text
      // Convert accent color to hex string
      final hex = '#${(resolvedAccent.red * 255).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(resolvedAccent.green * 255).toInt().toRadixString(16).padLeft(2, '0')}'
          '${(resolvedAccent.blue * 255).toInt().toRadixString(16).padLeft(2, '0')}';

      final svgString = SocialLinkHelper.getSvgIcon(platform, hexColor: hex, size: iconSize);

      return pw.UrlLink(
        destination: url,
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SvgImage(
              svg: svgString,
              width: iconSize,
              height: iconSize,
            ),
            pw.SizedBox(width: 3.5),
            pw.Text(
              displayText,
              style: pw.TextStyle(
                fontSize: fontSize,
                color: resolvedText,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Collects all non-empty social links from PersonalInfo into a list of PDF widgets.
  static List<pw.Widget> buildAllItems({
    required PersonalInfo info,
    required bool isAtsMode,
    PdfColor? accentColor,
    PdfColor? textColor,
    double fontSize = 8.5,
    double iconSize = 9.0,
    bool showLabelInAts = false,
  }) {
    final list = <pw.Widget>[];

    void addIfValid(SocialPlatform platform, String raw) {
      final widget = buildLinkItem(
        platform: platform,
        rawInput: raw,
        isAtsMode: isAtsMode,
        accentColor: accentColor,
        textColor: textColor,
        fontSize: fontSize,
        iconSize: iconSize,
        showLabelInAts: showLabelInAts,
      );
      if (widget != null) {
        list.add(widget);
      }
    }

    addIfValid(SocialPlatform.linkedin, info.linkedin);
    addIfValid(SocialPlatform.github, info.github);
    addIfValid(SocialPlatform.website, info.website);
    addIfValid(SocialPlatform.whatsapp, info.whatsapp);
    addIfValid(SocialPlatform.instagram, info.instagram);
    addIfValid(SocialPlatform.facebook, info.facebook);

    return list;
  }

  /// Builds a wrap container of all social links with dot separators or pill styling.
  static pw.Widget buildWrapList({
    required PersonalInfo info,
    required bool isAtsMode,
    PdfColor? accentColor,
    PdfColor? textColor,
    double spacing = 8.0,
    double runSpacing = 4.0,
    double fontSize = 8.5,
    double iconSize = 9.0,
  }) {
    final items = buildAllItems(
      info: info,
      isAtsMode: isAtsMode,
      accentColor: accentColor,
      textColor: textColor,
      fontSize: fontSize,
      iconSize: iconSize,
    );

    if (items.isEmpty) return pw.SizedBox();

    return pw.Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: pw.WrapCrossAlignment.center,
      children: items,
    );
  }

  static String _getAtsPlatformLabel(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.linkedin:
        return 'LinkedIn';
      case SocialPlatform.github:
        return 'GitHub';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.whatsapp:
        return 'WhatsApp';
      case SocialPlatform.website:
        return 'Portfolio';
    }
  }
}
