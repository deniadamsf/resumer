import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/cv_model.dart';

/// Education Section with dynamic list of degrees and schools
class EducationSection extends StatelessWidget {
  final List<Education> educations;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<Education> onAddEducation;
  final ValueChanged<int> onRemoveEducation;

  const EducationSection({
    super.key,
    required this.educations,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddEducation,
    required this.onRemoveEducation,
  });

  void _showAddEducationDialog(BuildContext context) {
    final schoolController = TextEditingController();
    final degreeController = TextEditingController();
    final fieldController = TextEditingController();
    final yearController = TextEditingController();
    final gpaController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'form.add_education'.tr,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: schoolController,
              style: GoogleFonts.outfit(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'form.institution'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: degreeController,
              style: GoogleFonts.outfit(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Jenjang (cth: S1 / Bachelor)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fieldController,
              style: GoogleFonts.outfit(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Jurusan / Bidang Studi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: yearController,
                    style: GoogleFonts.outfit(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Tahun Lulus',
                      hintText: '2023',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: gpaController,
                    style: GoogleFonts.outfit(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'IPK / GPA',
                      hintText: '3.80',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr, style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (schoolController.text.trim().isNotEmpty && degreeController.text.trim().isNotEmpty) {
                onAddEducation(
                  Education(
                    institution: schoolController.text.trim(),
                    degree: degreeController.text.trim(),
                    fieldOfStudy: fieldController.text.trim(),
                    graduationYear: yearController.text.trim().isNotEmpty ? yearController.text.trim() : '2022',
                    gpa: gpaController.text.trim(),
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.midnightNavy, foregroundColor: Colors.white),
            child: Text('Tambah', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

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
                  'form.education'.tr,
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
            const SizedBox(height: 12),
            for (int i = 0; i < educations.length; i++) ...[
              _buildEducationCard(context, i, educations[i]),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: () => _showAddEducationDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'form.add_education'.tr,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.midnightNavy,
                side: const BorderSide(color: AppColors.borderHairline),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationCard(BuildContext context, int index, Education edu) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${edu.degree} in ${edu.fieldOfStudy}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${edu.institution} (${edu.graduationYear})',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (edu.gpa.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'IPK / GPA: ${edu.gpa}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestPine,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onRemoveEducation(index),
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.crimsonBordeaux),
            visualDensity: VisualDensity.compact,
            tooltip: 'common.delete'.tr,
          ),
        ],
      ),
    );
  }
}
