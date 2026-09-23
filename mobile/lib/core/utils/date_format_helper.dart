/// Intelligent, bilingual Date & Month/Year Formatter and Parser.
/// Supports both Indonesian (`id_ID`) and English (`en_US`), handling full month names,
/// 3-letter abbreviations, numeric formats, and edge cases.
class DateParts {
  final int? month; // 1 to 12
  final String? year; // 4-digit year e.g. "2024"
  final bool isPresent; // true if contains 'sekarang' / 'present'
  final String raw;

  const DateParts({
    this.month,
    this.year,
    this.isPresent = false,
    this.raw = '',
  });

  bool get hasMonth => month != null && month! >= 1 && month! <= 12;
  bool get hasYear => year != null && year!.isNotEmpty;
  bool get isEmpty => !hasMonth && !hasYear && !isPresent;
}

class DateFormatHelper {
  static const List<String> monthNamesId = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const List<String> monthNamesEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> monthShortId = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const List<String> monthShortEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Get localized month name for month index 1..12
  static String getMonthName(int month, {bool isEnglish = false, bool full = true}) {
    final idx = (month - 1).clamp(0, 11);
    if (isEnglish) {
      return full ? monthNamesEn[idx] : monthShortEn[idx];
    } else {
      return full ? monthNamesId[idx] : monthShortId[idx];
    }
  }

  /// Map month string to month index (1..12), case-insensitive
  static int? parseMonthIndex(String input) {
    final clean = input.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // Check January
    if (clean == 'jan' || clean == 'januari' || clean == 'january') return 1;
    // Check February
    if (clean == 'feb' || clean == 'februari' || clean == 'february') return 2;
    // Check March
    if (clean == 'mar' || clean == 'maret' || clean == 'march') return 3;
    // Check April
    if (clean == 'apr' || clean == 'april') return 4;
    // Check May
    if (clean == 'mei' || clean == 'may') return 5;
    // Check June
    if (clean == 'jun' || clean == 'juni' || clean == 'june') return 6;
    // Check July
    if (clean == 'jul' || clean == 'juli' || clean == 'july') return 7;
    // Check August
    if (clean == 'agt' || clean == 'aug' || clean == 'agustus' || clean == 'august') return 8;
    // Check September
    if (clean == 'sep' || clean == 'sept' || clean == 'september') return 9;
    // Check October
    if (clean == 'okt' || clean == 'oct' || clean == 'oktober' || clean == 'october') return 10;
    // Check November
    if (clean == 'nov' || clean == 'november') return 11;
    // Check December
    if (clean == 'des' || clean == 'dec' || clean == 'desember' || clean == 'december') return 12;

    // Check numeric string "1" through "12"
    final numVal = int.tryParse(clean);
    if (numVal != null && numVal >= 1 && numVal <= 12) {
      return numVal;
    }

    return null;
  }

  /// Parses arbitrary date strings into month and year.
  /// Handles:
  /// - "Januari 2024", "januari 2024", "Jan 2024"
  /// - "January 2024", "Aug 2023", "Agt 2023"
  /// - "01/2024", "1/2024", "2024-01", "2024.01"
  /// - "Sekarang", "Present", "Current"
  /// - "2024" (year only)
  /// - "Januari" (month only)
  static DateParts parse(String? input) {
    if (input == null || input.trim().isEmpty) {
      return const DateParts();
    }

    final raw = input.trim();
    final lower = raw.toLowerCase();

    final isPresent = lower.contains('sekarang') ||
        lower.contains('present') ||
        lower.contains('current') ||
        lower == 'now';

    if (isPresent) {
      return DateParts(isPresent: true, raw: raw);
    }

    // 1. Extract 4-digit year (1900-2099)
    final yearRegex = RegExp(r'\b(19\d\d|20\d\d)\b');
    final yearMatch = yearRegex.firstMatch(raw);
    final year = yearMatch?.group(0);

    // 2. Extract numeric month (e.g. 01/2024, 2024-01, 1-2024)
    final numFormatRegex = RegExp(r'(?:^|[\s\-\/\.])(?:(\d{1,2})[\-\/\.](\d{4})|(\d{4})[\-\/\.](\d{1,2}))(?:$|[\s\-\/\.])');
    final numMatch = numFormatRegex.firstMatch(raw);
    if (numMatch != null) {
      final mStr = numMatch.group(1) ?? numMatch.group(4);
      final yStr = numMatch.group(2) ?? numMatch.group(3);
      final mVal = int.tryParse(mStr ?? '');
      if (mVal != null && mVal >= 1 && mVal <= 12) {
        return DateParts(
          month: mVal,
          year: yStr ?? year,
          raw: raw,
        );
      }
    }

    // 3. Extract word-based month by removing the year first
    String withoutYear = raw;
    if (year != null) {
      withoutYear = raw.replaceFirst(year, ' ');
    }

    // Split remaining tokens and find matching month
    final tokens = withoutYear.split(RegExp(r'[\s,\-_/]+'));
    int? detectedMonth;
    for (final token in tokens) {
      final m = parseMonthIndex(token);
      if (m != null) {
        detectedMonth = m;
        break;
      }
    }

    return DateParts(
      month: detectedMonth,
      year: year,
      raw: raw,
    );
  }

  /// Formats month and year into a standardized string e.g. "Januari 2024" or "January 2024"
  static String formatMonthYear(
    int? month,
    String? year, {
    bool isEnglish = false,
    bool full = true,
  }) {
    final hasM = month != null && month >= 1 && month <= 12;
    final y = year?.trim() ?? '';
    final hasY = y.isNotEmpty;

    if (hasM && hasY) {
      final mName = getMonthName(month, isEnglish: isEnglish, full: full);
      return '$mName $y';
    } else if (hasM) {
      return getMonthName(month, isEnglish: isEnglish, full: full);
    } else if (hasY) {
      return y;
    }
    return '';
  }

  /// Formats date range cleanly for PDF display and preview.
  /// Converts "januari 2024" and "sekarang" to "Januari 2024 - Sekarang" / "January 2024 - Present".
  /// Intelligently provides fallback months for year-only inputs (defaultStartMonth: 1, defaultEndMonth: 12).
  static String formatDateRange(
    String? start,
    String? end, {
    bool isEnglish = false,
    bool full = true,
    int? defaultStartMonth = 1,
    int? defaultEndMonth = 12,
  }) {
    // If start string contains a hyphenated range and end is empty, split them automatically
    String effectiveStart = start?.trim() ?? '';
    String effectiveEnd = end?.trim() ?? '';

    if (effectiveEnd.isEmpty && effectiveStart.isNotEmpty) {
      final rangeMatch = RegExp(r'^(.+?)\s*(?:[-–—]|sampai|to)\s*(.+)$', caseSensitive: false).firstMatch(effectiveStart);
      if (rangeMatch != null) {
        effectiveStart = rangeMatch.group(1)?.trim() ?? effectiveStart;
        effectiveEnd = rangeMatch.group(2)?.trim() ?? '';
      }
    }

    final startParts = parse(effectiveStart);
    final endParts = parse(effectiveEnd);

    String startFormatted = '';
    if (startParts.hasMonth && startParts.hasYear) {
      startFormatted = formatMonthYear(startParts.month, startParts.year, isEnglish: isEnglish, full: full);
    } else if (startParts.hasYear && defaultStartMonth != null) {
      startFormatted = formatMonthYear(defaultStartMonth, startParts.year, isEnglish: isEnglish, full: full);
    } else if (effectiveStart.isNotEmpty) {
      startFormatted = effectiveStart;
    }

    String endFormatted = '';
    if (endParts.isPresent) {
      endFormatted = isEnglish ? 'Present' : 'Sekarang';
    } else if (endParts.hasMonth && endParts.hasYear) {
      endFormatted = formatMonthYear(endParts.month, endParts.year, isEnglish: isEnglish, full: full);
    } else if (endParts.hasYear && defaultEndMonth != null) {
      endFormatted = formatMonthYear(defaultEndMonth, endParts.year, isEnglish: isEnglish, full: full);
    } else if (effectiveEnd.isNotEmpty) {
      endFormatted = effectiveEnd;
    }

    if (startFormatted.isNotEmpty && endFormatted.isNotEmpty) {
      return '$startFormatted - $endFormatted';
    } else if (startFormatted.isNotEmpty) {
      return startFormatted;
    } else if (endFormatted.isNotEmpty) {
      return endFormatted;
    }
    return '';
  }

  /// Formats single date e.g. for education graduation date.
  /// Converts "2020", "08/2020", or "agustus 2020" to "Agustus 2020" (or "August 2020" if English).
  static String formatEducationDate(
    String? date, {
    bool isEnglish = false,
    bool full = true,
    int? defaultMonth = 8,
  }) {
    if (date == null || date.trim().isEmpty) return '';
    final parts = parse(date);
    if (parts.hasMonth && parts.hasYear) {
      return formatMonthYear(parts.month, parts.year, isEnglish: isEnglish, full: full);
    } else if (parts.hasYear && defaultMonth != null) {
      return formatMonthYear(defaultMonth, parts.year, isEnglish: isEnglish, full: full);
    }
    return date.trim();
  }
}

