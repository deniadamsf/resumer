import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Modular ATS Feedback Section for concrete HR recommendations
class AtsFeedbackSection extends StatelessWidget {
  final List<dynamic> feedbackList;
  final bool isAnalyzed;

  const AtsFeedbackSection({
    super.key,
    required this.feedbackList,
    this.isAnalyzed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 18, color: AppColors.midnightNavy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ats.feedback_title'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!isAnalyzed)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.subtleSlateTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.analytics_outlined,
                      size: 20,
                      color: AppColors.mutedSteelSlate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ats.feedback_empty_title'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.midnightNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ats.feedback_empty_desc'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else if (feedbackList.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.forestPine.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.forestPine.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 18, color: AppColors.forestPine),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ats.feedback_perfect_title'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.forestPine,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...feedbackList.map((item) {
              final section = item['section']?.toString() ?? 'ats.feedback_default_section'.tr;
              final priority = item['priority']?.toString();
              final issue = item['issue']?.toString() ?? '';
              final suggestion = item['suggestion']?.toString() ?? '';
              final example = item['example']?.toString();

              final isHighPriority = priority != null &&
                  (priority.toLowerCase().contains('tinggi') || priority.toLowerCase().contains('high'));
              final isMediumPriority = priority != null &&
                  (priority.toLowerCase().contains('sedang') || priority.toLowerCase().contains('medium'));

              final priorityColor = isHighPriority
                  ? AppColors.crimsonBordeaux
                  : (isMediumPriority ? AppColors.antiqueBronze : AppColors.mutedSteelSlate);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.subtleSlateTint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.midnightNavy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            section,
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (priority != null && priority.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              priority,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: priorityColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      issue,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.crimsonBordeaux,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 15,
                            color: AppColors.forestPine,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (example != null && example.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderHairline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.forestPine),
                                const SizedBox(width: 6),
                                Text(
                                  'ats.feedback_example_label'.tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestPine,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              example.trim(),
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
