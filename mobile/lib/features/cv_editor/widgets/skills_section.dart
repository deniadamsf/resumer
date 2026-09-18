import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/cv_model.dart';

/// Skills Section using Wrap chips & detailed description dialog (GEMINI.md Bagian 4 & UI UX Pro Max)
class SkillsSection extends StatelessWidget {
  final List<SkillItem> skills;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<SkillItem> onAddSkill;
  final ValueChanged<int> onRemoveSkill;
  final void Function(int index, SkillItem updated)? onUpdateSkill;

  const SkillsSection({
    super.key,
    required this.skills,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddSkill,
    required this.onRemoveSkill,
    this.onUpdateSkill,
  });

  void _showSkillDialog(BuildContext context, [int? editIndex]) {
    final isEditing = editIndex != null;
    final initialSkill = isEditing ? skills[editIndex] : null;

    final nameController = TextEditingController(text: initialSkill?.name ?? '');
    final descController = TextEditingController(text: initialSkill?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'form.edit_skill'.tr : 'form.skills'.tr,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'form.skill_name'.tr,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                autofocus: true,
                style: GoogleFonts.outfit(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'form.skill_name_hint'.tr,
                  hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'form.skill_desc'.tr,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descController,
                maxLines: 3,
                style: GoogleFonts.outfit(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'form.skill_desc_hint'.tr,
                  hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
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
            onPressed: () {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isNotEmpty) {
                if (isEditing) {
                  onUpdateSkill?.call(editIndex, SkillItem(name: name, description: desc));
                } else {
                  onAddSkill(SkillItem(name: name, description: desc));
                }
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.midnightNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isEditing ? 'common.save'.tr : 'form.add_btn'.tr,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quickController = TextEditingController();

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
                  'form.skills'.tr,
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quickController,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'form.skills_hint'.tr,
                      hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: AppColors.subtleSlateTint.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.borderHairline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.borderHairline),
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        onAddSkill(SkillItem(name: val.trim()));
                        quickController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    final val = quickController.text.trim();
                    if (val.isNotEmpty) {
                      onAddSkill(SkillItem(name: val));
                      quickController.clear();
                    } else {
                      _showSkillDialog(context);
                    }
                  },
                  tooltip: 'form.add_skill_tooltip'.tr,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.midnightNavy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(44, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Mandatory Wrap per GEMINI.md Bagian 4 & UI UX Pro Max
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                for (int i = 0; i < skills.length; i++)
                  _buildSkillChip(context, i, skills[i]),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showSkillDialog(context),
              icon: const Icon(Icons.tune_rounded, size: 15, color: AppColors.accentSteel),
              label: Text(
                'form.add_skill_desc'.tr,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentSteel),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillChip(BuildContext context, int index, SkillItem skill) {
    final hasDesc = skill.description.trim().isNotEmpty;

    return InkWell(
      onTap: () => _showSkillDialog(context, index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.subtleSlateTint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasDesc ? AppColors.accentSteel.withValues(alpha: 0.4) : AppColors.borderHairline,
            width: hasDesc ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  skill.name,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                ),
                if (hasDesc) ...[
                  const SizedBox(height: 2),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      skill.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => onRemoveSkill(index),
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 14, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
