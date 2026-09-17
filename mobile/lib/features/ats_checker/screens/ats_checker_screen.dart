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
import '../../pdf_engine/templates/template_registry.dart';
import '../widgets/ats_breakdown_section.dart';
import '../widgets/ats_feedback_section.dart';
import '../widgets/ats_score_gauge.dart';
import '../widgets/ats_share_card.dart';

/// Full-screen ATS Quality Score Checker Tab
/// Adheres 100% to UI UX Pro Max and Bespoke Executive Standards
class AtsCheckerScreen extends StatefulWidget {
  const AtsCheckerScreen({super.key});

  @override
  State<AtsCheckerScreen> createState() => _AtsCheckerScreenState();
}

class _AtsCheckerScreenState extends State<AtsCheckerScreen> {
  final _profileMgr = CvProfileManager.instance;
  bool _isLoading = false;
  int _score = 92;
  String _verdict = 'Top 5% ATS Ready';
  Map<String, dynamic> _breakdown = {
    'keyword_match': 24,
    'impact_verbs': 25,
    'readability': 23,
    'completeness': 20,
  };
  List<dynamic> _feedback = [
    {
      'section': 'Summary',
      'issue': 'Tingkatkan penonjolan kata kunci industri',
      'suggestion': 'Gunakan kata kerja aksi terukur dan formula Google XYZ.',
    },
    {
      'section': 'Experience',
      'issue': 'Sertakan metrik kuantitatif terukur',
      'suggestion': 'Tambahkan persentase efisiensi, volume data, atau penghematan biaya.',
    }
  ];

  @override
  void initState() {
    super.initState();
    _score = _profileMgr.currentMeta.atsScore ?? 92;
    _profileMgr.addListener(_onProfileUpdate);
  }

  @override
  void dispose() {
    _profileMgr.removeListener(_onProfileUpdate);
    super.dispose();
  }

  void _onProfileUpdate() {
    if (mounted) {
      setState(() {
        _score = _profileMgr.currentMeta.atsScore ?? _score;
      });
    }
  }

  Future<void> _handleRunCheck() async {
    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_check'.tr,
      onRewarded: _executeCheck,
    );
  }

  Future<void> _executeCheck() async {
    setState(() => _isLoading = true);
    try {
      final cv = _profileMgr.currentCv;
      final response = await ApiService.instance.checkAtsScore(
        cv.toPlainText(),
        targetRole: cv.personalInfo.professionalTitle,
      );

      if (response['success'] == true && mounted) {
        final result = response['ats_result'];
        final newScore = (result['total_score'] as num?)?.toInt() ?? 92;
        setState(() {
          _score = newScore;
          _verdict = result['verdict'] ?? 'Top 5% ATS Ready';
          if (result['breakdown'] != null) {
            _breakdown = Map<String, dynamic>.from(result['breakdown']);
          }
          if (result['actionable_feedback'] != null) {
            _feedback = List<dynamic>.from(result['actionable_feedback']);
          }
        });
        await _profileMgr.updateProfileMeta(_profileMgr.currentIndex, atsScore: newScore);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Skor ATS berhasil dianalisis: $_score/100'),
              backgroundColor: AppColors.forestPine,
            ),
          );
        }
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

  Future<void> _handleAutoFix() async {
    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_autofix'.tr,
      onRewarded: _executeAutoFix,
    );
  }

  Future<void> _executeAutoFix() async {
    setState(() => _isLoading = true);
    try {
      final cv = _profileMgr.currentCv.clone();
      
      // Preserve all user sections that AI Auto-Fix does not optimize
      final preservedLanguages = List<LanguageItem>.from(cv.languages);
      final preservedHobbies = List<String>.from(cv.hobbies);
      final preservedCertifications = List<CertificationItem>.from(cv.certifications);
      final preservedEducations = List<Education>.from(cv.educations);
      final preservedPersonalInfo = cv.personalInfo;
      final preservedShowLanguages = cv.showLanguages;
      final preservedShowHobbies = cv.showHobbies;
      final preservedShowCertifications = cv.showCertifications;

      final response = await ApiService.instance.autoFixAts(cv.toPlainText());

      if (response['success'] == true && mounted) {
        final improved = response['improved_cv'];
        final improvedData = improved?['improved_cv_data'];

        if (improvedData != null) {
          // 1. Optimize summary
          if (improvedData['summary'] != null && (improvedData['summary'] as String).isNotEmpty) {
            cv.summary = improvedData['summary'];
          }

          // 2. Optimize work experience bullet points
          if (improvedData['experiences'] != null && (improvedData['experiences'] as List).isNotEmpty) {
            final expList = improvedData['experiences'] as List;
            for (int i = 0; i < expList.length && i < cv.experiences.length; i++) {
              final expItem = expList[i];
              if (expItem is Map && expItem['bullet_points'] != null && expItem['bullet_points'] is List) {
                cv.experiences[i].highlights = List<String>.from(expItem['bullet_points']);
              }
            }
          }

          // 3. Optimize skills with industry keywords
          if (improvedData['skills'] != null && (improvedData['skills'] as List).isNotEmpty) {
            final rawSkills = improvedData['skills'] as List;
            final List<SkillItem> parsedSkills = [];
            for (final s in rawSkills) {
              if (s != null) {
                parsedSkills.add(SkillItem.fromJson(s));
              }
            }
            if (parsedSkills.isNotEmpty) {
              cv.skills = parsedSkills;
            }
          }
        }

        // Restore and guarantee that core user sections are 100% intact
        cv.languages = preservedLanguages;
        cv.hobbies = preservedHobbies;
        cv.certifications = preservedCertifications;
        cv.educations = preservedEducations;
        cv.personalInfo = preservedPersonalInfo;
        cv.showLanguages = preservedShowLanguages;
        cv.showHobbies = preservedShowHobbies;
        cv.showCertifications = preservedShowCertifications;

        final newScore = (improved?['estimated_new_score'] as num?)?.toInt() ?? 96;
        setState(() => _score = newScore);
        await _profileMgr.saveCurrentProfile(cv, atsScore: newScore);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CV berhasil dioptimalkan! Skor ATS melonjak ke $newScore+'),
              backgroundColor: AppColors.forestPine,
            ),
          );
        }
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

  void _handleShareScore() {
    final cv = _profileMgr.currentCv;
    showDialog(
      context: context,
      builder: (_) => AtsShareCard(
        score: _score,
        verdict: _verdict,
        candidateName: cv.personalInfo.fullName.isNotEmpty ? cv.personalInfo.fullName : 'Alexander Wright',
        targetRole: cv.personalInfo.professionalTitle.isNotEmpty ? cv.personalInfo.professionalTitle : 'Professional',
        breakdown: _breakdown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oysterCanvas,
      appBar: FrostedAppBar(
        title: 'ats.checker_title'.tr,
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: _handleShareScore,
            icon: const Icon(Icons.share_rounded, color: AppColors.midnightNavy, size: 20),
            tooltip: 'Bagikan Kartu Skor',
          ),
        ],
      ),
      body: SingleChildScrollView(
        // UI UX Pro Max: bottom padding 120px to prevent being obscured by bottom navigation bar
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
                  _score = _profileMgr.currentMeta.atsScore ?? 90;
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

            // Active Template Context Info Card
            _buildActiveTemplateCard(_profileMgr.currentCv),
            const SizedBox(height: 14),

            // Hero Score Gauge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderHairline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AtsScoreGauge(score: _score, verdict: _verdict),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Re-check button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleRunCheck,
                          icon: _isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.midnightNavy))
                              : const Icon(Icons.refresh_rounded, size: 18, color: AppColors.midnightNavy),
                          label: Text(
                            'ats.run_check'.tr,
                            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            side: const BorderSide(color: AppColors.borderHairline),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 1-Click Auto-Fix button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleAutoFix,
                          icon: const Icon(Icons.auto_fix_high_rounded, size: 18, color: Colors.white),
                          label: Text(
                            'ats.auto_fix_btn'.tr,
                            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forestPine,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Breakdown Section
            AtsBreakdownSection(breakdown: _breakdown),
            const SizedBox(height: 16),

            // Recommendations / Actionable Feedback Section
            AtsFeedbackSection(feedbackList: _feedback),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTemplateCard(CvDocument cv) {
    final template = TemplateRegistry.getTemplate(cv.templateId);
    final isAts = template.isAtsFriendly;
    final badgeColor = isAts ? AppColors.forestPine : AppColors.antiqueBronze;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAts ? Icons.verified_rounded : Icons.palette_outlined,
                size: 18,
                color: badgeColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Template: ${template.nameKey.tr}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAts ? 'ATS Ready (1-Kolom)' : 'Kreatif (Non-ATS)',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          if (!isAts) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.antiqueBronze.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Analisis skor di atas menguji kekuatan isi teks Anda. Format Kreatif 2-kolom sangat memikat untuk HRD manusia (email langsung/portofolio), namun jika melamar ke portal ATS otomatis, disarankan beralih ke template ATS 1-kolom.',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        cv.templateId = 'asian_ats';
                        await _profileMgr.saveCurrentProfile(cv);
                        setState(() {});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Beralih ke template Asian ATS Classic'),
                              duration: Duration(seconds: 2),
                              backgroundColor: AppColors.forestPine,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.midnightNavy),
                      label: Text(
                        'Beralih ke Template Asian ATS',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.midnightNavy, width: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
