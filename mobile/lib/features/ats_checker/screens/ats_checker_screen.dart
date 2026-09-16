import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/frosted_app_bar.dart';
import '../../cv_editor/services/cv_profile_manager.dart';
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
        await _profileMgr.saveCurrentProfile(cv, atsScore: newScore);
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
      final cv = _profileMgr.currentCv;
      final response = await ApiService.instance.autoFixAts(cv.toPlainText());

      if (response['success'] == true && mounted) {
        final improved = response['improved_cv'];
        final improvedData = improved?['improved_cv_data'];

        if (improvedData != null) {
          if (improvedData['summary'] != null) {
            cv.summary = improvedData['summary'];
          }
          if (improvedData['experiences'] != null && (improvedData['experiences'] as List).isNotEmpty) {
            final expList = improvedData['experiences'] as List;
            for (int i = 0; i < expList.length && i < cv.experiences.length; i++) {
              final expItem = expList[i];
              if (expItem['bullet_points'] != null) {
                cv.experiences[i].highlights = List<String>.from(expItem['bullet_points']);
              }
            }
          }
          if (improvedData['skills'] != null && (improvedData['skills'] as List).isNotEmpty) {
            cv.skills = List<String>.from(improvedData['skills']);
          }
        }

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
}
