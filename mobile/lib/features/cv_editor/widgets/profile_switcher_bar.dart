import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/cv_model.dart';

/// Segmented Profile Switcher (CV 1, CV 2, CV 3) with Quiet Luxury styling & UI UX Pro Max standards
class ProfileSwitcherBar extends StatelessWidget {
  final int currentIndex;
  final CvProfileMeta currentMeta;
  final bool isSyncing;
  final ValueChanged<int> onProfileSelected;
  final void Function(String newTitle, String newTargetJob) onRenameProfile;

  const ProfileSwitcherBar({
    super.key,
    required this.currentIndex,
    required this.currentMeta,
    required this.isSyncing,
    required this.onProfileSelected,
    required this.onRenameProfile,
  });

  void _showRenameDialog(BuildContext context) {
    final titleController = TextEditingController(text: currentMeta.title);
    final targetJobController = TextEditingController(text: currentMeta.targetJob);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'profile.rename_title'.tr,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.midnightNavy,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Judul Profil',
                hintText: 'profile.rename_hint'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetJobController,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Posisi Target',
                hintText: 'profile.target_role_hint'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
              Navigator.pop(ctx);
              onRenameProfile(titleController.text.trim(), targetJobController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.midnightNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('common.save'.tr, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
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
          // Segmented selector row
          Row(
            children: [
              for (int i = 1; i <= 3; i++) ...[
                Expanded(
                  child: InkWell(
                    onTap: () => onProfileSelected(i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44, // Minimal 44px touch target (UI UX PRO MAX)
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: currentIndex == i ? AppColors.midnightNavy : AppColors.subtleSlateTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: currentIndex == i ? AppColors.midnightNavy : AppColors.borderHairline,
                        ),
                      ),
                      child: Text(
                        'CV $i',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: currentIndex == i ? FontWeight.w700 : FontWeight.w500,
                          color: currentIndex == i ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Active profile meta info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentMeta.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                    if (currentMeta.targetJob.isNotEmpty)
                      Text(
                        currentMeta.targetJob,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.mutedSteelSlate),
                tooltip: 'Opsi Profil',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderHairline),
                ),
                color: AppColors.cardSurface,
                elevation: 4,
                onSelected: (val) {
                  if (val == 'edit') {
                    _showRenameDialog(context);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      'Ubah Nama Profil',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              isSyncing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.antiqueBronze),
                    )
                  : const Icon(Icons.cloud_done_rounded, size: 16, color: AppColors.forestPine),
            ],
          ),
        ],
      ),
    );
  }
}
