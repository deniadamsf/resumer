import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';

/// Certifications Section with dynamic toggle ON/OFF & Wrap chips
class CertificationsSection extends StatelessWidget {
  final List<String> certifications;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onAddCertification;
  final ValueChanged<String> onRemoveCertification;

  const CertificationsSection({
    super.key,
    required this.certifications,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddCertification,
    required this.onRemoveCertification,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

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
                  'Sertifikasi & Lisensi Profesional',
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
                    controller: controller,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'cth: AWS Solutions Architect, PMP, Scm',
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
                        onAddCertification(val.trim());
                        controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    final val = controller.text.trim();
                    if (val.isNotEmpty) {
                      onAddCertification(val);
                      controller.clear();
                    }
                  },
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
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: certifications
                  .map(
                    (cert) => Chip(
                      label: Text(
                        cert,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.midnightNavy,
                        ),
                      ),
                      backgroundColor: AppColors.subtleSlateTint,
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => onRemoveCertification(cert),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.borderHairline),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
