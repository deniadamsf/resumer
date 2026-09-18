import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/api_service.dart';
import '../../cv_editor/services/cv_profile_manager.dart';
import '../../navigation/screens/main_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '1047047792857-idood18l4f3m7lpr4klqedl0rid9dm6c.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> _handleDeveloperBypass() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.instance.saveToken('guest_mode_token');
      await ApiService.instance.saveUserData(
        name: 'auth.default_guest_name'.tr,
        email: 'guest@resumer.app',
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        // User cancelled account picker dialog — exit gracefully without error
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleAccount.authentication;
      final idToken = googleAuth.idToken ?? 'mock_token_${googleAccount.id}';

      final response = await ApiService.instance.googleLogin(idToken);

      if (response['success'] == true && mounted) {
        // Save user profile info
        final userObj = response['user'] as Map<String, dynamic>?;
        final candidateName = userObj?['name'] ?? googleAccount.displayName ?? 'auth.default_user_name'.tr;
        final candidateEmail = userObj?['email'] ?? googleAccount.email;
        final candidateAvatar = userObj?['avatar_url'] ?? googleAccount.photoUrl;

        await ApiService.instance.saveUserData(
          name: candidateName,
          email: candidateEmail,
          avatar: candidateAvatar,
        );

        // Sync to CV if active CV still uses empty name or legacy default name
        final cv = CvProfileManager.instance.currentCv;
        if (cv.personalInfo.fullName.isEmpty ||
            cv.personalInfo.fullName == 'Alexander Wright' ||
            cv.personalInfo.fullName == 'Tamu Resumer' ||
            cv.personalInfo.fullName == 'Resumer Guest' ||
            cv.personalInfo.fullName == 'auth.default_guest_name'.tr) {
          cv.personalInfo.fullName = candidateName;
          if (cv.personalInfo.email.isEmpty ||
              cv.personalInfo.email == 'alexander.wright@executive.io' ||
              cv.personalInfo.email.contains('@resumer.') ||
              cv.personalInfo.email == 'guest@resumer.app') {
            cv.personalInfo.email = candidateEmail;
          }
          CvProfileManager.instance.updateDraftSilently(cv);
          CvProfileManager.instance.persistDraftLocally();
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
        return;
      } else {
        throw Exception(response['message'] ?? 'auth.auth_failed'.tr);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'common.error'.tr}: $e'),
            backgroundColor: AppColors.crimsonBordeaux,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.oysterCanvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Quiet Luxury Emblem
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.midnightNavy,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x180B132B),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.description_rounded,
                      size: 40,
                      color: AppColors.subtleSlateTint,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Brand Title
                Text(
                  'common.app_name'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: AppColors.midnightNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'auth.login_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),

                // 1-Click Google OAuth Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderHairline, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A0F172A),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.midnightNavy,
                                ),
                              )
                            else ...[
                              // Google G Icon representation
                              const Icon(Icons.g_mobiledata_rounded,
                                  size: 32, color: AppColors.midnightNavy),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'auth.sign_in_google'.tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // No password notice
                Text(
                  'auth.oauth_notice'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isLoading ? null : _handleDeveloperBypass,
                  child: Text(
                    'auth.guest_login_btn'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedSteelSlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
