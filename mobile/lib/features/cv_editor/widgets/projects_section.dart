import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_format_helper.dart';
import '../models/cv_model.dart';

/// Projects & Portfolio Section following Quiet Luxury & UI UX Pro Max standards
class ProjectsSection extends StatelessWidget {
  final List<ProjectItem> projects;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<ProjectItem> onAddProject;
  final ValueChanged<int> onRemoveProject;
  final void Function(int index, ProjectItem updated)? onUpdateProject;

  const ProjectsSection({
    super.key,
    required this.projects,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddProject,
    required this.onRemoveProject,
    this.onUpdateProject,
  });

  void _showProjectDialog(BuildContext context, [int? editIndex]) {
    final isEditing = editIndex != null;
    final initial = isEditing ? projects[editIndex] : null;
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');

    final nameController = TextEditingController(text: initial?.name ?? '');
    final roleController = TextEditingController(text: initial?.role ?? '');
    final descController = TextEditingController(text: initial?.description ?? '');

    // Parse start month & year using DateFormatHelper
    int startMonth = 1;
    String startYear = DateTime.now().year.toString();
    if (initial != null && initial.startDate.isNotEmpty) {
      final parsed = DateFormatHelper.parse(initial.startDate);
      if (parsed.month != null) startMonth = parsed.month!;
      if (parsed.year != null && parsed.year!.isNotEmpty) startYear = parsed.year!;
    }
    final startYearController = TextEditingController(text: startYear);

    // Parse end month & year or 'Sekarang' / 'Present'
    final initialEndParts = DateFormatHelper.parse(initial?.endDate);
    bool isCurrent = initial == null ? false : (initial.isCurrent || initialEndParts.isPresent);
    int endMonth = 12;
    String endYear = DateTime.now().year.toString();
    if (initial != null && !isCurrent && initial.endDate.isNotEmpty) {
      if (initialEndParts.month != null) endMonth = initialEndParts.month!;
      if (initialEndParts.year != null && initialEndParts.year!.isNotEmpty) endYear = initialEndParts.year!;
    }
    final endYearController = TextEditingController(text: endYear);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'form.edit_project'.tr : 'form.add_project'.tr,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'form.project_name'.tr,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  autofocus: !isEditing,
                  style: GoogleFonts.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'form.project_name_hint'.tr,
                    hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'form.project_role'.tr,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: roleController,
                  style: GoogleFonts.outfit(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'form.project_role_hint'.tr,
                    hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'form.project_start_date'.tr,
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
                            value: startMonth,
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
                        keyboardType: TextInputType.text,
                        style: GoogleFonts.outfit(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'form.start_year'.tr,
                          hintText: '2023',
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
                          'form.current_project_checkbox'.tr,
                          style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCurrent) ...[
                  const SizedBox(height: 6),
                  Text(
                    'form.project_end_date'.tr,
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
                              value: endMonth,
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
                          keyboardType: TextInputType.text,
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
                const SizedBox(height: 14),
                Text(
                  'form.project_desc'.tr,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  style: GoogleFonts.outfit(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'form.project_desc_hint'.tr,
                    hintStyle: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.midnightNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final startFormatted = DateFormatHelper.formatMonthYear(
                  startMonth,
                  startYearController.text.trim(),
                  isEnglish: isEn,
                  full: true,
                );

                final endFormatted = isCurrent
                    ? (isEn ? 'Present' : 'Sekarang')
                    : DateFormatHelper.formatMonthYear(
                        endMonth,
                        endYearController.text.trim(),
                        isEnglish: isEn,
                        full: true,
                      );

                final item = ProjectItem(
                  name: name,
                  role: roleController.text.trim(),
                  startDate: startFormatted,
                  endDate: endFormatted,
                  isCurrent: isCurrent,
                  description: descController.text.trim(),
                );

                if (isEditing) {
                  onUpdateProject?.call(editIndex, item);
                } else {
                  onAddProject(item);
                }
                Navigator.pop(ctx);
              },
              child: Text(
                isEditing ? 'common.save'.tr : 'common.add'.tr,
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
              ),
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
        boxShadow: const [
          BoxShadow(color: Color(0x060F172A), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'form.projects'.tr,
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.subtleSlateTint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${projects.length}',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedSteelSlate),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                onChanged: onToggle,
                activeTrackColor: AppColors.midnightNavy,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 10),
            if (projects.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'form.empty_projects'.tr,
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ...projects.asMap().entries.map((entry) {
              final idx = entry.key;
              final p = entry.value;
              final period = p.displayPeriod;
              final hasRole = p.role.isNotEmpty;
              final hasDesc = p.description.isNotEmpty;

              return InkWell(
                onTap: () => _showProjectDialog(context, idx),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.subtleSlateTint.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderHairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.crimsonBordeaux),
                            onPressed: () => onRemoveProject(idx),
                            visualDensity: VisualDensity.compact,
                            tooltip: 'common.delete'.tr,
                          ),
                        ],
                      ),
                      if (hasRole) ...[
                        const SizedBox(height: 2),
                        Text(
                          p.role,
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mutedSteelSlate),
                        ),
                      ],
                      if (period.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          period,
                          style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                      if (hasDesc) ...[
                        const SizedBox(height: 4),
                        Text(
                          p.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () => _showProjectDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.midnightNavy),
                label: Text(
                  'form.add_project'.tr,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.midnightNavy),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderHairline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
