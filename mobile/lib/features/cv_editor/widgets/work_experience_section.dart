import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/cv_model.dart';

/// Work Experience Section with month & year selection & Google XYZ bullet highlights
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

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  void _showExperienceDialog(BuildContext context, [int? editIndex]) {
    final isEditing = editIndex != null;
    final initial = isEditing ? experiences[editIndex] : null;

    final companyController = TextEditingController(text: initial?.company ?? '');
    final positionController = TextEditingController(text: initial?.position ?? '');

    // Parse start month & year
    String startMonth = 'Jan';
    String startYear = DateTime.now().year.toString();
    if (initial != null && initial.startDate.isNotEmpty) {
      final parts = initial.startDate.split(' ');
      if (parts.length >= 2 && _months.contains(parts[0])) {
        startMonth = parts[0];
        startYear = parts[1];
      } else {
        startYear = initial.startDate;
      }
    }
    final startYearController = TextEditingController(text: startYear);

    // Parse end month & year or 'Sekarang'
    bool isCurrent = initial == null || initial.endDate.toLowerCase().contains('sekarang') || initial.endDate.toLowerCase().contains('present');
    String endMonth = 'Des';
    String endYear = DateTime.now().year.toString();
    if (initial != null && !isCurrent && initial.endDate.isNotEmpty) {
      final parts = initial.endDate.split(' ');
      if (parts.length >= 2 && _months.contains(parts[0])) {
        endMonth = parts[0];
        endYear = parts[1];
      } else {
        endYear = initial.endDate;
      }
    }
    final endYearController = TextEditingController(text: endYear);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Ubah Pengalaman Kerja' : 'form.add_experience'.tr,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: companyController,
                  autofocus: !isEditing,
                  style: GoogleFonts.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'form.company'.tr,
                    hintText: 'cth: PT GoTo Gojek Tokopedia, Telkom',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: positionController,
                  style: GoogleFonts.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'form.position'.tr,
                    hintText: 'cth: Senior Mobile Developer, Product Manager',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'form.start_date'.tr,
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
                          child: DropdownButton<String>(
                            value: startMonth,
                            isExpanded: true,
                            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
                            items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => startMonth = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: startYearController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'form.start_year'.tr,
                          hintText: '2022',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setModalState(() => isCurrent = !isCurrent),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCurrent,
                        activeColor: AppColors.midnightNavy,
                        onChanged: (val) => setModalState(() => isCurrent = val ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'form.current_work_checkbox'.tr,
                          style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCurrent) ...[
                  const SizedBox(height: 6),
                  Text(
                    'form.end_date'.tr,
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
                            child: DropdownButton<String>(
                              value: endMonth,
                              isExpanded: true,
                              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
                              items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => endMonth = val);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: endYearController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.outfit(fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'form.end_year'.tr,
                            hintText: '2024',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                final company = companyController.text.trim();
                final position = positionController.text.trim();
                final sYear = startYearController.text.trim();
                final eYear = endYearController.text.trim();

                if (company.isNotEmpty && position.isNotEmpty) {
                  final startFormatted = sYear.isNotEmpty ? '$startMonth $sYear' : startMonth;
                  final endFormatted = isCurrent ? 'Sekarang' : (eYear.isNotEmpty ? '$endMonth $eYear' : endMonth);

                  if (isEditing) {
                    onUpdateExperience(
                      editIndex,
                      WorkExperience(
                        company: company,
                        position: position,
                        startDate: startFormatted,
                        endDate: endFormatted,
                        highlights: initial!.highlights,
                      ),
                    );
                  } else {
                    onAddExperience(
                      WorkExperience(
                        company: company,
                        position: position,
                        startDate: startFormatted,
                        endDate: endFormatted,
                        highlights: [],
                      ),
                    );
                  }
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.midnightNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEditing ? 'Simpan' : 'Tambah', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              onPressed: () => _showExperienceDialog(context),
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
    return InkWell(
      onTap: () => _showExperienceDialog(context, index),
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
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentSteel),
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
      ),
    );
  }
}
