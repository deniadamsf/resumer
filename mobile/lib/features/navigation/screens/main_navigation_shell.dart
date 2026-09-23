import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/admob_banner_widget.dart';
import '../../ats_checker/screens/ats_checker_screen.dart';
import '../../cover_letter/screens/cover_letter_screen.dart';
import '../../cv_editor/screens/cv_editor_screen.dart';
import '../../cv_editor/services/cv_profile_manager.dart';
import '../../job_matcher/screens/job_matcher_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// Modern Executive Navigation Shell with Frosted Bottom Tab Bar
/// Adheres 100% to UI UX Pro Max and Bespoke Executive Standards
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    CvEditorScreen(),
    AtsCheckerScreen(),
    JobMatcherScreen(showBackButton: false),
    CoverLetterScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    AppLocalizations.instance.localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    AppLocalizations.instance.localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    // Flush any pending editor drafts to local storage immediately
    CvProfileManager.instance.persistDraftLocally();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = AppLocalizations.instance.currentLocale;
    return Scaffold(
      extendBody: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.oysterCanvas,
      body: IndexedStack(
        key: ValueKey(currentLocale),
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdMobBannerWidget(),
          _buildModernTabBar(),
        ],
      ),
    );
  }

  Widget _buildModernTabBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            border: const Border(
              top: BorderSide(color: AppColors.borderHairline, width: 1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 8,
            bottom: bottomPadding > 0 ? bottomPadding : 10,
            left: 4,
            right: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                index: 0,
                label: 'tabs.editor'.tr,
                activeIcon: Icons.description_rounded,
                inactiveIcon: Icons.description_outlined,
              ),
              _buildTabItem(
                index: 1,
                label: 'tabs.ats_score'.tr,
                activeIcon: Icons.speed_rounded,
                inactiveIcon: Icons.speed_outlined,
              ),
              _buildTabItem(
                index: 2,
                label: 'tabs.job_match'.tr,
                activeIcon: Icons.work_rounded,
                inactiveIcon: Icons.work_outline_rounded,
              ),
              _buildTabItem(
                index: 3,
                label: 'tabs.cover_letter'.tr,
                activeIcon: Icons.mail_rounded,
                inactiveIcon: Icons.mail_outline_rounded,
              ),
              _buildTabItem(
                index: 4,
                label: 'tabs.profile'.tr,
                activeIcon: Icons.person_rounded,
                inactiveIcon: Icons.person_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabSelected(index),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.midnightNavy.withValues(alpha: 0.05),
          highlightColor: AppColors.midnightNavy.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.midnightNavy.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    size: 22,
                    color: isSelected
                        ? AppColors.midnightNavy
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.midnightNavy
                        : AppColors.textSecondary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
