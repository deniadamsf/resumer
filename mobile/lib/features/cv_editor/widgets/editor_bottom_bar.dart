import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';

/// Floating Bottom Action Bar with Quiet Luxury buttons & UI UX Pro Max ergonomics
class EditorBottomBar extends StatelessWidget {
  final bool isLoading;
  final bool isEligibleForAi;
  final VoidCallback onAtsCheck;
  final VoidCallback onAiPolish;
  final VoidCallback onCoverLetter;
  final VoidCallback onPlainTextSimulation;
  final VoidCallback onExportPdf;

  const EditorBottomBar({
    super.key,
    required this.isLoading,
    required this.isEligibleForAi,
    required this.onAtsCheck,
    required this.onAiPolish,
    required this.onCoverLetter,
    required this.onPlainTextSimulation,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
            // ATS Score Check CTA
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onAtsCheck,
                icon: const Icon(Icons.speed_rounded, size: 18),
                label: Text(
                  'Uji Skor',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestPine,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // AI Polish CTA (Validates core fields)
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: (isLoading || !isEligibleForAi) ? null : onAiPolish,
                icon: const Icon(Icons.auto_awesome_outlined, size: 18, color: Colors.white),
                label: Text(
                  'Poles AI',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEligibleForAi ? AppColors.midnightNavy : AppColors.mutedSteelSlate,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 6),

            // AI Cover Letter CTA
            IconButton(
              onPressed: isLoading ? null : onCoverLetter,
              tooltip: 'Surat Lamaran AI',
              icon: const Icon(Icons.mail_outline_rounded, color: AppColors.midnightNavy, size: 19),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.subtleSlateTint,
                minimumSize: const Size(42, 50),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderHairline),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // ATS Plain Text Robot View CTA
            IconButton(
              onPressed: isLoading ? null : onPlainTextSimulation,
              tooltip: 'Mode Robot ATS',
              icon: const Icon(Icons.terminal_rounded, color: AppColors.midnightNavy, size: 19),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.subtleSlateTint,
                minimumSize: const Size(42, 50),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderHairline),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Export PDF CTA
            IconButton(
              onPressed: isLoading ? null : onExportPdf,
              tooltip: 'Ekspor PDF',
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.midnightNavy, size: 19),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.subtleSlateTint,
                minimumSize: const Size(42, 50),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderHairline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
