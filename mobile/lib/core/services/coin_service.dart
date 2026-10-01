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

  static const String _prefCoinsKey = 'resumer_cached_coins';
  static const String _prefClaimedKey = 'resumer_claimed_welcome_bonus';
  static const String devEmail = 'denif9734@gmail.com';
  static const String _prefDevGrantKey = 'resumer_dev_grant_1000_denif_done';

  /// Memeriksa dan memberikan 1000 koin khusus akun pengembang denif9734@gmail.com
  Future<void> checkDeveloperGrant({String? explicitEmail}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetEmail = (explicitEmail ?? prefs.getString('user_email') ?? ApiService.instance.userEmail).toLowerCase().trim();
      final alreadyGranted = prefs.getBool(_prefDevGrantKey) ?? false;

      if (targetEmail == devEmail) {
        if (!alreadyGranted || currentCoins < 1000) {
          final newBalance = currentCoins < 1000 ? 1000 : currentCoins;
          await _saveCoins(newBalance);
          await prefs.setBool(_prefDevGrantKey, true);
          debugPrint('[CoinService] Developer 1000 coins granted to $devEmail. Current balance: $newBalance');
        }
      }
    } catch (e) {
      debugPrint('[CoinService] Error in checkDeveloperGrant: $e');
    }
  }

  /// Inisialisasi saldo dari cache lokal & sinkronisasi dengan backend
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCoins = prefs.getInt(_prefCoinsKey) ?? 0;
    coinsNotifier.value = cachedCoins;

    await checkDeveloperGrant();

    // Sinkronisasi live dari backend
    await refreshBalance();
  }

  /// Sinkronisasi saldo koin dari backend
  Future<void> refreshBalance() async {
    await checkDeveloperGrant();
    try {
      final res = await ApiService.instance.getCoinsBalance();
      if (res['success'] == true) {
        final serverCoins = (res['coins'] as num?)?.toInt() ?? 0;
        final hasClaimed = res['has_claimed_welcome_bonus'] == true;

        await _saveCoins(serverCoins);

        // Jika belum pernah klaim bonus selamat datang, klaim 5 koin gratis
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

  /// Klaim 5 koin gratis untuk pengguna baru
  Future<bool> claimInitialBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyClaimed = prefs.getBool(_prefClaimedKey) ?? false;
    if (alreadyClaimed) return false;

    try {
      final res = await ApiService.instance.claimWelcomeBonus();
      if (res['success'] == true) {
        final newBalance = (res['coins'] as num?)?.toInt() ?? (currentCoins + 5);
        await prefs.setBool(_prefClaimedKey, true);
        await _saveCoins(newBalance);
        debugPrint('[CoinService] Successfully claimed 5 welcome coins! Balance: $newBalance');
        return true;
      }
    } catch (_) {}

    // Fallback lokal jika backend offline
    await prefs.setBool(_prefClaimedKey, true);
    await _saveCoins(currentCoins + 5);
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

  /// Reset saldo koin saat pengguna sign-out
  Future<void> reset() async {
    coinsNotifier.value = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCoinsKey);
    await prefs.remove(_prefClaimedKey);
  }

  Future<void> _saveCoins(int coins) async {
    coinsNotifier.value = coins;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefCoinsKey, coins);
  }
}
