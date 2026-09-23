enum SocialPlatform {
  linkedin,
  github,
  instagram,
  facebook,
  whatsapp,
  website,
}

class SocialLinkItem {
  final SocialPlatform platform;
  final String rawInput;
  final String cleanHandle;
  final String url;
  final String displayText;

  const SocialLinkItem({
    required this.platform,
    required this.rawInput,
    required this.cleanHandle,
    required this.url,
    required this.displayText,
  });
}

/// Smart normalizer and vector SVG generator for CV social media & portfolio links.
class SocialLinkHelper {
  /// Extracts clean username / identifier from user input (handles full URLs, @ handles, and raw usernames).
  static String extractHandle(SocialPlatform platform, String rawInput) {
    var val = rawInput.trim();
    if (val.isEmpty) return '';

    // Strip leading @
    if (val.startsWith('@')) {
      val = val.substring(1).trim();
    }

    // Strip protocol
    val = val.replaceAll(RegExp(r'^https?:\/\/', caseSensitive: false), '');
    val = val.replaceAll(RegExp(r'^www\.', caseSensitive: false), '');

    switch (platform) {
      case SocialPlatform.linkedin:
        // Match linkedin.com/in/username or linkedin.com/company/xxx
        val = val.replaceAll(RegExp(r'^linkedin\.com\/in\/', caseSensitive: false), '');
        val = val.replaceAll(RegExp(r'^linkedin\.com\/', caseSensitive: false), '');
        break;

      case SocialPlatform.github:
        val = val.replaceAll(RegExp(r'^github\.com\/', caseSensitive: false), '');
        break;

      case SocialPlatform.instagram:
        val = val.replaceAll(RegExp(r'^instagram\.com\/', caseSensitive: false), '');
        break;

      case SocialPlatform.facebook:
        val = val.replaceAll(RegExp(r'^facebook\.com\/', caseSensitive: false), '');
        val = val.replaceAll(RegExp(r'^fb\.com\/', caseSensitive: false), '');
        break;

      case SocialPlatform.whatsapp:
        // Clean non-digit characters except leading +
        var cleaned = val.replaceAll(RegExp(r'[^0-9+]'), '');
        if (cleaned.startsWith('+')) {
          cleaned = cleaned.substring(1);
        }
        if (cleaned.startsWith('0')) {
          // Indonesian phone prefix conversion: 0812... -> 62812...
          cleaned = '62${cleaned.substring(1)}';
        }
        return cleaned;

      case SocialPlatform.website:
        // Just return clean domain/path
        break;
    }

    // Strip trailing slashes or queries
    val = val.split('?').first;
    if (val.endsWith('/')) {
      val = val.substring(0, val.length - 1);
    }

    return val.trim();
  }

  /// Builds a fully-qualified, safe target URL for clicking in PDF or web browser.
  static String buildUrl(SocialPlatform platform, String rawInput) {
    final handle = extractHandle(platform, rawInput);
    if (handle.isEmpty) return '';

    switch (platform) {
      case SocialPlatform.linkedin:
        return 'https://linkedin.com/in/$handle';
      case SocialPlatform.github:
        return 'https://github.com/$handle';
      case SocialPlatform.instagram:
        return 'https://instagram.com/$handle';
      case SocialPlatform.facebook:
        return 'https://facebook.com/$handle';
      case SocialPlatform.whatsapp:
        return 'https://wa.me/$handle';
      case SocialPlatform.website:
        return rawInput.trim().startsWith(RegExp(r'^https?:\/\/', caseSensitive: false))
            ? rawInput.trim()
            : 'https://$handle';
    }
  }

  /// Builds clean, readable text for display in CV headers (compact and professional).
  static String buildDisplayText(SocialPlatform platform, String rawInput) {
    final handle = extractHandle(platform, rawInput);
    if (handle.isEmpty) return '';

    switch (platform) {
      case SocialPlatform.linkedin:
        return 'linkedin.com/in/$handle';
      case SocialPlatform.github:
        return 'github.com/$handle';
      case SocialPlatform.instagram:
        return '@$handle';
      case SocialPlatform.facebook:
        return 'facebook.com/$handle';
      case SocialPlatform.whatsapp:
        return '+$handle';
      case SocialPlatform.website:
        return handle;
    }
  }

  /// Returns SVG string for crisp vector rendering in package:pdf (pw.SvgImage).
  static String getSvgIcon(SocialPlatform platform, {String hexColor = '#1C2541', double size = 10}) {
    // Ensure hex starts with #
    final color = hexColor.startsWith('#') ? hexColor : '#$hexColor';

    switch (platform) {
      case SocialPlatform.linkedin:
        return '''
<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none">
  <path fill="$color" d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.88 8.56a1.68 1.68 0 0 0 1.68-1.68c0-.93-.75-1.69-1.68-1.69a1.69 1.69 0 0 0-1.69 1.69c0 .93.76 1.68 1.69 1.68m1.39 9.94v-8.37H5.5v8.37h2.77z"/>
</svg>
''';

      case SocialPlatform.github:
        return '''
<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none">
  <path fill="$color" fill-rule="evenodd" clip-rule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"/>
</svg>
''';

      case SocialPlatform.instagram:
        return '''
<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none">
  <path fill="$color" d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
</svg>
''';

      case SocialPlatform.facebook:
        return '''
<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none">
  <path fill="$color" d="M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z"/>
</svg>
''';

      case SocialPlatform.whatsapp:
        return '''
<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none">
  <path fill="$color" d="M12.04 2c-5.46 0-9.91 4.45-9.91 9.91 0 1.75.46 3.45 1.32 4.95L2.05 22l5.25-1.38c1.45.79 3.08 1.21 4.74 1.21 5.46 0 9.91-4.45 9.91-9.91 0-2.65-1.03-5.14-2.9-7.01A9.816 9.816 0 0 0 12.04 2m.01 1.67c2.2 0 4.26.86 5.82 2.42a8.225 8.225 0 0 1 2.41 5.83c0 4.54-3.7 8.24-8.24 8.24-1.48 0-2.93-.4-4.2-1.15l-.3-.18-3.12.82.83-3.04-.2-.31a8.196 8.196 0 0 1-1.26-4.38c0-4.54 3.7-8.24 8.25-8.24m4.52 11.66c-.25-.13-1.47-.72-1.7-.81-.23-.08-.39-.13-.56.13-.17.25-.64.81-.79.97-.14.17-.29.19-.54.06-.25-.13-1.06-.39-2.01-1.24-.74-.66-1.24-1.48-1.39-1.73-.14-.25-.02-.39.11-.51.11-.11.25-.29.37-.43.13-.15.17-.25.25-.42.08-.17.04-.31-.02-.44-.06-.13-.56-1.35-.77-1.85-.2-.49-.41-.42-.56-.43h-.48c-.17 0-.44.06-.67.31-.23.25-.87.85-.87 2.08s.89 2.41 1.02 2.58c.13.17 1.76 2.68 4.26 3.76.6.26 1.06.41 1.42.53.6.19 1.15.16 1.58.1.48-.07 1.47-.6 1.68-1.18.21-.58.21-1.07.15-1.18-.07-.12-.22-.19-.47-.31z"/>
</svg>
''';

      case SocialPlatform.website:
        return '''
<svg width="$size" height="$size" viewBox="0 0 24 24" fill="none">
  <path fill="$color" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
</svg>
''';
    }
  }
}
