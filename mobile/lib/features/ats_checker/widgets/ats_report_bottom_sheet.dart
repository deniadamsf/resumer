import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import 'ats_score_gauge.dart';
import 'ats_breakdown_section.dart';
import 'ats_feedback_section.dart';
import 'ats_share_card.dart';

/// Modal Bottom Sheet orchestrator for complete ATS Score Report
class AtsReportBottomSheet extends StatelessWidget {
  final int score;
  final String? verdict;
  final Map<String, dynamic>? breakdown;
  final List<dynamic>? feedback;
  final String candidateName;
  final String targetRole;
  final VoidCallback onAutoFixTap;

  const AtsReportBottomSheet({
    super.key,
    required this.score,
    this.verdict,
    this.breakdown,
    this.feedback,
    required this.candidateName,
    required this.targetRole,
    required this.onAutoFixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.oysterCanvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar & Drag Handle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderHairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ats.checker_title'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                    IconButton(
                      tooltip: 'ats.share_tooltip'.tr,
                      onPressed: () {
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (ctx) => AtsShareCard(
                            candidateName: candidateName,
                            targetRole: targetRole,
                            score: score,
                            verdict: verdict ?? (score >= 85 ? 'ats.verdict_top_tier'.tr : (score >= 60 ? 'ats.verdict_mid_tier'.tr : 'ats.verdict_needs_opt'.tr)),
                            breakdown: breakdown,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 20, color: AppColors.midnightNavy),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.cardSurface,
                        side: const BorderSide(color: AppColors.borderHairline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderHairline),

          // Scrollable Report Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  AtsScoreGauge(score: score, verdict: verdict),
                  const SizedBox(height: 20),

                  // 1-Click ATS Auto-Fix CTA Button
                  if (score < 98) ...[
                    ElevatedButton.icon(
                      onPressed: onAutoFixTap,
                      icon: const Icon(Icons.auto_awesome_outlined, size: 20, color: Colors.white),
                      label: Text(
                        'ats.auto_fix_btn'.tr,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.midnightNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ats.auto_fix_desc'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 4 Core Criteria Breakdown
                  if (breakdown != null) ...[
                    AtsBreakdownSection(breakdown: breakdown!),
                    const SizedBox(height: 16),
                  ],

                  // Actionable HR Recruiter Feedback
                  if (feedback != null) ...[
                    AtsFeedbackSection(feedbackList: feedback!),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
