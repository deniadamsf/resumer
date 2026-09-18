import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/cv_model.dart';

/// Certifications Section with detailed metadata & description for AI Polish
class CertificationsSection extends StatelessWidget {
  final List<CertificationItem> certifications;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<CertificationItem> onAddCertification;
  final ValueChanged<int> onRemoveCertification;
  final void Function(int index, CertificationItem updated)? onUpdateCertification;

  const CertificationsSection({
    super.key,
    required this.certifications,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddCertification,
    required this.onRemoveCertification,
    this.onUpdateCertification,
  });

  void _showCertDialog(BuildContext context, [int? editIndex]) {
    final isEditing = editIndex != null;
    final initial = isEditing ? certifications[editIndex] : null;

    final nameController = TextEditingController(text: initial?.name ?? '');
    final issuerController = TextEditingController(text: initial?.issuer ?? '');
    final yearController = TextEditingController(text: initial?.year ?? '');
    final descController = TextEditingController(text: initial?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditing ? 'form.edit_cert'.tr : 'form.certifications'.tr,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'form.cert_name'.tr,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                autofocus: true,
                style: GoogleFonts.outfit(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'form.cert_name_hint'.tr,
                  hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'form.cert_issuer'.tr,
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: issuerController,
                          style: GoogleFonts.outfit(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'form.cert_issuer_hint'.tr,
                            hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'form.cert_year'.tr,
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: yearController,
                          style: GoogleFonts.outfit(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: '2023',
                            hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'form.cert_desc'.tr,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descController,
                maxLines: 3,
                style: GoogleFonts.outfit(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'form.cert_desc_hint'.tr,
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
              if (name.isNotEmpty) {
                final cert = CertificationItem(
                  name: name,
                  issuer: issuerController.text.trim(),
                  year: yearController.text.trim(),
                  description: descController.text.trim(),
                );
                if (isEditing) {
                  onUpdateCertification?.call(editIndex, cert);
                } else {
                  onAddCertification(cert);
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
                  'form.certifications'.tr,
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
                      hintText: 'cth: AWS Solutions Architect, Google Cert',
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
                        onAddCertification(CertificationItem(name: val.trim()));
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
                      onAddCertification(CertificationItem(name: val));
                      quickController.clear();
                    } else {
                      _showCertDialog(context);
                    }
                  },
                  tooltip: 'form.add_cert_tooltip'.tr,
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
            for (int i = 0; i < certifications.length; i++) ...[
              _buildCertCard(context, i, certifications[i]),
              const SizedBox(height: 8),
            ],
            TextButton.icon(
              onPressed: () => _showCertDialog(context),
              icon: const Icon(Icons.tune_rounded, size: 15, color: AppColors.accentSteel),
              label: Text(
                'form.add_cert_full'.tr,
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

  Widget _buildCertCard(BuildContext context, int index, CertificationItem cert) {
    return InkWell(
      onTap: () => _showCertDialog(context, index),
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
                    cert.name,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onRemoveCertification(index),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.crimsonBordeaux),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'common.delete'.tr,
                ),
              ],
            ),
            if (cert.issuer.isNotEmpty || cert.year.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                [if (cert.issuer.isNotEmpty) cert.issuer, if (cert.year.isNotEmpty) cert.year].join(' • '),
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentSteel),
              ),
            ],
            if (cert.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                cert.description,
                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
