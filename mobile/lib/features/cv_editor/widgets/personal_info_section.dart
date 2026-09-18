import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Personal Information and Local Photo Picker (0-byte Server Load)
class PersonalInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController linkedinController;
  final String? localPhotoPath;
  final bool showPhotoOption;
  final ValueChanged<String?> onPhotoChanged;

  const PersonalInfoSection({
    super.key,
    required this.nameController,
    required this.titleController,
    required this.emailController,
    required this.phoneController,
    required this.locationController,
    required this.linkedinController,
    required this.localPhotoPath,
    required this.showPhotoOption,
    required this.onPhotoChanged,
  });

  Future<void> _pickPhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        onPhotoChanged(picked.path);
      }
    } catch (_) {}
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
                  'form.personal_info'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (showPhotoOption) _buildPhotoPickerBtn(context),
            ],
          ),
          if (showPhotoOption && localPhotoPath != null) ...[
            const SizedBox(height: 12),
            _buildPhotoPreview(context),
          ],
          const SizedBox(height: 12),
          _buildField('form.full_name'.tr, nameController, Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _buildField('form.professional_title'.tr, titleController, Icons.work_outline_rounded),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildField('form.email'.tr, emailController, Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField('form.phone'.tr, phoneController, Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildField('form.location'.tr, locationController, Icons.location_on_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField('form.linkedin'.tr, linkedinController, Icons.link_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPickerBtn(BuildContext context) {
    return InkWell(
      onTap: () => _pickPhoto(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.accentSteel),
            const SizedBox(width: 4),
            Text(
              localPhotoPath != null ? 'form.photo_change'.tr : 'form.photo_btn'.tr,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accentSteel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(BuildContext context) {
    final file = File(localPhotoPath!);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: file.existsSync()
              ? Image.file(file, width: 44, height: 54, fit: BoxFit.cover)
              : Container(width: 44, height: 54, color: AppColors.subtleSlateTint),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'form.photo_saved_locally'.tr,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                'form.photo_secure_badge'.tr,
                style: GoogleFonts.outfit(fontSize: 10, color: AppColors.forestPine),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => onPhotoChanged(null),
          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.crimsonBordeaux),
          tooltip: 'form.delete_photo_tooltip'.tr,
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        labelStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    );
  }
}
