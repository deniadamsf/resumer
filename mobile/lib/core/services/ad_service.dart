import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../localization/app_localizations.dart';

/// Enterprise AdService for Rewarded Video Ads & AdMob Remote Config
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  String rewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';
  String bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  String interstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';

  void updateAdUnits({String? rewarded, String? banner, String? interstitial}) {
    if (rewarded != null) rewardedUnitId = rewarded;
    if (banner != null) bannerUnitId = banner;
    if (interstitial != null) interstitialUnitId = interstitial;
  }

  /// Displays the Quiet Luxury Rewarded Ad dialog and invokes [onRewarded] upon completion
  Future<void> showRewardedAd({
    required BuildContext context,
    required String prompt,
    required VoidCallback onRewarded,
  }) async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RewardedAdPromptDialog(prompt: prompt),
    );

    if (shouldProceed == true && context.mounted) {
      // Display simulated executive video ad overlay
      final completed = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        pageBuilder: (ctx, anim1, anim2) => const _AdPlaybackOverlay(),
      );

      if (completed == true) {
        onRewarded();
      }
    }
  }
}

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
                      'Tonton Iklan',
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

class _AdPlaybackOverlay extends StatefulWidget {
  const _AdPlaybackOverlay();

  @override
  State<_AdPlaybackOverlay> createState() => _AdPlaybackOverlayState();
}

class _AdPlaybackOverlayState extends State<_AdPlaybackOverlay> {
  int _secondsLeft = 2;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        _timer.cancel();
        if (mounted) Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderHairline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestPine),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sponsor Video AdMob',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hadiah terbuka dalam $_secondsLeft detik...',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
