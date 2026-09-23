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
  final _scrollController = ScrollController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isTailoring = false;
  JobMatchResult? _result;

  @override
  void initState() {
    super.initState();
    _cv = (widget.currentCv ?? _profileMgr.currentCv).clone();
    _profileMgr.addListener(_onProfileUpdate);
    _textController.text = 'job_match.sample_job_text'.tr;
  }

  @override
  void dispose() {
    _profileMgr.removeListener(_onProfileUpdate);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onProfileUpdate() {
    if (!mounted) return;
    setState(() {
      _cv = _profileMgr.currentCv.clone();
    });
  }

  Future<void> _handleStartMatch() async {
    if (!_cv.isEligibleForAi) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ats.incomplete_profile_desc'.tr),
          backgroundColor: AppColors.antiqueBronze,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              300.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            );
          }
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
      // 1. Inject missing keywords and enrich skill descriptions
      final currentSkillsMap = <String, SkillItem>{};
      for (final s in _cv.skills) {
        currentSkillsMap[s.name.trim().toLowerCase()] = s;
      }

      // Add missing keywords as skills with industry-standard descriptions
      for (final kw in _result!.missingKeywords) {
        final cleanKw = kw.trim();
        if (cleanKw.isNotEmpty && !currentSkillsMap.containsKey(cleanKw.toLowerCase())) {
          final newSkill = SkillItem(
            name: cleanKw,
            description: 'job_match.tailor_skill_desc'.tr,
          );
          _cv.skills.add(newSkill);
          currentSkillsMap[cleanKw.toLowerCase()] = newSkill;
        }
      }

      // Enrich existing skills descriptions if empty
      for (final skill in _cv.skills) {
        if (skill.description.trim().isEmpty) {
          skill.description = 'job_match.tailor_existing_skill_desc'.tr;
        }
      }

      // 2. Optimize Certifications & Licenses (ONLY if user already has certifications)
      // ATURAN MUTLAK USER: "tapi kalo kosong ya jangan diisi"
      if (_cv.certifications.isNotEmpty) {
        for (final cert in _cv.certifications) {
          if (cert.description.trim().isEmpty) {
            cert.description = 'job_match.tailor_cert_desc'.tr;
          }
        }
      }

      // 3. Optimize Projects & Portfolio (ONLY if user already has projects)
      // ATURAN MUTLAK USER: "tapi kalo kosong ya jangan diisi"
      if (_cv.projects.isNotEmpty) {
        for (final proj in _cv.projects) {
          if (proj.description.trim().isEmpty) {
            proj.description = 'job_match.tailor_project_desc'.tr;
          }
        }
      }

      // 4. Align Professional Summary with target keywords if summary is active
      if (_cv.summary.trim().isNotEmpty && _result!.matchedKeywords.isNotEmpty) {
        final topKeywords = _result!.matchedKeywords.take(3).join(', ');
        final addition = 'job_match.tailor_summary_addition'.trArgs([topKeywords]);
        if (!_cv.summary.contains(topKeywords)) {
          _cv.summary = '${_cv.summary.trim()}$addition';
        }
      }

      await CvProfileManager.instance.saveCurrentProfile(_cv);
      widget.onCvUpdated?.call(_cv);

      if (mounted) {
        final additions = <String>[];
        if (_cv.certifications.isNotEmpty) additions.add('job_match.tailor_cert_mention'.tr);
        if (_cv.projects.isNotEmpty) additions.add('job_match.tailor_project_mention'.tr);
        final extraMention = additions.join('');
        final successMsg = 'job_match.tailor_success_detailed'.trArgs([extraMention]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: AppColors.forestPine,
            behavior: SnackBarBehavior.floating,
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
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
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
            const SizedBox(height: 12),
            Text(
              'job_match.subtitle'.tr,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),

            // Tab Switcher Pill
            JobInputToggleCard(
              currentMode: _mode,
              onModeChanged: (mode) => setState(() => _mode = mode),
            ),
            const SizedBox(height: 12),

            // Active Input Section
            if (_mode == JobInputMode.text)
              JobTextInputSection(controller: _textController)
            else
              JobImageInputSection(
                selectedImage: _selectedImage,
                onImageSelected: (img) => setState(() => _selectedImage = img),
              ),
            const SizedBox(height: 14),

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
              if (_result!.fitSummary != null && _result!.fitSummary!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildFitSummaryCard(
                  _result!.fitSummary!.trim(),
                  score: _result!.matchScore,
                ),
              ],
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

  Widget _buildFitSummaryCard(String summary, {required int score}) {
    final accentColor = score >= 80
        ? AppColors.forestPine
        : (score >= 60 ? AppColors.antiqueBronze : AppColors.crimsonBordeaux);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics_outlined, size: 16, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'job_match.fit_summary_title'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
