import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 100% Client-Side Local Storage Service for Candidate Digital Signatures.
/// Data is stored as Base64 in device SharedPreferences (0 Byte server cost/privasi mutlak).
class SignatureService extends ChangeNotifier {
  static final SignatureService instance = SignatureService._internal();
  SignatureService._internal();

  static const String _storageKey = 'user_digital_signature_png_base64';

  Uint8List? _cachedSignatureBytes;

  Uint8List? get cachedSignatureBytes => _cachedSignatureBytes;
  bool get hasSignature => _cachedSignatureBytes != null && _cachedSignatureBytes!.isNotEmpty;

  /// Initializes the service and loads any cached signature from local storage.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString(_storageKey);
      if (base64String != null && base64String.isNotEmpty) {
        _cachedSignatureBytes = base64Decode(base64String);
      } else {
        _cachedSignatureBytes = null;
      }
    } catch (e) {
      debugPrint('Error loading signature from local storage: $e');
      _cachedSignatureBytes = null;
    }
    notifyListeners();
  }

  /// Retrieves the saved signature bytes from local device database.
  Future<Uint8List?> getSignature() async {
    if (_cachedSignatureBytes != null) return _cachedSignatureBytes;
    await init();
    return _cachedSignatureBytes;
  }

  /// Saves signature PNG bytes to local device database.
  Future<bool> saveSignature(Uint8List bytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = base64Encode(bytes);
      final success = await prefs.setString(_storageKey, base64String);
      if (success) {
        _cachedSignatureBytes = bytes;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error saving signature to local storage: $e');
      return false;
    }
  }

  /// Clears saved signature from local device database.
  Future<bool> deleteSignature() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_storageKey);
      if (success) {
        _cachedSignatureBytes = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting signature from local storage: $e');
      return false;
    }
  }
}
