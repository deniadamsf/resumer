import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Daily Quota Banner with Quiet Luxury styling and live bypass state
class DailyQuotaBanner extends StatelessWidget {
  final int remainingQuota;
  final String? customTitle;
  final String? customSubtitle;
  final bool showBypassBadge;

  const DailyQuotaBanner({
    super.key,
    required this.remainingQuota,
    this.customTitle,
    this.customSubtitle,
    this.showBypassBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final isExhausted = remainingQuota <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isExhausted ? const Color(0xFFFFFDF5) : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExhausted ? const Color(0xFFFDE68A) : AppColors.borderHairline,
          width: isExhausted ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isExhausted
                ? const Color(0xFFD97706).withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
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
              color: isExhausted
                  ? const Color(0xFFFEF3C7)
                  : AppColors.subtleSlateTint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isExhausted ? const Color(0xFFF59E0B) : AppColors.borderHairline,
              ),
            ),
            child: Icon(
              isExhausted ? Icons.toll_rounded : Icons.auto_awesome_rounded,
              color: isExhausted ? const Color(0xFFD97706) : AppColors.midnightNavy,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customTitle ??
                            (isExhausted
                                ? 'Jatah AI Habis (0/5 Hari Ini)'
                                : 'quota.remaining_count'.trArgs(['$remainingQuota'])),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isExhausted ? const Color(0xFF92400E) : AppColors.midnightNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showBypassBadge) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isExhausted ? const Color(0xFFD97706) : AppColors.subtleSlateTint,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isExhausted ? const Color(0xFFD97706) : AppColors.borderHairline,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.toll_rounded,
                              size: 11,
                              color: isExhausted ? Colors.white : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isExhausted ? 'Bypass 1 Koin' : 'Bisa Koin',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isExhausted ? Colors.white : AppColors.midnightNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  customSubtitle ??
                      (isExhausted
                          ? 'Bisa di-bypass dengan 1 koin untuk perbaikan CV AI.'
                          : 'Untuk perbaikan CV AI. Bisa di-bypass dengan koin jika habis.'),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isExhausted ? const Color(0xFFB45309) : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
