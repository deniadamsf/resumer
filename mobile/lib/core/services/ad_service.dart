import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/colors.dart';
import '../localization/app_localizations.dart';
import '../widgets/coin_dialogs.dart';
import '../widgets/coin_topup_sheet.dart';
import 'coin_service.dart';

/// Enterprise AdService for Rewarded Video Ads, Banner Ads & AdMob Remote Config
/// Complies 100% with Resumer Blueprint, Quiet Luxury standards & Google AdMob Policies.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // Official Test Ad Unit IDs (Google Sample IDs)
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';

  // Production Ad Unit IDs (Created in AdMob Console)
  static const String _prodRewardedId = 'ca-app-pub-4891614770967901/4067351402';
  static const String _prodBannerId = 'ca-app-pub-4891614770967901/6786593095';

  /// Enforce test ads in debug mode so developers' AdMob accounts are never penalized
  bool forceTestAds = kDebugMode;

  String get rewardedUnitId => forceTestAds ? _testRewardedId : _prodRewardedId;
  String get bannerUnitId => forceTestAds ? _testBannerId : _prodBannerId;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;
  int _retryAttempt = 0;
  Completer<RewardedAd?>? _pendingAdCompleter;

  /// Check whether rewarded ad is preloaded and ready in memory
  bool get isRewardedAdReady => _rewardedAd != null;

  /// Initializes AdMob SDK and starts silent background preloading
  Future<void> init() async {
    try {
      debugPrint('[AdService] Initializing Google Mobile Ads SDK...');
      await MobileAds.instance.initialize();
      debugPrint('[AdService] Mobile Ads initialized. Unit: $rewardedUnitId (forceTest: $forceTestAds)');
      preloadRewardedAd();
    } catch (e) {
      debugPrint('[AdService] MobileAds initialize error: $e');
    }
  }

  /// Preloads a Rewarded Ad in background so it is instantly ready when clicked.
  void preloadRewardedAd() {
    if (_rewardedAd != null || _isRewardedAdLoading) {
      debugPrint('[AdService] Rewarded ad already ready or loading.');
      return;
    }

    _isRewardedAdLoading = true;
    debugPrint('[AdService] Loading RewardedAd (Unit ID: $rewardedUnitId)...');

    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('[AdService] RewardedAd successfully preloaded & ready in memory.');
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          _retryAttempt = 0;

          // If a user clicked while loading, resolve their waiting dialog
          if (_pendingAdCompleter != null && !_pendingAdCompleter!.isCompleted) {
            _pendingAdCompleter!.complete(ad);
            _pendingAdCompleter = null;
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('[AdService] RewardedAd failed to load: ${error.message} (code: ${error.code})');
          _rewardedAd = null;
          _isRewardedAdLoading = false;

          if (_pendingAdCompleter != null && !_pendingAdCompleter!.isCompleted) {
            _pendingAdCompleter!.complete(null);
            _pendingAdCompleter = null;
          }

          // Exponential backoff retry (up to 30 seconds max delay)
          _retryAttempt++;
          final delaySeconds = math.min(30, math.pow(2, _retryAttempt).toInt());
          debugPrint('[AdService] Retrying RewardedAd load in $delaySeconds seconds...');
          Timer(Duration(seconds: delaySeconds), preloadRewardedAd);
        },
      ),
    );
  }

  /// Displays the Quiet Luxury Rewarded Ad dialog with option to skip with coins.
  /// If user chooses [coin], spends [coinCost] and immediately invokes [onRewarded].
  /// If user chooses [ad], displays rewarded video ad and invokes [onRewarded] upon completion.
  Future<void> showRewardedAd({
    required BuildContext context,
    required String prompt,
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    int coinCost = 1,
    String actionType = 'skip_ad',
    String? actionDescription,
    bool allowCoinSkip = true,
    bool allowWatchAd = true,
  }) async {
    // 1. Dual-choice modal (Skip with 1 Coin OR Watch Video Free)
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RewardedAdChoiceDialog(
        prompt: prompt,
        coinCost: coinCost,
        allowCoinSkip: allowCoinSkip,
        allowWatchAd: allowWatchAd,
      ),
    );

    if (!context.mounted) return;

    if (choice == 'cancel' || choice == null) {
      onDismissed?.call();
      return;
    }

    if (choice == 'topup') {
      onDismissed?.call();
      CoinTopupSheet.show(context);
      return;
    }

    // 2. User chose to skip ad with coin
    if (choice == 'coin') {
      if (!CoinService.instance.hasEnoughCoins(coinCost)) {
        CoinTopupSheet.show(context);
        onDismissed?.call();
        return;
      }

      final spent = await CoinService.instance.spend(
        coinCost,
        actionType,
        description: actionDescription ?? 'Lewati Iklan ($actionType)',
      );

      if (spent) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Berhasil menggunakan $coinCost koin. Iklan dilewati!',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.midnightNavy,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        onRewarded();
        return;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal memproses koin. Silakan coba tonton iklan atau periksa koneksi Anda.',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              backgroundColor: AppColors.crimsonBordeaux,
            ),
          );
        }
        onDismissed?.call();
        return;
      }
    }

    // 3. User chose to watch video ad
    if (choice == 'ad') {
      // If ad is ready in memory, show directly
      if (_rewardedAd != null) {
        _showLoadedRewardedAd(
          context: context,
          onRewarded: onRewarded,
          onDismissed: onDismissed,
        );
        return;
      }

      // Ad is not ready yet: Display Waiting Dialog and wait up to 5 seconds
      debugPrint('[AdService] RewardedAd not ready yet. Displaying waiting dialog...');
      _pendingAdCompleter = Completer<RewardedAd?>();

      preloadRewardedAd();

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const _AdLoadingWaitDialog(),
      );

      RewardedAd? loadedAd;
      try {
        loadedAd = await _pendingAdCompleter!.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('[AdService] Timeout waiting for RewardedAd.');
            return null;
          },
        );
      } catch (_) {
        loadedAd = null;
      } finally {
        _pendingAdCompleter = null;
      }

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await Future.delayed(const Duration(milliseconds: 120));

      if (loadedAd != null && context.mounted) {
        _showLoadedRewardedAd(
          context: context,
          onRewarded: onRewarded,
          onDismissed: onDismissed,
        );
      } else if (context.mounted) {
        // Fallback: Ad is still buffering, offer skip with coin if user has coin!
        if (CoinService.instance.hasEnoughCoins(coinCost)) {
          final fallbackChoice = await CoinDialogs.showAdBufferingFallback(
            context: context,
            coinCost: coinCost,
          );
          if (fallbackChoice == 'coin') {
            final spent = await CoinService.instance.spend(
              coinCost,
              actionType,
              description: actionDescription ?? 'Bypass Iklan Buffering ($actionType)',
            );
            if (spent) {
              onRewarded();
              return;
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ad.ad_not_ready'.tr,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AppColors.midnightNavy,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        onDismissed?.call();
      }
    }
  }

  void _showLoadedRewardedAd({
    required BuildContext context,
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
  }) {
    final ad = _rewardedAd;
    if (ad == null) return;

    bool userEarnedReward = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] RewardedAd displayed full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] RewardedAd dismissed. Auto-reloading next ad...');
        ad.dispose();
        _rewardedAd = null;
        // Auto-reload immediately in background for next action
        preloadRewardedAd();

        if (userEarnedReward) {
          onRewarded();
        }
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, AdError error) {
        debugPrint('[AdService] RewardedAd failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        // Auto-reload for recovery
        preloadRewardedAd();
        onDismissed?.call();
      },
    );

    ad.setImmersiveMode(true);
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('[AdService] User earned reward: ${reward.amount} ${reward.type}');
        userEarnedReward = true;
      },
    );
  }
}

/// Quiet Luxury Choice Dialog:
/// Allows users to choose between watching a free sponsored video ad OR skipping instantly with 1 coin.
class _RewardedAdChoiceDialog extends StatelessWidget {
  final String prompt;
  final int coinCost;
  final bool allowCoinSkip;
  final bool allowWatchAd;

  const _RewardedAdChoiceDialog({
    required this.prompt,
    this.coinCost = 1,
    this.allowCoinSkip = true,
    this.allowWatchAd = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardSurface,
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dual Aesthetic Emblem
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B132B).withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.smart_display_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD97706),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.toll_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                allowWatchAd ? 'ad.choose_access'.tr : 'ad.quota_exhausted_title'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.midnightNavy,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Prompt description
              Text(
                prompt,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // User's Live Coin Balance Pill
              ValueListenableBuilder<int>(
                valueListenable: CoinService.instance.coinsNotifier,
                builder: (context, coins, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.toll_rounded, color: Color(0xFFD97706), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${'ad.your_balance'.tr} ',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                        Text(
                          '$coins Koin',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Option 1: Lewati Iklan (Gunakan 1 Koin)
              if (allowCoinSkip) ...[
                ValueListenableBuilder<int>(
                  valueListenable: CoinService.instance.coinsNotifier,
                  builder: (context, coins, _) {
                    final hasEnough = coins >= coinCost;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (hasEnough) {
                            Navigator.of(context).pop('coin');
                          } else {
                            Navigator.of(context).pop('topup');
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: hasEnough ? const Color(0xFFF59E0B) : const Color(0xFFFDE68A),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD97706).withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF3C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.toll_rounded,
                                  color: Color(0xFFD97706),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          allowWatchAd ? 'ad.skip_with_coin'.tr : 'ad.bypass_with_coin'.tr,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF92400E),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD97706),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            allowWatchAd ? 'INSTAN' : 'BYPASS',
                                            style: GoogleFonts.outfit(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      hasEnough
                                          ? (allowWatchAd ? 'ad.skip_with_coin_desc'.tr : 'ad.bypass_with_coin_desc'.tr)
                                          : '${'ad.insufficient_coins'.tr} • ${'ad.tap_to_topup'.tr}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: hasEnough ? const Color(0xFFB45309) : AppColors.crimsonBordeaux,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                hasEnough ? Icons.arrow_forward_ios_rounded : Icons.add_circle_outline_rounded,
                                size: 15,
                                color: hasEnough ? const Color(0xFF92400E) : const Color(0xFFD97706),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],

              // Option 2: Tonton Video Iklan (Gratis) - Ditampilkan hanya jika allowWatchAd == true
              if (allowWatchAd) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop('ad'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.subtleSlateTint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderHairline, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_circle_outline_rounded,
                              color: AppColors.midnightNavy,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ad.watch_free_ad'.tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.midnightNavy,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'ad.watch_free_ad_desc'.tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.midnightNavy,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop('cancel'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'common.cancel'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quiet Luxury Waiting Dialog displayed when ad is still preparing
class _AdLoadingWaitDialog extends StatelessWidget {
  const _AdLoadingWaitDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.cardSurface,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.midnightNavy),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Menyiapkan Video...',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon tunggu sebentar, iklan sedang disiapkan.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

