import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../models/cv_model.dart';

/// Section Widget for managing and displaying Education history.
/// Adheres strictly to UI UX Pro Max & GEMINI.md Section 7.
class EducationSection extends StatelessWidget {
  final List<Education> educations;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<Education> onAddEducation;
  final ValueChanged<int> onRemoveEducation;
  final void Function(int index, Education updated)? onUpdateEducation;

  const EducationSection({
    super.key,
    required this.educations,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddEducation,
    required this.onRemoveEducation,
    this.onUpdateEducation,
  });

  void _showEducationDialog(BuildContext context, [int? editIndex]) {
    final isEditing = editIndex != null;
    final initial = isEditing ? educations[editIndex] : null;
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');

    final schoolController = TextEditingController(text: initial?.institution ?? '');
    final degreeController = TextEditingController(text: initial?.degree ?? '');
    final fieldController = TextEditingController(text: initial?.fieldOfStudy ?? '');
    final gpaController = TextEditingController(text: initial?.gpa ?? '');

    // Parse graduation month & year using intelligent DateFormatHelper
    int gradMonth = 8;
    String gradYear = DateTime.now().year.toString();
    if (initial != null && initial.graduationYear.isNotEmpty) {
      final parsed = DateFormatHelper.parse(initial.graduationYear);
      if (parsed.month != null) gradMonth = parsed.month!;
      if (parsed.year != null && parsed.year!.isNotEmpty) gradYear = parsed.year!;
    }
    final yearController = TextEditingController(text: gradYear);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'form.edit_education'.tr : 'form.add_education'.tr,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: schoolController,
                  autofocus: !isEditing,
                  style: GoogleFonts.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'form.institution'.tr,
                    hintText: 'form.institution_hint'.tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: degreeController,
                  style: GoogleFonts.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'form.degree_label'.tr,
                    hintText: 'form.degree_hint'.tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fieldController,
                  style: GoogleFonts.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'form.field_of_study'.tr,
                    hintText: 'form.field_of_study_hint'.tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'form.grad_month_year'.tr,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderHairline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: gradMonth,
                            isExpanded: true,
                            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
                            items: List.generate(12, (i) {
                              final mIdx = i + 1;
                              return DropdownMenuItem<int>(
                                value: mIdx,
                                child: Text(
                                  DateFormatHelper.getMonthName(mIdx, isEnglish: isEn, full: true),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(fontSize: 12.5, color: AppColors.textPrimary),
                                ),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) setModalState(() => gradMonth = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: yearController,
                        keyboardType: TextInputType.text,
                        style: GoogleFonts.outfit(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'form.grad_year_label'.tr,
                          hintText: '2023',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: gpaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'form.gpa_optional_hint'.tr,
                    hintText: 'form.gpa_hint'.tr,
                    helperText: 'form.gpa_sma_note'.tr,
                    helperMaxLines: 2,
                    helperStyle: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('common.cancel'.tr, style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final institution = schoolController.text.trim();
                final degree = degreeController.text.trim();
                final yearInput = yearController.text.trim();

                // Smart check: if user typed month name into year field (e.g. "agustus 2023"), extract both
                final parsedYear = DateFormatHelper.parse(yearInput);
                final finalMonth = parsedYear.month ?? gradMonth;
                final finalYear = parsedYear.year ?? (RegExp(r'\b\d{4}\b').firstMatch(yearInput)?.group(0) ?? yearInput);

                final formattedDate = DateFormatHelper.formatMonthYear(
                  finalMonth,
                  finalYear,
                  isEnglish: isEn,
                  full: true,
                );

                if (institution.isNotEmpty && degree.isNotEmpty) {
                  final edu = Education(
                    institution: institution,
                    degree: degree,
                    fieldOfStudy: fieldController.text.trim(),
                    graduationYear: formattedDate,
                    gpa: gpaController.text.trim(),
                  );
                  if (isEditing) {
                    onUpdateEducation?.call(editIndex, edu);
                  } else {
                    onAddEducation(edu);
                  }
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.midnightNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEditing ? 'common.save'.tr : 'form.add_btn'.tr, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
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
              onPressed: () => _showEducationDialog(context),
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
    final hasGpa = edu.gpa.trim().isNotEmpty;

    return InkWell(
      onTap: () => _showEducationDialog(context, index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                    edu.fieldOfStudy.isNotEmpty ? '${edu.degree} — ${edu.fieldOfStudy}' : edu.degree,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
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
            Text(
              edu.institution,
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  DateFormatHelper.formatEducationDate(
                    edu.graduationYear,
                    isEnglish: AppLocalizations.instance.currentLocale.startsWith('en'),
                  ),
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentSteel),
                ),
                if (hasGpa) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderHairline),
                    ),
                    child: Text(
                      'IPK: ${edu.gpa.trim()}',
                      style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
