import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/signature_service.dart';
import '../../../core/widgets/frosted_app_bar.dart';
import '../../auth/screens/login_screen.dart';
import '../../cover_letter/widgets/signature_pad_modal.dart';
import '../../cv_editor/services/cv_profile_manager.dart';

/// Screen for Tab 5: Profile, Language Switching & Multi-Profile CV Management
/// Adheres strictly to UI UX Pro Max & Bespoke Executive Standards
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileMgr = CvProfileManager.instance;
  final _sigService = SignatureService.instance;
  final _apiService = ApiService.instance;

  @override
  void initState() {
    super.initState();
    _profileMgr.addListener(_onStateChanged);
    _sigService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _sigService.removeListener(_onStateChanged);
    _profileMgr.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'AW';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return AppColors.forestPine;
    if (score >= 60) return AppColors.antiqueBronze;
    return AppColors.crimsonBordeaux;
  }

  Future<void> _handleLanguageChange(String newLocale) async {
    HapticFeedback.mediumImpact();
    await AppLocalizations.instance.setLocale(newLocale);
    if (!mounted) return;
    final langName = newLocale == 'id_ID' ? 'Bahasa Indonesia' : 'English (US)';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('profile.lang_changed'.trArgs([langName])),
        backgroundColor: AppColors.midnightNavy,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSwitchProfile(int index) async {
    HapticFeedback.lightImpact();
    await _profileMgr.switchProfile(index);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('profile.switched'.trArgs([index.toString()])),
        backgroundColor: AppColors.forestPine,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleRenameProfile(int index) async {
    final meta = _profileMgr.getMeta(index);
    final titleController = TextEditingController(text: meta.title);
    final roleController = TextEditingController(text: meta.targetJob);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderHairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'profile.rename_title'.tr,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.midnightNavy,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Nama Profil',
                hintText: 'profile.rename_hint'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleController,
              decoration: InputDecoration(
                labelText: 'Posisi Target',
                hintText: 'profile.target_role_hint'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.midnightNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    _profileMgr.updateProfileMeta(
                      index,
                      title: titleController.text.trim(),
                      targetJob: roleController.text.trim(),
                    );
                  }
                  Navigator.pop(ctx);
                },
                child: Text(
                  'common.save'.tr,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'profile.sign_out'.tr,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'profile.sign_out_confirm'.tr,
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.crimsonBordeaux,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'profile.sign_out'.tr,
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _apiService.clearAuth();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = AppLocalizations.instance.currentLocale;
    final activeCv = _profileMgr.currentCv;
    final fullName = activeCv.personalInfo.fullName.isNotEmpty
        ? activeCv.personalInfo.fullName
        : 'Alexander Wright';
    final email = activeCv.personalInfo.email.isNotEmpty
        ? activeCv.personalInfo.email
        : 'alexander.wright@executive.io';
    final initials = _getInitials(fullName);

    return Scaffold(
      backgroundColor: AppColors.oysterCanvas,
      appBar: FrostedAppBar(
        title: 'tabs.profile'.tr,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        // 120px bottom padding to prevent bottom tab bar overlap per UI UX Pro Max
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Executive Account Card
            _buildAccountCard(fullName, email, initials),
            const SizedBox(height: 18),

            // 2. Language Selector Card (Indonesian / English)
            _buildLanguageSelectorCard(currentLocale),
            const SizedBox(height: 18),

            // 3. AI Quota Status Card
            _buildQuotaCard(),
            const SizedBox(height: 18),

            // 4. Multi-Profile CV Variations (1, 2, 3)
            _buildProfileVariationsSection(),
            const SizedBox(height: 18),

            // 5. Digital Signature Card
            _buildSignatureCard(),
            const SizedBox(height: 18),

            // 6. Data Privacy & Architecture Card
            _buildPrivacyCard(),
            const SizedBox(height: 24),

            // 7. Sign Out Button
            _buildSignOutButton(),
            const SizedBox(height: 12),

            // App Version Info
            Center(
              child: Text(
                'Resumer v1.0.0 • AI ATS Engine 2026',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(String name, String email, String initials) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.midnightNavy,
            child: Text(
              initials,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.forestPine.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 12, color: AppColors.forestPine),
                          const SizedBox(width: 4),
                          Text(
                            'Google OAuth',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forestPine,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.subtleSlateTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Device ID: ${_apiService.deviceUuid.length >= 8 ? _apiService.deviceUuid.substring(0, 8) : _apiService.deviceUuid}...',
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectorCard(String currentLocale) {
    final isIndo = currentLocale == 'id_ID';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.midnightNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  size: 18,
                  color: AppColors.midnightNavy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.language_title'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                    Text(
                      'profile.language_subtitle'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2 Language Buttons: ID vs EN
          Row(
            children: [
              Expanded(
                child: _buildLanguageOption(
                  label: 'profile.lang_indonesian'.tr,
                  flag: '🇮🇩',
                  subLabel: 'Bahasa Baku HRD',
                  isSelected: isIndo,
                  onTap: () => _handleLanguageChange('id_ID'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLanguageOption(
                  label: 'profile.lang_english'.tr,
                  flag: '🇺🇸',
                  subLabel: 'Executive English',
                  isSelected: !isIndo,
                  onTap: () => _handleLanguageChange('en_US'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String flag,
    required String subLabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.midnightNavy.withValues(alpha: 0.05)
                : AppColors.oysterCanvas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.midnightNavy : AppColors.borderHairline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 20)),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppColors.midnightNavy,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.midnightNavy : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subLabel,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.midnightNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.donut_large_rounded,
                  size: 18,
                  color: AppColors.midnightNavy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.quota_title'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                    Text(
                      'profile.quota_desc'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.forestPine.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '4 / 5',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestPine,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 4 / 5,
              backgroundColor: AppColors.borderHairline,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.midnightNavy),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'quota.resets_info'.tr,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileVariationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'profile.variations_title'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.midnightNavy,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_profileMgr.isSyncing) ...[
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.midnightNavy),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'profile.saving'.tr,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'profile.variations_subtitle'.tr,
          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        // List of 3 CV Variations
        for (int i = 1; i <= 3; i++) _buildCvProfileItem(i),
      ],
    );
  }

  Widget _buildCvProfileItem(int index) {
    final meta = _profileMgr.getMeta(index);
    final isActive = _profileMgr.currentIndex == index;
    final score = meta.atsScore;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.midnightNavy : AppColors.borderHairline,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSwitchProfile(index),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Radio / Active Indicator
                Icon(
                  isActive ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isActive ? AppColors.midnightNavy : AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 22,
                ),
                const SizedBox(width: 12),

                // Title & Target Job
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              meta.title,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.midnightNavy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'profile.active_badge'.tr,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.midnightNavy,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta.targetJob.isNotEmpty ? meta.targetJob : 'Belum ditentukan posisi target',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ATS Score Badge (if exists)
                if (score != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(score).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$score ATS',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _getScoreColor(score),
                      ),
                    ),
                  ),
                ],

                // Action Menu (Rename / Manage)
                IconButton(
                  onPressed: () => _handleRenameProfile(index),
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'profile.rename_title'.tr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureCard() {
    final hasSig = _sigService.hasSignature;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.midnightNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.gesture_rounded,
                  size: 18,
                  color: AppColors.midnightNavy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.digital_signature'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                    Text(
                      hasSig ? 'profile.signature_active'.tr : 'profile.signature_empty'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: hasSig ? AppColors.forestPine : AppColors.textSecondary,
                        fontWeight: hasSig ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderHairline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                await SignaturePadModal.show(context);
                setState(() {});
              },
              icon: Icon(
                hasSig ? Icons.edit_rounded : Icons.draw_rounded,
                size: 16,
                color: AppColors.midnightNavy,
              ),
              label: Text(
                hasSig ? 'cover_letter.change_signature'.tr : 'cover_letter.add_signature'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.midnightNavy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderHairline, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 20,
            color: AppColors.mutedSteelSlate,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile.privacy_title'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'profile.privacy_desc'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.crimsonBordeaux, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _handleSignOut,
        icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.crimsonBordeaux),
        label: Text(
          'profile.sign_out'.tr,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.crimsonBordeaux,
          ),
        ),
      ),
    );
  }
}
