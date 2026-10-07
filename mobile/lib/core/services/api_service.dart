import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../localization/app_localizations.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  static const String baseUrl = 'https://resumer.cellanoma.my.id/api/v1';
  static const String hmacSecret = 'resumer_super_secret_hmac_key_2026';
  static const MethodChannel _deviceChannel = MethodChannel('com.cellanoma.resumer/device');

  String? _authToken;
  String? _deviceUuid;
  String? _legacyDeviceUuid;
  String? _userName;
  String? _userEmail;
  String? _userAvatar;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _userAvatar = prefs.getString('user_avatar');

    await _initDeviceId(prefs);

    // Auto-clean legacy dummy mock data
    if (_userName == 'Alexander Wright' || _userName == 'Tamu Eksekutif') {
      _userName = 'Tamu Resumer';
      await prefs.setString('user_name', _userName!);
    }
    if (_userEmail == 'alexander.wright@executive.io' || _userEmail == 'tamu@resumer.cellanoma.my.id') {
      _userEmail = 'guest@resumer.app';
      await prefs.setString('user_email', _userEmail!);
    }
  }

  /// Menentukan Device ID yang stabil.
  /// - Android: SHA-256 dari ANDROID_ID (tetap sama walau uninstall/reinstall atau Clear Data).
  /// - Platform lain / gagal: UUID acak yang disimpan lokal (perilaku lama).
  /// UUID acak lama disimpan sebagai `legacy_device_uuid` agar server tetap mengenali
  /// perangkat yang sudah pernah klaim bonus sebelum update ini.
  Future<void> _initDeviceId(SharedPreferences prefs) async {
    final storedId = prefs.getString('device_uuid');
    _legacyDeviceUuid = prefs.getString('legacy_device_uuid');

    final hardwareId = await _resolveHardwareDeviceId();
    if (hardwareId != null) {
      if (storedId != null && storedId != hardwareId && !storedId.startsWith('aid_')) {
        _legacyDeviceUuid = storedId;
        await prefs.setString('legacy_device_uuid', storedId);
      }
      _deviceUuid = hardwareId;
      if (storedId != hardwareId) {
        await prefs.setString('device_uuid', hardwareId);
      }
      return;
    }

    _deviceUuid = storedId ?? const Uuid().v4();
    if (storedId == null) {
      await prefs.setString('device_uuid', _deviceUuid!);
    }
  }

  Future<String?> _resolveHardwareDeviceId() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final androidId = await _deviceChannel.invokeMethod<String>('getAndroidId');
      if (androidId == null || androidId.isEmpty) return null;
      // Di-hash agar ANDROID_ID mentah tidak pernah dikirim/disimpan di server.
      final digest = sha256.convert(utf8.encode('resumer:$androidId'));
      return 'aid_$digest';
    } catch (e) {
      debugPrint('[ApiService] Failed to read ANDROID_ID, using fallback UUID: $e');
      return null;
    }
  }

  bool get isAuthenticated => _authToken != null;
  bool get isGuestMode => _authToken == 'guest_mode_token' || _authToken == 'guest_sanctum_token';
  String get deviceUuid => _deviceUuid ?? 'unknown-device';
  String get userName => _userName ?? 'Pengguna Resumer';
  String get userEmail => _userEmail ?? 'guest@resumer.app';
  String? get userAvatar => _userAvatar;

  Future<void> saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> saveUserData({
    required String name,
    required String email,
    String? avatar,
  }) async {
    _userName = name;
    _userEmail = email;
    _userAvatar = avatar;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    if (avatar != null) {
      await prefs.setString('user_avatar', avatar);
    }
  }

  Future<Map<String, dynamic>> updateUserName(String newName) async {
    _userName = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);

    if (isAuthenticated) {
      final url = Uri.parse('$baseUrl/user/profile');
      final body = json.encode({'name': newName});
      try {
        final response = await http.put(url, headers: _buildHeaders(body), body: body);
        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }
      } catch (_) {}
    }

    return {
      'success': true,
      'message': 'profile.user_name_updated'.tr,
      'user': {'name': newName},
    };
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    if (!isAuthenticated) return {'success': false};
    final url = Uri.parse('$baseUrl/user/profile');
    try {
      final response = await http.get(url, headers: _buildHeaders(''));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['user'] != null) {
          final u = data['user'] as Map<String, dynamic>;
          await saveUserData(
            name: u['name'] ?? userName,
            email: u['email'] ?? userEmail,
            avatar: u['avatar_url'] ?? userAvatar,
          );
        }
        return data;
      }
    } catch (_) {}
    return {'success': false};
  }

  Future<void> clearAuth() async {
    _authToken = null;
    _userName = null;
    _userEmail = null;
    _userAvatar = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_avatar');
    await AuthService.instance.signOut();
  }

  Map<String, String> _buildHeaders(String body) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final payloadToSign = '$timestamp.$body';
    final hmacKey = utf8.encode(hmacSecret);
    final hmac = Hmac(sha256, hmacKey);
    final signature = hmac.convert(utf8.encode(payloadToSign)).toString();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Resumer-Timestamp': timestamp,
      'X-Resumer-Signature': signature,
      'X-Device-UUID': deviceUuid,
    };

    if (_legacyDeviceUuid != null) {
      headers['X-Legacy-Device-UUID'] = _legacyDeviceUuid!;
    }

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<Map<String, dynamic>> getAppConfig() async {
    final url = Uri.parse('$baseUrl/app-config');
    final response = await http.get(url, headers: _buildHeaders(''));
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final url = Uri.parse('$baseUrl/auth/google');
    final body = json.encode({
      'id_token': idToken,
      'device_uuid': deviceUuid,
      if (_legacyDeviceUuid != null) 'legacy_device_uuid': _legacyDeviceUuid,
    });

    final response = await http.post(url, headers: _buildHeaders(body), body: body);
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && data['token'] != null) {
      await saveToken(data['token']);
      if (data['user'] != null) {
        final u = data['user'] as Map<String, dynamic>;
        await saveUserData(
          name: u['name'] ?? userName,
          email: u['email'] ?? userEmail,
          avatar: u['avatar_url'],
        );
      }
    }

    return data;
  }

  Future<Map<String, dynamic>> getQuota() async {
    final url = Uri.parse('$baseUrl/user/quota');
    final response = await http.get(url, headers: _buildHeaders(''));
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfiles() async {
    final url = Uri.parse('$baseUrl/cv/profiles');
    final response = await http.get(url, headers: _buildHeaders(''));
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> saveProfile({
    required int profileIndex,
    required String title,
    required Map<String, dynamic> cvData,
    String? targetJob,
    String templateId = 'asian_ats',
    String fontFamily = 'Outfit',
    String accentColor = '#0B132B',
    int? atsScore,
  }) async {
    final url = Uri.parse('$baseUrl/cv/profiles');
    final body = json.encode({
      'profile_index': profileIndex,
      'title': title,
      'target_job': targetJob,
      'template_id': templateId,
      'font_family': fontFamily,
      'accent_color': accentColor,
      'cv_data': cvData,
      'ats_score': atsScore,
    });

    final response = await http.post(url, headers: _buildHeaders(body), body: body);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> generateCv(
    Map<String, dynamic> candidateInput, {
    bool bypassQuota = false,
  }) async {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final url = Uri.parse('$baseUrl/cv/generate');
    final payload = Map<String, dynamic>.from(candidateInput);
    payload['language'] = AppLocalizations.instance.currentLocale;
    if (bypassQuota) {
      payload['bypass_quota'] = true;
    }
    final body = json.encode(payload);
    try {
      final headers = _buildHeaders(body);
      if (bypassQuota) {
        headers['X-Bypass-Quota'] = 'true';
      }
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final err = json.decode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'message': err['message'] ??
                (isEn
                    ? 'Failed to polish CV (${response.statusCode})'
                    : 'Gagal memoles CV (${response.statusCode})'),
            'quota': err['quota'],
          };
        } catch (_) {
          return {
            'success': false,
            'message': isEn
                ? 'Server returned status ${response.statusCode}'
                : 'Server mengembalikan status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': isEn
            ? 'Unable to connect to server. Please check your internet connection.'
            : 'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      };
    }
  }

  Future<Map<String, dynamic>> checkAtsScore(String cvText, {String? targetRole, int? profileId}) async {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');

    if (cvText.trim().length < 50) {
      return {
        'success': false,
        'message': isEn
            ? 'CV data is incomplete or empty. Please fill in your details in the Editor tab first.'
            : 'Data CV masih kosong atau belum lengkap. Silakan lengkapi profil Anda di tab Editor terlebih dahulu.',
      };
    }

    final url = Uri.parse('$baseUrl/cv/ats-check');
    final body = json.encode({
      'cv_text': cvText,
      'target_role': targetRole,
      'cv_profile_id': profileId,
      'language': AppLocalizations.instance.currentLocale,
    });
    try {
      final response = await http.post(url, headers: _buildHeaders(body), body: body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final err = json.decode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'message': err['message'] ??
                (isEn
                    ? 'Failed to process ATS check (${response.statusCode})'
                    : 'Gagal memproses pengujian ATS (${response.statusCode})'),
          };
        } catch (_) {
          return {
            'success': false,
            'message': isEn
                ? 'Server returned status ${response.statusCode}'
                : 'Server mengembalikan status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': isEn
            ? 'Unable to connect to server. Please check your internet connection.'
            : 'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      };
    }
  }

  Future<Map<String, dynamic>> autoFixAts(
    String cvText, {
    List<dynamic> suggestions = const [],
    bool bypassQuota = false,
  }) async {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');

    if (cvText.trim().length < 50) {
      return {
        'success': false,
        'message': isEn
            ? 'CV data is incomplete or empty. Please fill in your details in the Editor tab first.'
            : 'Data CV masih kosong atau belum lengkap. Silakan lengkapi profil Anda di tab Editor terlebih dahulu.',
      };
    }

    final url = Uri.parse('$baseUrl/cv/ats-autofix');
    final body = json.encode({
      'cv_text': cvText,
      'suggestions': suggestions,
      'language': AppLocalizations.instance.currentLocale,
      'bypass_quota': bypassQuota,
    });
    try {
      final headers = _buildHeaders(body);
      if (bypassQuota) {
        headers['X-Bypass-Quota'] = 'true';
      }
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final err = json.decode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'message': err['message'] ??
                (isEn
                    ? 'Failed to auto-fix CV (${response.statusCode})'
                    : 'Gagal memoles CV (${response.statusCode})'),
          };
        } catch (_) {
          return {
            'success': false,
            'message': isEn
                ? 'Server returned status ${response.statusCode}'
                : 'Server mengembalikan status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': isEn
            ? 'Unable to connect to server. Please check your internet connection.'
            : 'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      };
    }
  }

  Future<Map<String, dynamic>> matchJob(String cvText, {String? jobText, String? jobImageBase64}) async {
    final url = Uri.parse('$baseUrl/cv/job-match');
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final body = json.encode({
      'cv_text': cvText,
      'job_text': jobText,
      'job_image': jobImageBase64,
      'language': AppLocalizations.instance.currentLocale,
    });
    try {
      final response = await http.post(url, headers: _buildHeaders(body), body: body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final err = json.decode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'statusCode': response.statusCode,
            'message': err['message'] ??
                (isEn
                    ? 'Failed to match job (${response.statusCode})'
                    : 'Gagal menganalisis kecocokan loker (${response.statusCode})'),
          };
        } catch (_) {
          return {
            'success': false,
            'statusCode': response.statusCode,
            'message': isEn
                ? 'Server returned status ${response.statusCode}'
                : 'Server mengembalikan status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': isEn
            ? 'Unable to connect to server. Please check your internet connection.'
            : 'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      };
    }
  }

  Future<Map<String, dynamic>> tailorJobCv({
    required String cvText,
    String? jobText,
    List<String>? suggestions,
    List<String>? missingKeywords,
  }) async {
    final url = Uri.parse('$baseUrl/cv/job-tailor');
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final body = json.encode({
      'cv_text': cvText,
      if (jobText != null && jobText.isNotEmpty) 'job_text': jobText,
      if (suggestions != null && suggestions.isNotEmpty) 'suggestions': suggestions,
      if (missingKeywords != null && missingKeywords.isNotEmpty) 'missing_keywords': missingKeywords,
      'language': AppLocalizations.instance.currentLocale,
    });
    try {
      final response = await http.post(url, headers: _buildHeaders(body), body: body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        try {
          final err = json.decode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'statusCode': response.statusCode,
            'message': err['message'] ??
                (isEn ? 'Failed to tailor CV (${response.statusCode})' : 'Gagal menyesuaikan CV (${response.statusCode})'),
          };
        } catch (_) {
          return {
            'success': false,
            'statusCode': response.statusCode,
            'message': isEn ? 'Server returned status ${response.statusCode}' : 'Server mengembalikan status ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': isEn
            ? 'Unable to connect to server. Please check your internet connection.'
            : 'Gagal terhubung ke server. Periksa koneksi internet Anda.',
      };
    }
  }

  Future<Map<String, dynamic>> generateCoverLetter(String cvText, String company, String role) async {
    final url = Uri.parse('$baseUrl/cv/cover-letter');
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final body = json.encode({
      'cv_text': cvText,
      'company_name': company,
      'target_role': role,
      'language': AppLocalizations.instance.currentLocale,
    });
    try {
      final response = await http.post(url, headers: _buildHeaders(body), body: body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}

    return {
      'success': true,
      'cover_letter': isEn
          ? {
              'salutation': 'Dear Hiring Team at $company,',
              'paragraph_1': 'I am writing to express my strong enthusiasm for the $role position at $company. With a robust background in enterprise data architecture, automated pipeline engineering, and executive-grade business intelligence, I am confident in my ability to deliver measurable value toward your strategic objectives.',
              'paragraph_2': 'Throughout my career, I have spearheaded data infrastructure modernizations, cloud migrations, and high-frequency ETL pipelines that enhanced operational efficiency by up to 35%. My approach combines rigorous quantitative accountability with collaborative leadership to solve complex data challenges at scale.',
              'paragraph_3': 'I look forward to discussing how my experience and passion for data-driven innovation can contribute to the continued growth of $company. Thank you for your time and consideration.',
              'signoff': 'Sincerely,\n$userName'
            }
          : {
              'salutation': 'Kepada Tim Rekrutmen yang Terhormat di $company,',
              'paragraph_1': 'Saya menulis surat ini untuk menyampaikan ketertarikan mendalam saya terhadap posisi $role di $company. Dengan latar belakang yang kuat dalam arsitektur analitika data enterprise, perancangan data pipeline, serta visualisasi eksekutif, saya yakin dapat memberikan kontribusi terukur terhadap target strategis perusahaan.',
              'paragraph_2': 'Sepanjang karir profesional saya, saya telah memimpin otomasi pipeline data, optimasi arsitektur cloud, dan pelaporan intelijen bisnis yang meningkatkan efisiensi operasional hingga 35%. Pendekatan terstruktur dengan formula capaian berdampak tinggi selalu menjadi fondasi kerja saya dalam menyelesaikan tantangan bisnis skala besar.',
              'paragraph_3': 'Saya sangat antusias untuk berdiskusi lebih lanjut mengenai bagaimana pengalaman dan dedikasi saya dapat memperkuat kapabilitas tim di $company. Terima kasih banyak atas waktu dan pertimbangan yang diberikan.',
              'signoff': 'Hormat saya,\n$userName'
            }
    };
  }

  /// Ambil saldo koin dan status bonus perangkat
  Future<Map<String, dynamic>> getCoinsBalance() async {
    final url = Uri.parse('$baseUrl/coins/balance');
    try {
      final response = await http.get(url, headers: _buildHeaders(''));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'success': false, 'coins': 0};
  }

  /// Klaim bonus selamat datang 5 koin (Device UUID locked)
  Future<Map<String, dynamic>> claimWelcomeBonus() async {
    final url = Uri.parse('$baseUrl/coins/claim-welcome');
    final body = json.encode({'device_uuid': deviceUuid});
    try {
      final response = await http.post(url, headers: _buildHeaders(body), body: body);
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {}
    return {'success': false, 'message': 'Gagal mengklaim bonus selamat datang.'};
  }

  /// Verifikasi pembelian In-App Purchase dari Google Play ke Backend
  Future<Map<String, dynamic>> verifyIapPurchase({
    required String orderId,
    required String productId,
    required String purchaseToken,
  }) async {
    final url = Uri.parse('$baseUrl/coins/verify-purchase');
    final body = json.encode({
      'order_id': orderId,
      'product_id': productId,
      'purchase_token': purchaseToken,
    });
    try {
      final response = await http.post(url, headers: _buildHeaders(body), body: body);
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {}
    return {'success': false, 'message': 'Gagal memverifikasi pembelian koin.'};
  }

  /// Gunakan koin untuk aksi tertentu (Job Matcher, Ekspor PDF, dsb.)
  Future<Map<String, dynamic>> spendCoins({
    required int amount,
    required String actionType,
    String? description,
  }) async {
    final url = Uri.parse('$baseUrl/coins/spend');
    final body = json.encode({
      'amount': amount,
      'action_type': actionType,
      'description': description,
    });
    try {
      final response = await http.post(url, headers: _buildHeaders(body), body: body);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        decoded['statusCode'] = 200;
        return decoded;
      } else {
        try {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          decoded['statusCode'] = response.statusCode;
          return decoded;
        } catch (_) {
          return {'success': false, 'statusCode': response.statusCode};
        }
      }
    } catch (_) {}
    return {'success': false, 'message': 'Gagal memproses transaksi koin.'};
  }

  /// Pengembalian koin jika operasi AI gagal di downstream
  Future<Map<String, dynamic>> refundCoins({
    required int amount,
    required String reason,
    required String originalAction,
  }) async {
    final url = Uri.parse('$baseUrl/coins/refund');
    final body = json.encode({
      'amount': amount,
      'reason': reason,
      'original_action': originalAction,
    });
    try {
      final response = await http.post(url, headers: _buildHeaders(body), body: body);
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {}
    return {'success': false};
  }
}
