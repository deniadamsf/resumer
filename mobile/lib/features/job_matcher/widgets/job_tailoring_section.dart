import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Tailoring Recommendations & 1-Click Tailor CV CTA Button
/// Translates AI suggestions into direct resume action
class JobTailoringSection extends StatelessWidget {
  final List<String> suggestions;
  final VoidCallback onTailorCv;
  final bool isTailoring;

  const JobTailoringSection({
    super.key,
    required this.suggestions,
    required this.onTailorCv,
    this.isTailoring = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 18, color: AppColors.midnightNavy),
              const SizedBox(width: 8),
              Text(
                'job_match.tailoring_title'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.midnightNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Suggestions list
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mutedSteelSlate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s,
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
              )),

          const SizedBox(height: 12),

          // 1-Click Tailor CV CTA Button
          ElevatedButton.icon(
            onPressed: isTailoring ? null : onTailorCv,
            icon: isTailoring
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_outlined, size: 18, color: Colors.white),
            label: Text(
              'job_match.tailor_cv_btn'.tr,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.midnightNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'job_match.tailor_cv_desc'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
