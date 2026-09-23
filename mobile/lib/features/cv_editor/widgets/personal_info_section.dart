import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Personal Information and Local Photo Picker (0-byte Server Load)
class PersonalInfoSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController linkedinController;
  final TextEditingController githubController;
  final TextEditingController instagramController;
  final TextEditingController facebookController;
  final TextEditingController whatsappController;
  final TextEditingController websiteController;
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
    required this.githubController,
    required this.instagramController,
    required this.facebookController,
    required this.whatsappController,
    required this.websiteController,
    required this.localPhotoPath,
    required this.showPhotoOption,
    required this.onPhotoChanged,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  bool _isSocialExpanded = false;

  @override
  void initState() {
    super.initState();
    // Auto expand if any social link has existing content
    if (widget.linkedinController.text.isNotEmpty ||
        widget.githubController.text.isNotEmpty ||
        widget.instagramController.text.isNotEmpty ||
        widget.facebookController.text.isNotEmpty ||
        widget.whatsappController.text.isNotEmpty ||
        widget.websiteController.text.isNotEmpty) {
      _isSocialExpanded = true;
    }
  }

  Future<void> _pickPhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        widget.onPhotoChanged(picked.path);
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
              if (widget.showPhotoOption) _buildPhotoPickerBtn(context),
            ],
          ),
          if (widget.showPhotoOption && widget.localPhotoPath != null) ...[
            const SizedBox(height: 12),
            _buildPhotoPreview(context),
          ],
          const SizedBox(height: 12),
          _buildField('form.full_name'.tr, widget.nameController, Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _buildField('form.professional_title'.tr, widget.titleController, Icons.work_outline_rounded),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildField('form.email'.tr, widget.emailController, Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField('form.phone'.tr, widget.phoneController, Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildField('form.location'.tr, widget.locationController, Icons.location_on_outlined),
          const SizedBox(height: 14),
          _buildSocialAccordion(),
        ],
      ),
    );
  }

  Widget _buildSocialAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isSocialExpanded = !_isSocialExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.share_outlined, size: 16, color: AppColors.midnightNavy),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'form.social_links_section'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.midnightNavy,
                          ),
                        ),
                        Text(
                          'form.social_links_hint'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isSocialExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isSocialExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: Column(
                children: [
                  const Divider(height: 1, color: AppColors.borderHairline),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('form.linkedin'.tr, widget.linkedinController, Icons.link_rounded,
                            hintText: 'form.username_placeholder'.tr),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildField('form.github'.tr, widget.githubController, Icons.code_rounded,
                            hintText: 'form.username_placeholder'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('form.website'.tr, widget.websiteController, Icons.language_rounded,
                            hintText: 'form.web_placeholder'.tr),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildField('form.whatsapp'.tr, widget.whatsappController, Icons.chat_bubble_outline_rounded,
                            hintText: 'form.wa_placeholder'.tr, keyboardType: TextInputType.phone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('form.instagram'.tr, widget.instagramController, Icons.camera_alt_outlined,
                            hintText: 'form.username_placeholder'.tr),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildField('form.facebook'.tr, widget.facebookController, Icons.public_rounded,
                            hintText: 'form.username_placeholder'.tr),
                      ),
                    ],
                  ),
                ],
              ),
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
              widget.localPhotoPath != null ? 'form.photo_change'.tr : 'form.photo_btn'.tr,
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
    final file = File(widget.localPhotoPath!);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: file.existsSync()
              ? Image.file(file, key: ValueKey(widget.localPhotoPath), width: 44, height: 54, fit: BoxFit.cover)
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
          onPressed: () => widget.onPhotoChanged(null),
          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.crimsonBordeaux),
          tooltip: 'form.delete_photo_tooltip'.tr,
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, String? hintText}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontSize: 12.5, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 16, color: AppColors.textSecondary),
        labelStyle: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary),
        hintStyle: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: Colors.white,
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
