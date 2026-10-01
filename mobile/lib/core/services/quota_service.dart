import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Service: QuotaService
/// Mengelola jatah harian fitur AI (5x per hari) secara reaktif di seluruh tab aplikasi.
class QuotaService {
  static final QuotaService instance = QuotaService._internal();
  QuotaService._internal();

  static const int maxDailyLimit = 5;

  final ValueNotifier<int> remainingQuotaNotifier = ValueNotifier<int>(maxDailyLimit);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  int get remainingQuota => remainingQuotaNotifier.value;
  bool get hasRemainingQuota => remainingQuotaNotifier.value > 0;

  /// Inisialisasi dan ambil jatah harian dari backend
  Future<void> fetchQuota() async {
    try {
      isLoadingNotifier.value = true;
      final res = await ApiService.instance.getQuota();
      if (res['success'] == true && res['quota'] != null) {
        final remaining = (res['quota']['remaining'] as num?)?.toInt() ?? maxDailyLimit;
        remainingQuotaNotifier.value = remaining.clamp(0, maxDailyLimit);
      }
    } catch (e) {
      debugPrint('[QuotaService] Error fetching quota: $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  /// Update jatah kuota dari response endpoint AI
  void updateQuota(int remaining) {
    remainingQuotaNotifier.value = remaining.clamp(0, maxDailyLimit);
  }

  /// Konsumsi 1 kuota lokal
  void consumeLocally() {
    if (remainingQuotaNotifier.value > 0) {
      remainingQuotaNotifier.value = remainingQuotaNotifier.value - 1;
    }
  }
}
