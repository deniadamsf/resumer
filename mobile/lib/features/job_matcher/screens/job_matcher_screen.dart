import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/frosted_app_bar.dart';
import '../../cv_editor/models/cv_model.dart';
import '../../cv_editor/services/cv_profile_manager.dart';
import '../../cv_editor/widgets/profile_switcher_bar.dart';
import '../models/job_match_model.dart';
import '../widgets/job_image_input_section.dart';
import '../widgets/job_input_toggle_card.dart';
import '../widgets/job_keywords_section.dart';
import '../widgets/job_match_score_gauge.dart';
import '../widgets/job_tailoring_section.dart';
import '../widgets/job_text_input_section.dart';

/// Clean Orchestrator Screen for AI Job Matcher
/// Follows 100% UI UX Pro Max & Quiet Luxury standards
class JobMatcherScreen extends StatefulWidget {
  final CvDocument? currentCv;
  final ValueChanged<CvDocument>? onCvUpdated;
  final bool? showBackButton;

  const JobMatcherScreen({
    super.key,
    this.currentCv,
    this.onCvUpdated,
    this.showBackButton,
  });

  @override
  State<JobMatcherScreen> createState() => _JobMatcherScreenState();
}

class _JobMatcherScreenState extends State<JobMatcherScreen> {
  final _profileMgr = CvProfileManager.instance;
  late CvDocument _cv;
  JobInputMode _mode = JobInputMode.text;
  final _textController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isTailoring = false;
  JobMatchResult? _result;

  @override
  void initState() {
    super.initState();
    _cv = (widget.currentCv ?? _profileMgr.currentCv).clone();
    _profileMgr.addListener(_onProfileUpdate);
    _textController.text =
        'Dibutuhkan Senior Data Specialist / BI Engineer dengan kualifikasi:\n'
        '• Mahir dalam pemrograman Python & ekosistem Data Science\n'
        '• Pengalaman mendalam dengan SQL & Enterprise Data Pipelines\n'
        '• Memiliki pemahaman tentang CI/CD Pipelines, Docker, dan Automated Testing\n'
        '• Berpengalaman merancang Executive Dashboards';
  }

  @override
  void dispose() {
    _profileMgr.removeListener(_onProfileUpdate);
    _textController.dispose();
    super.dispose();
  }

  void _onProfileUpdate() {
    if (!mounted) return;
    setState(() {
      _cv = _profileMgr.currentCv.clone();
    });
  }

  Future<void> _handleStartMatch() async {
    final text = _textController.text.trim();
    if (_mode == JobInputMode.text && text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('job_match.no_input_error'.tr)),
      );
      return;
    }
    if (_mode == JobInputMode.image && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('job_match.no_input_error'.tr)),
      );
      return;
    }

    // Rewarded Ad 3: Quiet Luxury prompt before running AI match
    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_job_match'.tr,
      onRewarded: _executeJobMatch,
    );
  }

  Future<void> _executeJobMatch() async {
    setState(() => _isLoading = true);

    try {
      String? base64Image;
      if (_mode == JobInputMode.image && _selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final response = await ApiService.instance.matchJob(
        _cv.toPlainText(),
        jobText: _mode == JobInputMode.text ? _textController.text.trim() : null,
        jobImageBase64: base64Image,
      );

      if (response['success'] == true && mounted) {
        final rawResult = (response['match_result'] ?? response['ats_result'] ?? {}) as Map<String, dynamic>;
        setState(() {
          _result = JobMatchResult.fromJson(rawResult);
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'common.error'.tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'common.error'.tr}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleTailorCv() async {
    if (_result == null) return;
    setState(() => _isTailoring = true);

    try {
      // Inject missing keywords into skills without duplicating
      final currentSkills = Set<String>.from(_cv.skills.map((s) => s.name.toLowerCase()));
      for (final kw in _result!.missingKeywords) {
        if (!currentSkills.contains(kw.toLowerCase())) {
          _cv.skills.add(SkillItem(name: kw));
          currentSkills.add(kw.toLowerCase());
        }
      }

      await CvProfileManager.instance.saveCurrentProfile(_cv);
      widget.onCvUpdated?.call(_cv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('job_match.tailor_success'.tr),
            backgroundColor: AppColors.forestPine,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'common.error'.tr}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTailoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oysterCanvas,
      appBar: FrostedAppBar(
        title: 'job_match.title'.tr,
        showBackButton: widget.showBackButton ?? (Navigator.canPop(context)),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSwitcherBar(
              currentIndex: _profileMgr.currentIndex,
              currentMeta: _profileMgr.currentMeta,
              isSyncing: _profileMgr.isSyncing,
              onProfileSelected: (index) async {
                await _profileMgr.switchProfile(index);
                setState(() {
                  _cv = _profileMgr.currentCv.clone();
                  _result = null;
                });
              },
              onRenameProfile: (newTitle, newTargetJob) {
                _profileMgr.updateProfileMeta(
                  _profileMgr.currentIndex,
                  title: newTitle.isNotEmpty ? newTitle : null,
                  targetJob: newTargetJob.isNotEmpty ? newTargetJob : null,
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'job_match.subtitle'.tr,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            // Tab Switcher Pill
            JobInputToggleCard(
              currentMode: _mode,
              onModeChanged: (mode) => setState(() => _mode = mode),
            ),
            const SizedBox(height: 14),

            // Active Input Section
            if (_mode == JobInputMode.text)
              JobTextInputSection(controller: _textController)
            else
              JobImageInputSection(
                selectedImage: _selectedImage,
                onImageSelected: (img) => setState(() => _selectedImage = img),
              ),
            const SizedBox(height: 16),

            // Primary Match CTA Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleStartMatch,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.compare_arrows_rounded, size: 20, color: Colors.white),
              label: Text(
                _isLoading ? 'common.loading'.tr : 'job_match.match_btn'.tr,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.midnightNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),

            // Results Section (Rendered smoothly when ready)
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Divider(height: 1, color: AppColors.borderHairline),
              const SizedBox(height: 20),
              JobMatchScoreGauge(
                score: _result!.matchScore,
                verdict: _result!.verdict,
              ),
              const SizedBox(height: 20),
              JobKeywordsSection(
                matchedKeywords: _result!.matchedKeywords,
                missingKeywords: _result!.missingKeywords,
              ),
              const SizedBox(height: 16),
              JobTailoringSection(
                suggestions: _result!.tailoringSuggestions,
                onTailorCv: _handleTailorCv,
                isTailoring: _isTailoring,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
