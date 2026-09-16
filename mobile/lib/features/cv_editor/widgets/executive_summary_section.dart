import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Executive Summary section with dynamic toggle ON/OFF
class ExecutiveSummarySection extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const ExecutiveSummarySection({
    super.key,
    required this.controller,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'form.summary'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                activeTrackColor: AppColors.midnightNavy,
                onChanged: onToggle,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 4,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
              decoration: InputDecoration(
                hintText: 'form.summary_hint'.tr,
                hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: AppColors.subtleSlateTint.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderHairline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderHairline),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '3-4 kalimat padat yang memuat nilai jual utama, keahlian, dan metrik dampak.',
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
