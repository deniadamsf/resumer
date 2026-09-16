import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/cv_model.dart';

/// Work Experience Section with dynamic items & Google XYZ bullet highlights
class WorkExperienceSection extends StatelessWidget {
  final List<WorkExperience> experiences;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<WorkExperience> onAddExperience;
  final ValueChanged<int> onRemoveExperience;
  final void Function(int index, WorkExperience updated) onUpdateExperience;

  const WorkExperienceSection({
    super.key,
    required this.experiences,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddExperience,
    required this.onRemoveExperience,
    required this.onUpdateExperience,
  });

  void _showAddExperienceDialog(BuildContext context) {
    final companyController = TextEditingController();
    final positionController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'form.add_experience'.tr,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: companyController,
              style: GoogleFonts.outfit(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'form.company'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: positionController,
              style: GoogleFonts.outfit(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'form.position'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startController,
                    style: GoogleFonts.outfit(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Mulai',
                      hintText: '2021',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: endController,
                    style: GoogleFonts.outfit(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Selesai',
                      hintText: 'Sekarang',
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
              if (companyController.text.trim().isNotEmpty && positionController.text.trim().isNotEmpty) {
                onAddExperience(
                  WorkExperience(
                    company: companyController.text.trim(),
                    position: positionController.text.trim(),
                    startDate: startController.text.trim().isNotEmpty ? startController.text.trim() : '2022',
                    endDate: endController.text.trim().isNotEmpty ? endController.text.trim() : 'Sekarang',
                    highlights: [],
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

  void _showAddHighlightDialog(BuildContext context, int expIndex) {
    final highlightController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tambah Capaian (Google XYZ)',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: highlightController,
          maxLines: 3,
          autofocus: true,
          style: GoogleFonts.outfit(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Mencapai [X] yang diukur dengan [Y] melalui aksi [Z]...',
            hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr, style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = highlightController.text.trim();
              if (text.isNotEmpty) {
                final exp = experiences[expIndex];
                final newHighlights = List<String>.from(exp.highlights)..add(text);
                onUpdateExperience(
                  expIndex,
                  WorkExperience(
                    company: exp.company,
                    position: exp.position,
                    startDate: exp.startDate,
                    endDate: exp.endDate,
                    highlights: newHighlights,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.midnightNavy,
              foregroundColor: Colors.white,
            ),
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
                  'form.experience'.tr,
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
            for (int i = 0; i < experiences.length; i++) ...[
              _buildExperienceCard(context, i, experiences[i]),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: () => _showAddExperienceDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'form.add_experience'.tr,
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

  Widget _buildExperienceCard(BuildContext context, int index, WorkExperience exp) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${exp.position} — ${exp.company}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onRemoveExperience(index),
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.crimsonBordeaux),
                visualDensity: VisualDensity.compact,
                tooltip: 'common.delete'.tr,
              ),
            ],
          ),
          Text(
            '${exp.startDate} - ${exp.endDate}',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          for (final h in exp.highlights) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.accentSteel)),
                  Expanded(
                    child: Text(
                      h,
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showAddHighlightDialog(context, index),
              icon: const Icon(Icons.add, size: 14),
              label: Text('Tambah Poin Capaian', style: GoogleFonts.outfit(fontSize: 11)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentSteel,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
