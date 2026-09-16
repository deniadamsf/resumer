import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Modular ATS Breakdown Section displaying the 4 core ATS criteria
class AtsBreakdownSection extends StatelessWidget {
  final Map<String, dynamic> breakdown;

  const AtsBreakdownSection({super.key, required this.breakdown});

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
          Text(
            'ats.breakdown_title'.tr,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildMetricBar('ats.keyword_match'.tr, (breakdown['keyword_match'] ?? 20) as int, 25),
          _buildMetricBar('ats.impact_verbs'.tr, (breakdown['impact_verbs'] ?? 20) as int, 25),
          _buildMetricBar('ats.readability'.tr, (breakdown['readability'] ?? 20) as int, 25),
          _buildMetricBar('ats.completeness'.tr, (breakdown['completeness'] ?? 20) as int, 25, isLast: true),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, int value, int maxVal, {bool isLast = false}) {
    final percentage = (value / maxVal).clamp(0.0, 1.0);
    final color = percentage >= 0.85
        ? AppColors.forestPine
        : (percentage >= 0.60 ? AppColors.antiqueBronze : AppColors.crimsonBordeaux);

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
                '$value / $maxVal',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
