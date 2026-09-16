import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Keywords Breakdown Section for Job Matcher
/// Strictly adheres to UI UX Pro Max rule: WRAP is mandatory for chips (never Row)
class JobKeywordsSection extends StatelessWidget {
  final List<String> matchedKeywords;
  final List<String> missingKeywords;

  const JobKeywordsSection({
    super.key,
    required this.matchedKeywords,
    required this.missingKeywords,
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
          // Matched Keywords Header & Wrap Chips
          _buildCategoryHeader(
            title: 'job_match.matched_keywords'.tr,
            count: matchedKeywords.length,
            color: AppColors.forestPine,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 10),
          if (matchedKeywords.isEmpty)
            Text(
              'Belum ada kata kunci yang cocok ditemukan.',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matchedKeywords
                  .map(
                    (kw) => _buildChip(
                      label: kw,
                      bgColor: const Color(0xFFECFDF5),
                      borderColor: const Color(0xFFA7F3D0),
                      textColor: AppColors.forestPine,
                      icon: Icons.check_rounded,
                    ),
                  )
                  .toList(),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.borderHairline),
          ),

          // Missing Keywords Header & Wrap Chips
          _buildCategoryHeader(
            title: 'job_match.missing_keywords'.tr,
            count: missingKeywords.length,
            color: AppColors.antiqueBronze,
            icon: Icons.add_circle_outline_rounded,
          ),
          const SizedBox(height: 10),
          if (missingKeywords.isEmpty)
            Text(
              'Luar biasa! Semua kata kunci penting ada di CV Anda.',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.forestPine),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: missingKeywords
                  .map(
                    (kw) => _buildChip(
                      label: kw,
                      bgColor: const Color(0xFFFFFBEB),
                      borderColor: const Color(0xFFFDE68A),
                      textColor: AppColors.antiqueBronze,
                      icon: Icons.add_rounded,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.midnightNavy,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count kata kunci',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
