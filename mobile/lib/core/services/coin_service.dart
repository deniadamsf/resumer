import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Service: CoinService
/// Mengelola saldo koin pengguna secara reaktif dan persisten.
/// Terhubung dengan Google Play IAP dan backend Laravel Resumer.
class CoinService {
  static final CoinService instance = CoinService._internal();
  CoinService._internal();

  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  int get currentCoins => coinsNotifier.value;
  bool hasEnoughCoins(int required) => coinsNotifier.value >= required;

  static const int maxDailyAdCoins = 3;
  static const String _prefCoinsKey = 'resumer_cached_coins';
  static const String _prefAdRewardDateKey = 'resumer_ad_reward_date';
  static const String _prefAdRewardCountKey = 'resumer_ad_reward_count';

  /// Flag level-perangkat: bonus 2 koin sudah pernah diklaim di device ini.
  /// TIDAK dihapus saat logout agar relogin / ganti akun tidak mereset bonus.
  static const String _prefClaimedKey = 'resumer_claimed_welcome_bonus';

  final ValueNotifier<int> adCoinsClaimedTodayNotifier = ValueNotifier<int>(0);

  int get adCoinsClaimedToday => adCoinsClaimedTodayNotifier.value;
  int get remainingAdCoinsToday => (maxDailyAdCoins - adCoinsClaimedTodayNotifier.value).clamp(0, maxDailyAdCoins);
  bool get canClaimAdCoin => remainingAdCoinsToday > 0;

  /// Inisialisasi saldo dari cache lokal & sinkronisasi dengan backend
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCoins = prefs.getInt(_prefCoinsKey) ?? 0;
    coinsNotifier.value = cachedCoins;

    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_prefAdRewardDateKey);
    if (savedDate == todayKey) {
      adCoinsClaimedTodayNotifier.value = prefs.getInt(_prefAdRewardCountKey) ?? 0;
    } else {
      adCoinsClaimedTodayNotifier.value = 0;
      await prefs.setString(_prefAdRewardDateKey, todayKey);
      await prefs.setInt(_prefAdRewardCountKey, 0);
    }

    // Sinkronisasi live dari backend
    await refreshBalance();
  }

  /// Sinkronisasi saldo koin dari backend
  Future<void> refreshBalance() async {
    try {
      final res = await ApiService.instance.getCoinsBalance();
      if (res['success'] == true) {
        final serverCoins = (res['coins'] as num?)?.toInt() ?? 0;
        final hasClaimed = res['has_claimed_welcome_bonus'] == true;

        await _saveCoins(serverCoins);

        if (res['ad_rewards_today'] != null) {
          final serverAdRewards = (res['ad_rewards_today'] as num).toInt();
          final todayKey = DateTime.now().toIso8601String().substring(0, 10);
          final prefs = await SharedPreferences.getInstance();
          adCoinsClaimedTodayNotifier.value = serverAdRewards;
          await prefs.setString(_prefAdRewardDateKey, todayKey);
          await prefs.setInt(_prefAdRewardCountKey, serverAdRewards);
        }

        // Jika belum pernah klaim bonus selamat datang, klaim 2 koin gratis
        if (!hasClaimed) {
          await claimInitialBonus();
        }
      } else {
        // Fallback untuk mode guest baru
        final prefs = await SharedPreferences.getInstance();
        final localClaimed = prefs.getBool(_prefClaimedKey) ?? false;
        if (!localClaimed) {
          await claimInitialBonus();
        }
      }
    } catch (e) {
      debugPrint('[CoinService] Error refreshing coin balance: $e');
    }
  }

  /// Klaim 2 koin gratis untuk pengguna baru (sekali per Device ID).
  Future<bool> claimInitialBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyClaimed = prefs.getBool(_prefClaimedKey) ?? false;
    if (alreadyClaimed) return false;

    if (ApiService.instance.isAuthenticated && !ApiService.instance.isGuestMode) {
      // Server adalah sumber kebenaran (dikunci per device_uuid & user_id).
      final res = await ApiService.instance.claimWelcomeBonus();
      final serverCoins = (res['coins'] as num?)?.toInt();
      if (res['success'] == true) {
        await prefs.setBool(_prefClaimedKey, true);
        await _saveCoins(serverCoins ?? currentCoins + 2);
        debugPrint('[CoinService] Successfully claimed 2 welcome coins! Balance: $currentCoins');
        return true;
      }
      if (serverCoins != null) {
        // Server menolak: bonus sudah pernah diklaim di perangkat/akun ini.
        await prefs.setBool(_prefClaimedKey, true);
        await _saveCoins(serverCoins);
      }
      // Offline / error jaringan: jangan tambah koin lokal, coba lagi di sinkronisasi berikutnya.
      return false;
    }

    // Mode guest: bonus lokal sekali per perangkat.
    await prefs.setBool(_prefClaimedKey, true);
    await _saveCoins(currentCoins + 2);
    return true;
  }

  /// Tambahkan 1 koin dari menonton iklan video (Maksimal 3 koin per hari)
  Future<bool> awardAdCoinReward() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_prefAdRewardDateKey);

    int countToday = adCoinsClaimedToday;
    if (savedDate != todayKey) {
      countToday = 0;
      adCoinsClaimedTodayNotifier.value = 0;
      await prefs.setString(_prefAdRewardDateKey, todayKey);
      await prefs.setInt(_prefAdRewardCountKey, 0);
    }

    if (countToday >= maxDailyAdCoins) {
      debugPrint('[CoinService] Daily limit of 3 ad coins reached.');
      return false;
    }

    if (ApiService.instance.isAuthenticated && !ApiService.instance.isGuestMode) {
      try {
        final res = await ApiService.instance.claimAdReward();
        if (res['success'] == true) {
          final serverCoins = (res['coins'] as num?)?.toInt();
          final claimedToday = (res['claimed_today'] as num?)?.toInt() ?? (countToday + 1);

          adCoinsClaimedTodayNotifier.value = claimedToday;
          await prefs.setString(_prefAdRewardDateKey, todayKey);
          await prefs.setInt(_prefAdRewardCountKey, claimedToday);
          await _saveCoins(serverCoins ?? currentCoins + 1);
          debugPrint('[CoinService] Successfully claimed +1 ad coin! Balance: $currentCoins, claimedToday: $claimedToday');
          return true;
        } else if (res['statusCode'] == 429) {
          adCoinsClaimedTodayNotifier.value = maxDailyAdCoins;
          await prefs.setString(_prefAdRewardDateKey, todayKey);
          await prefs.setInt(_prefAdRewardCountKey, maxDailyAdCoins);
          return false;
        }
      } catch (e) {
        debugPrint('[CoinService] Error claiming ad reward online: $e');
      }
    }

    // Mode guest / offline fallback
    final nextCount = countToday + 1;
    adCoinsClaimedTodayNotifier.value = nextCount;
    await prefs.setString(_prefAdRewardDateKey, todayKey);
    await prefs.setInt(_prefAdRewardCountKey, nextCount);
    await _saveCoins(currentCoins + 1);
    debugPrint('[CoinService] Successfully awarded +1 ad coin locally! Balance: $currentCoins');
    return true;
  }

  /// Gunakan koin untuk aksi tertentu (Job Matcher, Ekspor PDF, dsb.)
  Future<bool> spend(
    int amount,
    String actionType, {
    String? description,
  }) async {
    if (!hasEnoughCoins(amount)) {
      debugPrint('[CoinService] Insufficient coins: need $amount, have $currentCoins');
      return false;
    }

    // Pengurangan optimistik secara lokal
    final previousBalance = currentCoins;
    final newBalance = previousBalance - amount;
    await _saveCoins(newBalance);

    // Jika pengguna login, sinkronisasikan ke backend
    if (ApiService.instance.isAuthenticated) {
      try {
        final res = await ApiService.instance.spendCoins(
          amount: amount,
          actionType: actionType,
          description: description,
        );

        if (res['success'] == true) {
          final verifiedBalance = (res['coins'] as num?)?.toInt();
          if (verifiedBalance != null) {
            await _saveCoins(verifiedBalance);
          }
          return true;
        } else if (res['statusCode'] == 402) {
          // Hanya rollback jika server dengan tegas menolak karena saldo di server tidak cukup (HTTP 402)
          await _saveCoins(previousBalance);
          return false;
        }
        // Respon selain 402 (misal 404 endpoint belum dideploy, 500, atau respon non-sukses)
        // tetap diizinkan dengan pengurangan lokal agar pengalaman pengguna mulus & tidak terblokir
        return true;
      } catch (e) {
        // Offline / network fallback: tetap sukses dengan saldo lokal
        debugPrint('[CoinService] Spend request exception (using local deduction): $e');
        return true;
      }
    }

    // Mode guest / belum login: langsung berhasil dengan pengurangan lokal
    return true;
  }

  /// Kembalikan koin jika request AI gagal
  Future<void> refund(
    int amount,
    String reason,
    String originalAction,
  ) async {
    final newBalance = currentCoins + amount;
    await _saveCoins(newBalance);

    try {
      await ApiService.instance.refundCoins(
        amount: amount,
        reason: reason,
        originalAction: originalAction,
      );
    } catch (_) {}
  }

  /// Tangani verifikasi pembelian dari In-App Purchase Google Play
  Future<bool> onPurchaseVerified(PurchaseDetails purchase) async {
    isLoadingNotifier.value = true;
    try {
      final orderId = purchase.purchaseID ?? 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      final productId = purchase.productID;
      final token = purchase.verificationData.serverVerificationData;

      final res = await ApiService.instance.verifyIapPurchase(
        orderId: orderId,
        productId: productId,
        purchaseToken: token,
      );

      if (res['success'] == true) {
        final serverCoins = (res['coins'] as num?)?.toInt();
        if (serverCoins != null) {
          await _saveCoins(serverCoins);
        }
        isLoadingNotifier.value = false;
        return true;
      } else {
        // Fallback jika verifikasi server timeout tapi Google Play sukses
        int granted = 0;
        if (productId == 'resumer_coins_30') granted = 30;
        if (productId == 'resumer_coins_70') granted = 70;
        if (productId == 'resumer_coins_200') granted = 200;

        if (granted > 0) {
          await _saveCoins(currentCoins + granted);
        }
        isLoadingNotifier.value = false;
        return true;
      }
    } catch (e) {
      debugPrint('[CoinService] Error verifying purchase: $e');
      isLoadingNotifier.value = false;
      return false;
    }
  }

  /// Sinkronisasi saldo koin dari response server
  Future<void> updateBalance(int coins) async {
    await _saveCoins(coins);
  }

  /// Kurangi saldo koin secara lokal jika operasi offline
  Future<void> deductLocally(int amount) async {
    final newBalance = (currentCoins - amount).clamp(0, 999999999);
    await _saveCoins(newBalance);
  }

  /// Reset saldo koin saat pengguna sign-out.
  /// Flag bonus selamat datang (level perangkat) sengaja TIDAK dihapus.
  Future<void> reset() async {
    coinsNotifier.value = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCoinsKey);
  }

  Future<void> _saveCoins(int coins) async {
    coinsNotifier.value = coins;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefCoinsKey, coins);
  }
}
