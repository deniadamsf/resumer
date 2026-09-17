import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Modular ATS Breakdown Section displaying the 4 core ATS criteria
class AtsBreakdownSection extends StatelessWidget {
  final Map<String, dynamic>? breakdown;

  const AtsBreakdownSection({super.key, this.breakdown});

  @override
  Widget build(BuildContext context) {
    final isAnalyzed = breakdown != null && breakdown!.isNotEmpty;

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
          Text(
            'ats.breakdown_title'.tr,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildMetricBar(
            'ats.keyword_match'.tr,
            isAnalyzed ? (breakdown!['keyword_match'] as num?)?.toInt() : null,
            25,
          ),
          _buildMetricBar(
            'ats.impact_verbs'.tr,
            isAnalyzed ? (breakdown!['impact_verbs'] as num?)?.toInt() : null,
            25,
          ),
          _buildMetricBar(
            'ats.readability'.tr,
            isAnalyzed ? (breakdown!['readability'] as num?)?.toInt() : null,
            25,
          ),
          _buildMetricBar(
            'ats.completeness'.tr,
            isAnalyzed ? (breakdown!['completeness'] as num?)?.toInt() : null,
            25,
            isLast: true,
          ),
          if (!isAnalyzed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.subtleSlateTint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ats.breakdown_empty_hint'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.35,
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

  Widget _buildMetricBar(String label, int? value, int maxVal, {bool isLast = false}) {
    final hasValue = value != null;
    final percentage = hasValue ? (value / maxVal).clamp(0.0, 1.0) : 0.0;
    final color = !hasValue
        ? AppColors.subtleSlateTint
        : (percentage >= 0.85
            ? AppColors.forestPine
            : (percentage >= 0.60 ? AppColors.antiqueBronze : AppColors.crimsonBordeaux));

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hasValue ? '$value / $maxVal' : '— / $maxVal',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: hasValue ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppColors.subtleSlateTint,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
