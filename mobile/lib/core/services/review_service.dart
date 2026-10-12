import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service: ReviewService
/// Mengelola Google Play In-App Review & Store Rating secara etis & cerdas
/// Mematuhi Google Play In-App Review API Guidelines & Zero-Spam Policy.
class ReviewService {
  static final ReviewService instance = ReviewService._internal();
  ReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;

  static const String _keyLastRequestTimestamp = 'review_last_request_timestamp';
  static const String _keyHasRated = 'review_has_rated_or_reviewed';
  static const String _keySuccessfulActionsCount = 'review_successful_actions_count';

  /// Jeda waktu minimal antar prompt otomatis (7 hari) agar tidak mengganggu pengguna
  static const int _minimumDaysBetweenPrompts = 7;

  /// Jumlah minimal momen kepuasan (Aha moments) sebelum prompt pertama
  static const int _minimumActionsRequired = 1;

  SharedPreferences? _prefs;

  /// Inisialisasi awal (dipanggil di main.dart)
  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('[ReviewService] Init error: $e');
    }
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Membuka store listing di Google Play Store atau App Store secara langsung.
  /// Digunakan ketika pengguna secara sadar mengklik tombol "Beri Rating & Ulasan" di Profil/Pengaturan.
  Future<void> openStoreListing() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_keyHasRated, true);

      final isAvailable = await _inAppReview.isAvailable();
      debugPrint('[ReviewService] Opening store listing (available: $isAvailable)...');
      await _inAppReview.openStoreListing();
    } catch (e) {
      debugPrint('[ReviewService] openStoreListing failed: $e');
    }
  }

  /// Mencatat aksi bernilai tinggi yang berhasil diselesaikan pengguna
  /// (misal: Ekspor PDF CV, Salin/Ekspor Surat Lamaran, Skor ATS Tinggi).
  ///
  /// Secara otomatis dapat mengevaluasi dan memicu Google Play In-App Review
  /// di momen kepuasan puncak (Peak-End Rule) dengan delay halus.
  Future<void> recordSuccessfulAction({
    required String actionType,
    bool autoPromptIfEligible = true,
  }) async {
    try {
      final prefs = await _getPrefs();
      final currentCount = (prefs.getInt(_keySuccessfulActionsCount) ?? 0) + 1;
      await prefs.setInt(_keySuccessfulActionsCount, currentCount);

      debugPrint('[ReviewService] Action recorded: $actionType (total: $currentCount)');

      if (autoPromptIfEligible && currentCount >= _minimumActionsRequired) {
        // Berikan delay halus (1800ms) agar transisi UI, haptic, atau snackbar selesai
        Timer(const Duration(milliseconds: 1800), () {
          requestReviewIfAppropriate(trigger: actionType);
        });
      }
    } catch (e) {
      debugPrint('[ReviewService] recordSuccessfulAction failed: $e');
    }
  }

  /// Meminta Google Play In-App Review secara non-intrusive jika kondisi terpenuhi.
  /// Mematuhi kuota internal Google Play & kebijakan anti-gatekeeping.
  Future<bool> requestReviewIfAppropriate({String trigger = 'unknown'}) async {
    try {
      final prefs = await _getPrefs();

      // 1. Cek apakah user sudah pernah menandai review / klik rating manual
      final hasRated = prefs.getBool(_keyHasRated) ?? false;
      if (hasRated) {
        debugPrint('[ReviewService] User already marked as reviewed. Skipping auto prompt.');
        return false;
      }

      // 2. Cek jeda waktu sejak prompt terakhir
      final lastPromptMillis = prefs.getInt(_keyLastRequestTimestamp) ?? 0;
      if (lastPromptMillis > 0) {
        final lastPromptDate = DateTime.fromMillisecondsSinceEpoch(lastPromptMillis);
        final daysSinceLastPrompt = DateTime.now().difference(lastPromptDate).inDays;
        if (daysSinceLastPrompt < _minimumDaysBetweenPrompts) {
          debugPrint('[ReviewService] Throttled. Last prompt was $daysSinceLastPrompt days ago (min: $_minimumDaysBetweenPrompts days).');
          return false;
        }
      }

      // 3. Pastikan API In-App Review didukung di perangkat
      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) {
        debugPrint('[ReviewService] In-App Review API not available on this platform/environment.');
        return false;
      }

      // Catat waktu permintaan
      await prefs.setInt(_keyLastRequestTimestamp, DateTime.now().millisecondsSinceEpoch);

      debugPrint('[ReviewService] Requesting Google Play In-App Review (trigger: $trigger)...');
      await _inAppReview.requestReview();
      return true;
    } catch (e) {
      debugPrint('[ReviewService] requestReview error: $e');
      return false;
    }
  }
}
