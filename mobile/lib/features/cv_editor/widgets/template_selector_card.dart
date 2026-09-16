import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Card for choosing CV template (Asian ATS vs Western Strict) and standard ATS font
class TemplateSelectorCard extends StatelessWidget {
  final String selectedTemplateId;
  final String selectedFont;
  final ValueChanged<String> onTemplateChanged;
  final ValueChanged<String> onFontChanged;

  const TemplateSelectorCard({
    super.key,
    required this.selectedTemplateId,
    required this.selectedFont,
    required this.onTemplateChanged,
    required this.onFontChanged,
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
              Text(
                'form.template_selection'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.midnightNavy,
                ),
              ),
              // Font dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.subtleSlateTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFont,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 18),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.midnightNavy,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Outfit', child: Text('Font: Outfit')),
                      DropdownMenuItem(value: 'Arial', child: Text('Font: Arial')),
                      DropdownMenuItem(value: 'Calibri', child: Text('Font: Calibri')),
                      DropdownMenuItem(value: 'Garamond', child: Text('Font: Garamond')),
                    ],
                    onChanged: (val) {
                      if (val != null) onFontChanged(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTemplateOption(
                  title: 'Asian ATS',
                  subtitle: 'Dengan Pas Foto Formal',
                  atsRange: 'Skor: 85-95',
                  isSelected: selectedTemplateId == 'asian_ats',
                  onTap: () => onTemplateChanged('asian_ats'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTemplateOption(
                  title: 'Western Strict',
                  subtitle: '1 Kolom Teks Bersih',
                  atsRange: 'Skor: 95-100',
                  isSelected: selectedTemplateId == 'western_strict',
                  onTap: () => onTemplateChanged('western_strict'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateOption({
    required String title,
    required String subtitle,
    required String atsRange,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.subtleSlateTint : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.midnightNavy : AppColors.borderHairline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.midnightNavy : AppColors.textPrimary,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.forestPine),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cardSurface : AppColors.subtleSlateTint,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                atsRange,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.forestPine : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
