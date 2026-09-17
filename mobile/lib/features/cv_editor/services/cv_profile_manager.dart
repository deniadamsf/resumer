import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/cv_model.dart';

/// Manages 3 CV Profiles variations with offline-first persistence (SharedPreferences)
/// and automatic cloud sync with Laravel backend (`/api/v1/cv/profiles`).
class CvProfileManager extends ChangeNotifier {
  static final CvProfileManager instance = CvProfileManager._internal();
  CvProfileManager._internal();

  int _currentIndex = 1;
  final Map<int, CvDocument> _profiles = {};
  final Map<int, CvProfileMeta> _metas = {};
  bool _isSyncing = false;

  int get currentIndex => _currentIndex;
  bool get isSyncing => _isSyncing;

  CvDocument get currentCv => _profiles[_currentIndex] ?? _defaultTemplate(1);
  CvProfileMeta get currentMeta =>
      _metas[_currentIndex] ??
      CvProfileMeta(profileIndex: _currentIndex, title: 'CV $_currentIndex');

  CvDocument getProfile(int index) => _profiles[index] ?? _defaultTemplate(index);
  CvProfileMeta getMeta(int index) =>
      _metas[index] ?? CvProfileMeta(profileIndex: index, title: 'CV $index');

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentIndex = prefs.getInt('cv_active_profile_index') ?? 1;

    for (int i = 1; i <= 3; i++) {
      final jsonStr = prefs.getString('cv_profile_$i');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final map = json.decode(jsonStr) as Map<String, dynamic>;
          final doc = CvDocument.fromJson(map);
          // Auto-migrate legacy mock data (Alexander Wright)
          if (doc.personalInfo.fullName == 'Alexander Wright' ||
              doc.personalInfo.email == 'alexander.wright@executive.io') {
            _profiles[i] = _defaultTemplate(i);
            await _saveLocally(i);
          } else {
            _profiles[i] = doc;
          }
        } catch (_) {
          _profiles[i] = _defaultTemplate(i);
        }
      } else {
        _profiles[i] = _defaultTemplate(i);
      }

      final metaStr = prefs.getString('cv_meta_$i');
      if (metaStr != null && metaStr.isNotEmpty) {
        try {
          final map = json.decode(metaStr) as Map<String, dynamic>;
          _metas[i] = CvProfileMeta.fromJson(map);
        } catch (_) {
          _metas[i] = CvProfileMeta(profileIndex: i, title: 'CV $i');
        }
      } else {
        _metas[i] = CvProfileMeta(
          profileIndex: i,
          title: 'CV $i',
          targetJob: _profiles[i]?.personalInfo.professionalTitle ?? '',
        );
      }
    }

    notifyListeners();

    // Background sync from remote backend
    _fetchFromCloud();
  }

  Future<void> switchProfile(int newIndex, {CvDocument? currentDraft}) async {
    if (newIndex < 1 || newIndex > 3 || newIndex == _currentIndex) return;

    if (currentDraft != null) {
      _profiles[_currentIndex] = currentDraft.clone();
      await _saveLocally(_currentIndex);
    }

    _currentIndex = newIndex;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cv_active_profile_index', _currentIndex);

    notifyListeners();
  }

  Future<void> updateProfileMeta(
    int index, {
    String? title,
    String? targetJob,
    int? atsScore,
    String? atsVerdict,
    Map<String, dynamic>? atsBreakdown,
    List<dynamic>? atsFeedback,
  }) async {
    final meta = getMeta(index);
    if (title != null) meta.title = title;
    if (targetJob != null) meta.targetJob = targetJob;
    if (atsScore != null) meta.atsScore = atsScore;
    if (atsVerdict != null) meta.atsVerdict = atsVerdict;
    if (atsBreakdown != null) meta.atsBreakdown = atsBreakdown;
    if (atsFeedback != null) meta.atsFeedback = atsFeedback;
    _metas[index] = meta;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cv_meta_$index', json.encode(meta.toJson()));

    notifyListeners();
    _syncSingleProfileToCloud(index);
  }

  /// Updates the draft document for the current profile in memory immediately.
  /// Does NOT trigger notifyListeners() to avoid disrupting active typing in the editor.
  void updateDraftSilently(CvDocument doc) {
    _profiles[_currentIndex] = doc.clone();
  }

  /// Persists the current draft to local storage (SharedPreferences).
  Future<void> persistDraftLocally() async {
    await _saveLocally(_currentIndex);
  }

  Future<void> saveCurrentProfile(
    CvDocument doc, {
    int? atsScore,
    String? atsVerdict,
    Map<String, dynamic>? atsBreakdown,
    List<dynamic>? atsFeedback,
    bool notify = true,
  }) async {
    _profiles[_currentIndex] = doc.clone();
    if (atsScore != null || atsVerdict != null || atsBreakdown != null || atsFeedback != null) {
      final meta = getMeta(_currentIndex);
      if (atsScore != null) meta.atsScore = atsScore;
      if (atsVerdict != null) meta.atsVerdict = atsVerdict;
      if (atsBreakdown != null) meta.atsBreakdown = atsBreakdown;
      if (atsFeedback != null) meta.atsFeedback = atsFeedback;
      _metas[_currentIndex] = meta;
    }

    await _saveLocally(_currentIndex);
    if (notify) {
      notifyListeners();
    }

    await _syncSingleProfileToCloud(_currentIndex);
  }

  Future<void> _saveLocally(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final doc = _profiles[index];
    if (doc != null) {
      await prefs.setString('cv_profile_$index', json.encode(doc.toJson()));
    }
    final meta = _metas[index];
    if (meta != null) {
      await prefs.setString('cv_meta_$index', json.encode(meta.toJson()));
    }
  }

  Future<void> _fetchFromCloud() async {
    if (!ApiService.instance.isAuthenticated) return;

    try {
      final res = await ApiService.instance.getProfiles();
      if (res['success'] == true && res['profiles'] is List) {
        final list = res['profiles'] as List;
        for (final item in list) {
          final idx = item['profile_index'] as int? ?? 1;
          if (idx >= 1 && idx <= 3 && item['cv_data'] is Map) {
            final doc = CvDocument.fromJson(item['cv_data'] as Map<String, dynamic>);
            _profiles[idx] = doc;

            final existingMeta = _metas[idx];
            _metas[idx] = CvProfileMeta(
              profileIndex: idx,
              title: item['title'] as String? ?? 'CV $idx',
              targetJob: item['target_job'] as String? ?? '',
              atsScore: item['ats_score'] as int?,
              atsVerdict: existingMeta?.atsVerdict,
              atsBreakdown: existingMeta?.atsBreakdown,
              atsFeedback: existingMeta?.atsFeedback,
            );

            await _saveLocally(idx);
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _syncSingleProfileToCloud(int index) async {
    if (!ApiService.instance.isAuthenticated) return;

    final doc = _profiles[index];
    final meta = getMeta(index);
    if (doc == null) return;

    _isSyncing = true;
    notifyListeners();

    try {
      await ApiService.instance.saveProfile(
        profileIndex: index,
        title: meta.title,
        targetJob: meta.targetJob.isNotEmpty ? meta.targetJob : doc.personalInfo.professionalTitle,
        templateId: doc.templateId,
        fontFamily: doc.fontFamily,
        accentColor: doc.accentColor,
        cvData: doc.toJson(),
        atsScore: meta.atsScore,
      );
    } catch (_) {
      // Offline fallback: data is safe locally
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Wipes all local CV documents and resets to clean blank templates
  Future<void> clearAllLocalProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 3; i++) {
      _profiles[i] = _defaultTemplate(i);
      _metas[i] = CvProfileMeta(profileIndex: i, title: 'CV $i', targetJob: '');
      await prefs.remove('cv_profile_$i');
      await prefs.remove('cv_meta_$i');
    }
    _currentIndex = 1;
    await prefs.setInt('cv_active_profile_index', 1);
    notifyListeners();
  }

  static CvDocument _defaultTemplate(int index) {
    return CvDocument(
      templateId: index == 2 ? 'western_strict' : 'asian_ats',
      personalInfo: PersonalInfo(
        fullName: '',
        professionalTitle: '',
        email: '',
        phone: '',
        location: '',
        linkedin: '',
      ),
      summary: '',
      experiences: [],
      educations: [],
      skills: [],
      certifications: [],
      languages: [],
    );
  }
}
