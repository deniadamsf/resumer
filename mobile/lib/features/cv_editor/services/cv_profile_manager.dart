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
          _profiles[i] = CvDocument.fromJson(map);
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
          title: i == 1 ? 'CV 1 - Executive Master' : 'CV $i',
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

  Future<void> updateProfileMeta(int index, {String? title, String? targetJob, int? atsScore}) async {
    final meta = getMeta(index);
    if (title != null) meta.title = title;
    if (targetJob != null) meta.targetJob = targetJob;
    if (atsScore != null) meta.atsScore = atsScore;
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

  Future<void> saveCurrentProfile(CvDocument doc, {int? atsScore, bool notify = true}) async {
    _profiles[_currentIndex] = doc.clone();
    if (atsScore != null) {
      final meta = getMeta(_currentIndex);
      meta.atsScore = atsScore;
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

            _metas[idx] = CvProfileMeta(
              profileIndex: idx,
              title: item['title'] as String? ?? 'CV $idx',
              targetJob: item['target_job'] as String? ?? '',
              atsScore: item['ats_score'] as int?,
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

  static CvDocument _defaultTemplate(int index) {
    if (index == 1) {
      return CvDocument(
        personalInfo: PersonalInfo(
          fullName: 'Alexander Wright',
          professionalTitle: 'Lead Mobile Architect',
          email: 'alexander.wright@executive.io',
          phone: '+62 812-9876-5432',
          location: 'Jakarta, Indonesia',
          linkedin: 'linkedin.com/in/alexander-wright',
        ),
        summary:
            'Accomplished Lead Mobile Architect with 7+ years of expertise architecting high-throughput fintech and SaaS solutions. Proven track record of scaling apps to 2M+ MAU with 99.98% crash-free sessions.',
        experiences: [
          WorkExperience(
            company: 'Zenith Global Technologies',
            position: 'Lead Mobile Engineer',
            startDate: '2022',
            endDate: 'Present',
            highlights: [
              'Architected client-side offline-first caching layer, cutting API latency by 45% for 1.2M active users.',
              'Spearheaded Flutter migration across 3 cross-functional teams, accelerating sprint delivery cycle by 35%.',
            ],
          ),
        ],
        educations: [
          Education(
            institution: 'Institute of Technology',
            degree: 'Bachelor of Science',
            fieldOfStudy: 'Computer Science',
            graduationYear: '2020',
            gpa: '3.85',
          ),
        ],
        skills: ['Flutter', 'Dart', 'Clean Architecture', 'REST APIs', 'CI/CD', 'Docker', 'SQLite']
            .map((s) => SkillItem(name: s))
            .toList(),
      );
    }

    return CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: index == 2 ? 'Senior Product Manager' : 'Data & BI Specialist',
        email: 'alexander.wright@executive.io',
        phone: '+62 812-9876-5432',
        location: 'Jakarta, Indonesia',
        linkedin: 'linkedin.com/in/alexander-wright',
      ),
      summary: index == 2
          ? 'Data-driven Product Manager with 5+ years driving high-conversion digital platforms, cross-functional engineering leadership, and user-centric growth.'
          : 'Analytical Data Specialist proficient in predictive modeling, enterprise data pipelines, and executive dashboards.',
      experiences: [],
      educations: [],
      skills: (index == 2
              ? ['Product Roadmapping', 'Agile/Scrum', 'User Research', 'A/B Testing', 'Growth Metrics']
              : ['SQL', 'Python', 'PowerBI', 'Tableau', 'ETL Pipelines', 'BigQuery'])
          .map((s) => SkillItem(name: s))
          .toList(),
    );
  }
}
