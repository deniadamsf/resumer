import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Daily Quota Banner with Quiet Luxury Antique Bronze accent
class DailyQuotaBanner extends StatelessWidget {
  final int remainingQuota;

  const DailyQuotaBanner({super.key, required this.remainingQuota});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.subtleSlateTint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: const Icon(Icons.data_usage_rounded, color: AppColors.midnightNavy, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'quota.remaining_count'.trArgs(['$remainingQuota']),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'quota.resets_info'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
