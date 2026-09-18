import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Clean Executive Quick Action Bar for CV Editor
/// Adheres 100% to UI UX Pro Max standards — generous touch targets, no text clipping
class EditorBottomBar extends StatelessWidget {
  final bool isLoading;
  final bool isEligibleForAi;
  final VoidCallback onAiPolish;
  final VoidCallback onExportPdf;

  const EditorBottomBar({
    super.key,
    required this.isLoading,
    required this.isEligibleForAi,
    required this.onAiPolish,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: const Border(top: BorderSide(color: AppColors.borderHairline)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // AI Polish CTA
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (isLoading || !isEligibleForAi) ? null : onAiPolish,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
                label: Text(
                  isLoading ? 'common.loading'.tr : 'common.polish_ai'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEligibleForAi ? AppColors.midnightNavy : AppColors.mutedSteelSlate,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Export PDF CTA
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onExportPdf,
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.white),
                label: Text(
                  'common.export_pdf_btn'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mutedSteelSlate,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
