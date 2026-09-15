import 'dart:convert';
import 'package:flutter/services.dart';

/// Sistem Lokalisasi Ekstensi `.tr` dengan automatic fallback ke `en_US`
/// Mematuhi aturan proyek pada GEMINI.md Bagian 5
class AppLocalizations {
  static final AppLocalizations instance = AppLocalizations._internal();
  AppLocalizations._internal();

  Map<String, dynamic> _localizedStrings = {};
  Map<String, dynamic> _fallbackStrings = {};
  String currentLocale = 'id_ID';

  Future<void> init([String locale = 'id_ID']) async {
    currentLocale = locale;
    try {
      final enJson = await rootBundle.loadString('assets/lang/en_US.json');
      _fallbackStrings = json.decode(enJson) as Map<String, dynamic>;
    } catch (_) {
      _fallbackStrings = {};
    }

    if (locale != 'en_US') {
      try {
        final locJson = await rootBundle.loadString('assets/lang/$locale.json');
        _localizedStrings = json.decode(locJson) as Map<String, dynamic>;
      } catch (_) {
        _localizedStrings = _fallbackStrings;
      }
    } else {
      _localizedStrings = _fallbackStrings;
    }
  }

  String translate(String key, {List<String>? args}) {
    final keys = key.split('.');
    dynamic current = _localizedStrings;

    for (final k in keys) {
      if (current is Map && current.containsKey(k)) {
        current = current[k];
      } else {
        current = null;
        break;
      }
    }

    // Fallback to en_US if key is not found in primary language
    if (current == null) {
      current = _fallbackStrings;
      for (final k in keys) {
        if (current is Map && current.containsKey(k)) {
          current = current[k];
        } else {
          return key; // return key as final fallback
        }
      }
    }

    String result = current.toString();
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        result = result.replaceAll('{$i}', args[i]);
      }
    }
    return result;
  }
}

/// Helper extension untuk pemanggilan sintaks `*.tr`
extension TranslationExtension on String {
  String get tr => AppLocalizations.instance.translate(this);

  String trArgs(List<String> args) =>
      AppLocalizations.instance.translate(this, args: args);
}
