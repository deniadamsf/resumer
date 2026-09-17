import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/colors.dart';
import '../localization/app_localizations.dart';

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

  /// Displays the Quiet Luxury Rewarded Ad dialog and invokes [onRewarded] upon completion.
  /// If the ad is not yet ready, displays an elegant waiting indicator and waits up to 5 seconds.
  Future<void> showRewardedAd({
    required BuildContext context,
    required String prompt,
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
  }) async {
    // 1. Opt-in confirmation dialog per Google AdMob policy & Quiet Luxury UI
    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RewardedAdPromptDialog(prompt: prompt),
    );

    if (shouldProceed != true || !context.mounted) return;

    // 2. Check if ad is already loaded and ready
    if (_rewardedAd != null) {
      _showLoadedRewardedAd(
        context: context,
        onRewarded: onRewarded,
        onDismissed: onDismissed,
      );
      return;
    }

    // 3. Ad is not ready yet: Display Waiting Dialog and wait up to 5 seconds
    debugPrint('[AdService] RewardedAd not ready yet. Displaying waiting dialog...');
    _pendingAdCompleter = Completer<RewardedAd?>();

    // Trigger preload if not already active
    preloadRewardedAd();

    // Show waiting dialog without blocking navigation logic
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _AdLoadingWaitDialog(),
    );

    // Await either ad ready or 5-second timeout
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

    // Dismiss waiting dialog safely
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Short breather for clean UI transition
    await Future.delayed(const Duration(milliseconds: 120));

    if (loadedAd != null && context.mounted) {
      _showLoadedRewardedAd(
        context: context,
        onRewarded: onRewarded,
        onDismissed: onDismissed,
      );
    } else if (context.mounted) {
      // Graceful fallback: Inform user without deducting AI quota
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Iklan belum siap atau koneksi internet tidak stabil. Silakan coba sesaat lagi.',
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

/// Quiet Luxury Confirmation Dialog for Rewarded Video Ad
class _RewardedAdPromptDialog extends StatelessWidget {
  final String prompt;

  const _RewardedAdPromptDialog({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.cardSurface,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.subtleSlateTint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: const Icon(
                Icons.smart_display_rounded,
                color: AppColors.midnightNavy,
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Sponsor Video Singkat',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              prompt,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderHairline),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'common.cancel'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.midnightNavy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Tonton Video',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

