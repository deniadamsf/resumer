import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

enum JobInputMode { text, image }

/// Segmented Switcher Pill for Job Matcher (Teks vs Screenshot)
/// Adheres strictly to UI UX Pro Max & Quiet Luxury geometry
class JobInputToggleCard extends StatelessWidget {
  final JobInputMode currentMode;
  final ValueChanged<JobInputMode> onModeChanged;

  const JobInputToggleCard({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPill(
              mode: JobInputMode.text,
              label: 'job_match.tab_text'.tr,
              icon: Icons.text_snippet_outlined,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildPill(
              mode: JobInputMode.image,
              label: 'job_match.tab_image'.tr,
              icon: Icons.image_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required JobInputMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.midnightNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.midnightNavy.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
