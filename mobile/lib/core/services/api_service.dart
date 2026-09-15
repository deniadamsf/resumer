import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  static const String baseUrl = 'https://resumer.cellanoma.my.id/api/v1';
  static const String hmacSecret = 'resumer_super_secret_hmac_key_2026';

  String? _authToken;
  String? _deviceUuid;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _deviceUuid = prefs.getString('device_uuid');

    if (_deviceUuid == null) {
      _deviceUuid = const Uuid().v4();
      await prefs.setString('device_uuid', _deviceUuid!);
    }
  }

  bool get isAuthenticated => _authToken != null;
  String get deviceUuid => _deviceUuid ?? 'unknown-device';

  Future<void> saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearAuth() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
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
    });

    final response = await http.post(url, headers: _buildHeaders(body), body: body);
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && data['token'] != null) {
      await saveToken(data['token']);
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

  Future<Map<String, dynamic>> generateCv(Map<String, dynamic> candidateInput) async {
    final url = Uri.parse('$baseUrl/cv/generate');
    final body = json.encode(candidateInput);
    final response = await http.post(url, headers: _buildHeaders(body), body: body);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkAtsScore(String cvText, {String? targetRole, int? profileId}) async {
    final url = Uri.parse('$baseUrl/cv/ats-check');
    final body = json.encode({
      'cv_text': cvText,
      'target_role': targetRole,
      'cv_profile_id': profileId,
    });
    final response = await http.post(url, headers: _buildHeaders(body), body: body);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> autoFixAts(String cvText, {List<dynamic> suggestions = const []}) async {
    final url = Uri.parse('$baseUrl/cv/ats-autofix');
    final body = json.encode({
      'cv_text': cvText,
      'suggestions': suggestions,
    });
    final response = await http.post(url, headers: _buildHeaders(body), body: body);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> matchJob(String cvText, {String? jobText, String? jobImageBase64}) async {
    final url = Uri.parse('$baseUrl/cv/job-match');
    final body = json.encode({
      'cv_text': cvText,
      'job_text': jobText,
      'job_image': jobImageBase64,
    });
    final response = await http.post(url, headers: _buildHeaders(body), body: body);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> generateCoverLetter(String cvText, String company, String role) async {
    final url = Uri.parse('$baseUrl/cv/cover-letter');
    final body = json.encode({
      'cv_text': cvText,
      'company_name': company,
      'target_role': role,
    });
    final response = await http.post(url, headers: _buildHeaders(body), body: body);
    return json.decode(response.body) as Map<String, dynamic>;
  }
}
