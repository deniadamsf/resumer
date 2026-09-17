import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/colors.dart';
import '../services/ad_service.dart';

/// Reusable Anchored Adaptive Banner Ad Widget
/// Automatically adapts to device screen width and provides Quiet Luxury visual container
class AdMobBannerWidget extends StatefulWidget {
  final bool showTopBorder;

  const AdMobBannerWidget({
    super.key,
    this.showTopBorder = true,
  });

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Orientation? _currentOrientation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.orientationOf(context);
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (_currentOrientation != orientation) {
      _currentOrientation = orientation;
      _loadAdaptiveBanner(width);
    }
  }

  Future<void> _loadAdaptiveBanner(int width) async {
    await _bannerAd?.dispose();
    if (!mounted) return;
    setState(() {
      _bannerAd = null;
      _isLoaded = false;
    });

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (size == null) {
      debugPrint('[AdMobBanner] Unable to determine adaptive banner size.');
      return;
    }

    final banner = BannerAd(
      adUnitId: AdService.instance.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('[AdMobBanner] Banner successfully loaded ($size).');
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdMobBanner] Banner failed to load: ${error.message} (code: ${error.code})');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    );

    await banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      // Gracefully collapse when ad is loading or unavailable
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: widget.showTopBorder
            ? const Border(
                top: BorderSide(
                  color: AppColors.borderHairline,
                  width: 0.8,
                ),
              )
            : null,
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
