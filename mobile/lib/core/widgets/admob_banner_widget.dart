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
  AdSize? _adSize;
  bool _isLoaded = false;
  Orientation? _currentOrientation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.orientationOf(context);
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (_currentOrientation != orientation && width > 0) {
      _currentOrientation = orientation;
      _loadAdaptiveBanner(width);
    }
  }

  Future<void> _loadAdaptiveBanner(int width) async {
    await _bannerAd?.dispose();
    if (!mounted) return;
    setState(() {
      _bannerAd = null;
      _adSize = null;
      _isLoaded = false;
    });

    // Request standard anchored adaptive banner to prevent oversized slots and blank whitespace
    // ignore: deprecated_member_use
    AdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    size ??= await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    size ??= AdSize.banner;

    final banner = BannerAd(
      adUnitId: AdService.instance.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          final bannerAd = ad as BannerAd;
          // Retrieve the exact pixel height and width from native platform
          // so the container hugs the ad creative perfectly with zero empty space.
          final platformSize = await bannerAd.getPlatformAdSize();
          debugPrint('[AdMobBanner] Banner successfully loaded. Requested: ${bannerAd.size}, Platform: $platformSize');
          if (mounted) {
            setState(() {
              _bannerAd = bannerAd;
              _adSize = platformSize ?? bannerAd.size;
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
              _adSize = null;
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
    if (!_isLoaded || _bannerAd == null || _adSize == null) {
      // Gracefully collapse when ad is loading or unavailable
      return const SizedBox.shrink();
    }

    final adHeight = _adSize!.height.toDouble();
    final adWidth = _adSize!.width.toDouble();

    if (adHeight <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: adHeight,
      alignment: Alignment.center,
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
      child: SizedBox(
        width: adWidth > 0 ? adWidth : double.infinity,
        height: adHeight,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
