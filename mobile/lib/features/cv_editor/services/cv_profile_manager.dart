import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
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

  /// Directory for persistent local storage of profile photos
  Future<Directory> _getPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/cv_photos');
    if (!photosDir.existsSync()) {
      await photosDir.create(recursive: true);
    }
    return photosDir;
  }

  /// Copies a picked/temporary photo to permanent local storage and associates it with profile [profileIndex]
  Future<String> saveProfilePhoto(int profileIndex, String sourcePath) async {
    final photosDir = await _getPhotosDirectory();
    final ext = sourcePath.contains('.') ? '.${sourcePath.split('.').last}' : '.jpg';
    final targetFileName = 'cv_photo_p${profileIndex}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final targetFile = File('${photosDir.path}/$targetFileName');

    // Delete existing photo file for this profile if any
    await _deleteExistingPhotoFileForProfile(profileIndex);

    // Copy to permanent app documents storage
    await File(sourcePath).copy(targetFile.path);
    final permanentPath = targetFile.path;

    // Persist path in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cv_photo_path_$profileIndex', permanentPath);
    await prefs.setString('user_master_photo_path', permanentPath);

    // Update profile in memory
    final doc = _profiles[profileIndex];
    if (doc != null) {
      doc.personalInfo.localPhotoPath = permanentPath;
      await _saveLocally(profileIndex);
    }

    notifyListeners();
    return permanentPath;
  }

  /// Explicitly deletes the local photo for profile [profileIndex]
  Future<void> deleteProfilePhoto(int profileIndex) async {
    await _deleteExistingPhotoFileForProfile(profileIndex);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cv_photo_path_$profileIndex');

    final currentMaster = prefs.getString('user_master_photo_path');
    final doc = _profiles[profileIndex];
    if (doc != null && doc.personalInfo.localPhotoPath != null) {
      if (currentMaster == doc.personalInfo.localPhotoPath) {
        await prefs.remove('user_master_photo_path');
      }
      doc.personalInfo.localPhotoPath = null;
      await _saveLocally(profileIndex);
    }

    notifyListeners();
  }

  Future<void> _deleteExistingPhotoFileForProfile(int profileIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldPath = prefs.getString('cv_photo_path_$profileIndex') ??
          _profiles[profileIndex]?.personalInfo.localPhotoPath;
      if (oldPath != null && oldPath.isNotEmpty) {
        final oldFile = File(oldPath);
        if (oldFile.existsSync()) {
          await oldFile.delete();
        }
      }
    } catch (_) {}
  }

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

      // Check and restore persistent local photo path
      final savedPhotoPath = prefs.getString('cv_photo_path_$i') ??
          prefs.getString('user_master_photo_path');
      if (savedPhotoPath != null && savedPhotoPath.isNotEmpty) {
        if (File(savedPhotoPath).existsSync()) {
          _profiles[i]?.personalInfo.localPhotoPath = savedPhotoPath;
        } else {
          await prefs.remove('cv_photo_path_$i');
        }
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

    // Ensure target profile has its local photo restored if available
    final targetDoc = _profiles[_currentIndex];
    if (targetDoc != null && targetDoc.personalInfo.localPhotoPath == null) {
      final savedPhoto = prefs.getString('cv_photo_path_$_currentIndex') ??
          prefs.getString('user_master_photo_path');
      if (savedPhoto != null && File(savedPhoto).existsSync()) {
        targetDoc.personalInfo.localPhotoPath = savedPhoto;
      }
    }

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
      // Use toLocalMap() so localPhotoPath is safely preserved in SharedPreferences
      await prefs.setString('cv_profile_$index', json.encode(doc.toLocalMap()));
      if (doc.personalInfo.localPhotoPath != null &&
          File(doc.personalInfo.localPhotoPath!).existsSync()) {
        await prefs.setString('cv_photo_path_$index', doc.personalInfo.localPhotoPath!);
      } else if (doc.personalInfo.localPhotoPath == null) {
        await prefs.remove('cv_photo_path_$index');
      }
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
        final prefs = await SharedPreferences.getInstance();
        final list = res['profiles'] as List;
        for (final item in list) {
          final idx = item['profile_index'] as int? ?? 1;
          if (idx >= 1 && idx <= 3 && item['cv_data'] is Map) {
            final doc = CvDocument.fromJson(item['cv_data'] as Map<String, dynamic>);

            final localDoc = _profiles[idx];
            final hasLocalData = localDoc != null &&
                (localDoc.personalInfo.fullName.isNotEmpty ||
                 localDoc.experiences.isNotEmpty ||
                 localDoc.educations.isNotEmpty);

            if (hasLocalData && idx == _currentIndex) {
              // Update only ATS score & metadata from cloud, keep local edits intact
              final existingMeta = _metas[idx];
              _metas[idx] = CvProfileMeta(
                profileIndex: idx,
                title: existingMeta?.title ?? (item['title'] as String? ?? 'CV $idx'),
                targetJob: (existingMeta?.targetJob.isNotEmpty ?? false)
                    ? existingMeta!.targetJob
                    : (item['target_job'] as String? ?? ''),
                atsScore: item['ats_score'] as int? ?? existingMeta?.atsScore,
                atsVerdict: existingMeta?.atsVerdict,
                atsBreakdown: existingMeta?.atsBreakdown,
                atsFeedback: existingMeta?.atsFeedback,
              );
              await prefs.setString('cv_meta_$idx', json.encode(_metas[idx]!.toJson()));
              continue;
            }

            // PRESERVE LOCAL PHOTO: Server strictly never stores photos (0-byte server load rule).
            // Restore local photo path from memory or SharedPreferences so cloud sync never wipes it.
            final localPhoto = _profiles[idx]?.personalInfo.localPhotoPath ??
                prefs.getString('cv_photo_path_$idx') ??
                prefs.getString('user_master_photo_path');
            if (localPhoto != null && File(localPhoto).existsSync()) {
              doc.personalInfo.localPhotoPath = localPhoto;
            }

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

  /// Wipes all local CV documents, clears photos from disk, and resets to clean blank templates
  Future<void> clearAllLocalProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 3; i++) {
      await _deleteExistingPhotoFileForProfile(i);
      _profiles[i] = _defaultTemplate(i);
      _metas[i] = CvProfileMeta(profileIndex: i, title: 'CV $i', targetJob: '');
      await prefs.remove('cv_profile_$i');
      await prefs.remove('cv_meta_$i');
      await prefs.remove('cv_photo_path_$i');
    }
    await prefs.remove('user_master_photo_path');
    try {
      final photosDir = await _getPhotosDirectory();
      if (photosDir.existsSync()) {
        photosDir.deleteSync(recursive: true);
      }
    } catch (_) {}
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
