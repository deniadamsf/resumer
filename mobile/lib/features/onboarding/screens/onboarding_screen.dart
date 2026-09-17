import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/api_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../navigation/screens/main_navigation_shell.dart';

/// Screen: OnboardingScreen
/// Pengenalan awal "Quiet Luxury & Bespoke Executive" yang menonjolkan
/// keunggulan powerful aplikasi Resumer (hanya tampil 1x pada instalasi pertama).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _totalSlides = 3;

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    final targetScreen = ApiService.instance.isAuthenticated
        ? const MainNavigationShell()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.15,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.oysterCanvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top Bar with Brand and Skip Button
              Padding(
                padding: EdgeInsets.only(
                  top: topPadding > 0 ? 4 : 12,
                  left: 20,
                  right: 20,
                  bottom: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.subtleSlateTint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderHairline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.forestPine,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'RESUMER AI',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.midnightNavy,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Skip Button
                    if (_currentPage < _totalSlides - 1)
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          foregroundColor: AppColors.textSecondary,
                        ),
                        child: Text(
                          'onboarding.skip'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48, height: 32),
                  ],
                ),
              ),

              // 2. Swipable Carousel
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildSlide(
                      badge: 'onboarding.badge_1'.tr,
                      title: 'onboarding.title_1'.tr,
                      desc: 'onboarding.desc_1'.tr,
                      visualWidget: const _InteractiveSlideOneVisual(),
                    ),
                    _buildSlide(
                      badge: 'onboarding.badge_2'.tr,
                      title: 'onboarding.title_2'.tr,
                      desc: 'onboarding.desc_2'.tr,
                      visualWidget: const _InteractiveSlideTwoVisual(),
                    ),
                    _buildSlide(
                      badge: 'onboarding.badge_3'.tr,
                      title: 'onboarding.title_3'.tr,
                      desc: 'onboarding.desc_3'.tr,
                      visualWidget: const _InteractiveSlideThreeVisual(),
                    ),
                  ],
                ),
              ),

              // 3. Bottom Controls (Indicators & CTA Button)
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 10,
                  bottom: bottomPadding > 0 ? bottomPadding + 14 : 26,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Page Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalSlides, (index) {
                        final isActive = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.midnightNavy
                                : AppColors.borderHairline,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),

                    // Primary CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.midnightNavy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _totalSlides - 1
                                  ? 'onboarding.get_started'.tr
                                  : 'onboarding.next'.tr,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _totalSlides - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.chevron_right_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String badge,
    required String title,
    required String desc,
    required Widget visualWidget,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 4),
                // Interactive visual card
                visualWidget,
                const SizedBox(height: 14),

                // Narrative Area
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.subtleSlateTint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderHairline),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentSteel,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// SLIDE 1: Interactive Before vs After Google XYZ Formula
// =============================================================================
class _InteractiveSlideOneVisual extends StatefulWidget {
  const _InteractiveSlideOneVisual();

  @override
  State<_InteractiveSlideOneVisual> createState() => _InteractiveSlideOneVisualState();
}

class _InteractiveSlideOneVisualState extends State<_InteractiveSlideOneVisual> {
  bool _isAfter = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderHairline, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Toggle Tabs
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.subtleSlateTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleTab(
                    label: 'onboarding.s1_tab_before'.tr,
                    isSelected: !_isAfter,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isAfter = false);
                    },
                  ),
                ),
                Expanded(
                  child: _buildToggleTab(
                    label: 'onboarding.s1_tab_after'.tr,
                    isSelected: _isAfter,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isAfter = true);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Animated Content Card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _isAfter ? _buildAfterContent() : _buildBeforeContent(),
          ),
          const SizedBox(height: 12),

          // Bottom Feature Pills
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildTag('onboarding.s1_tag_1'.tr),
              _buildTag('onboarding.s1_tag_2'.tr),
              _buildTag('onboarding.s1_tag_3'.tr),
            ],
          ),
          const SizedBox(height: 8),

          // Touch hint
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'onboarding.s1_hint'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.midnightNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeforeContent() {
    return Container(
      key: const ValueKey('before_content'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFB91C1C)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'onboarding.s1_score_before'.tr,
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB91C1C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Text(
                  'Format Pasif',
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'onboarding.s1_text_before'.tr,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAfterContent() {
    return Container(
      key: const ValueKey('after_content'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.forestPine),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'onboarding.s1_score_after'.tr,
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestPine,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Text(
                  'Google XYZ Formula',
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestPine,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'onboarding.s1_text_after'.tr,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.accentSteel,
        ),
      ),
    );
  }
}

// =============================================================================
// SLIDE 2: Interactive ATS Diagnostic Scanner & 1-Click Auto-Fix
// =============================================================================
class _InteractiveSlideTwoVisual extends StatefulWidget {
  const _InteractiveSlideTwoVisual();

  @override
  State<_InteractiveSlideTwoVisual> createState() => _InteractiveSlideTwoVisualState();
}

class _InteractiveSlideTwoVisualState extends State<_InteractiveSlideTwoVisual> {
  bool _isOptimized = false;

  @override
  Widget build(BuildContext context) {
    final targetScore = _isOptimized ? 96 : 62;
    final keywordRatio = _isOptimized ? 0.96 : 0.58;
    final robotRatio = _isOptimized ? 0.98 : 0.64;
    final formulaRatio = _isOptimized ? 0.92 : 0.50;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderHairline, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'onboarding.s2_score_label'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 62, end: targetScore.toDouble()),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, child) {
                      final scoreInt = val.round();
                      final isHigh = scoreInt >= 85;
                      final scoreColor = isHigh ? AppColors.forestPine : AppColors.antiqueBronze;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$scoreInt',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: scoreColor,
                            ),
                          ),
                          Text(
                            '/100',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isOptimized
                        ? AppColors.forestPine.withValues(alpha: 0.1)
                        : AppColors.antiqueBronze.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isOptimized
                          ? AppColors.forestPine.withValues(alpha: 0.3)
                          : AppColors.antiqueBronze.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOptimized ? Icons.verified_rounded : Icons.tune_rounded,
                        size: 13,
                        color: _isOptimized ? AppColors.forestPine : AppColors.antiqueBronze,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _isOptimized
                              ? 'onboarding.s2_verdict'.tr
                              : 'onboarding.s2_verdict_initial'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _isOptimized ? AppColors.forestPine : AppColors.antiqueBronze,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Diagnostic Metric Bars
          _buildScoreBar('onboarding.s2_metric_keywords'.tr, keywordRatio),
          const SizedBox(height: 6),
          _buildScoreBar('onboarding.s2_metric_robot'.tr, robotRatio),
          const SizedBox(height: 6),
          _buildScoreBar('onboarding.s2_metric_formula'.tr, formulaRatio),
          const SizedBox(height: 12),

          // Interactive Auto-Fix Action Button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _isOptimized = !_isOptimized);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
              decoration: BoxDecoration(
                color: _isOptimized ? const Color(0xFFF0FDF4) : AppColors.midnightNavy,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isOptimized ? const Color(0xFF86EFAC) : AppColors.midnightNavy,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isOptimized ? Icons.refresh_rounded : Icons.auto_fix_high_rounded,
                    size: 15,
                    color: _isOptimized ? AppColors.forestPine : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _isOptimized
                          ? 'onboarding.s2_btn_reset'.tr
                          : 'onboarding.s2_btn_autofix'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isOptimized ? AppColors.forestPine : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isOptimized) ...[
            const SizedBox(height: 5),
            Center(
              child: Text(
                'onboarding.s2_autofix_done'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forestPine,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double targetRatio) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: targetRatio),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final percent = (value * 100).toInt();
        final isHigh = percent >= 85;
        final barColor = isHigh ? AppColors.forestPine : AppColors.antiqueBronze;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$percent%',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: barColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: AppColors.subtleSlateTint,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// SLIDE 3: Interactive Multimodal Job Matcher & Smart Cover Letter
// =============================================================================
class _InteractiveSlideThreeVisual extends StatefulWidget {
  const _InteractiveSlideThreeVisual();

  @override
  State<_InteractiveSlideThreeVisual> createState() => _InteractiveSlideThreeVisualState();
}

class _InteractiveSlideThreeVisualState extends State<_InteractiveSlideThreeVisual>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Scan Loker, 1: Surat Lamaran
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderHairline, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Tabs (Scan Loker vs Surat Lamaran)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.subtleSlateTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSubTab(
                    label: 'onboarding.s3_tab_scan'.tr,
                    icon: Icons.document_scanner_outlined,
                    isSelected: _activeTab == 0,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _activeTab = 0);
                    },
                  ),
                ),
                Expanded(
                  child: _buildSubTab(
                    label: 'onboarding.s3_tab_letter'.tr,
                    icon: Icons.draw_outlined,
                    isSelected: _activeTab == 1,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _activeTab = 1);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _activeTab == 0 ? _buildScanContent() : _buildCoverLetterContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.midnightNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanContent() {
    return Column(
      key: const ValueKey('scan_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role & Score
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'onboarding.s3_target_role'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'onboarding.s3_ocr_label'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Text(
                'onboarding.s3_match_badge'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestPine,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Animated Scanner Viewport
        Container(
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderHairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Mock Vacancy Lines
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(height: 5, width: 170, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3))),
                    Container(height: 5, width: 210, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(3))),
                    Container(height: 5, width: 130, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3))),
                  ],
                ),
              ),
              // Animated Scanner Radar Beam
              AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(0, (_radarController.value * 2) - 1),
                    child: Container(
                      height: 2.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF38BDF8),
                            Color(0xFF34D399),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x8038BDF8),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Detected Keywords
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildDetectedChip('Clean Architecture'),
            _buildDetectedChip('Flutter/Dart'),
            _buildDetectedChip('CI/CD Pipeline'),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverLetterContent() {
    return Container(
      key: const ValueKey('letter_content'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 14, color: AppColors.midnightNavy),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Resumer AI Executive Letterhead',
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'onboarding.s3_cover_letter_preview'.tr,
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.draw_outlined, size: 13, color: AppColors.forestPine),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'onboarding.s3_signature_verified'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestPine,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 11, color: AppColors.forestPine),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
