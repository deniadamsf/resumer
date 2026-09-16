import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Text Area Input for Job Description & Requirements
/// Clean card layout with quick clipboard paste action
class JobTextInputSection extends StatelessWidget {
  final TextEditingController controller;

  const JobTextInputSection({
    super.key,
    required this.controller,
  });

  Future<void> _pasteFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      controller.text = data.text!;
      HapticFeedback.lightImpact();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teks lowongan berhasil ditempel dari clipboard'),
            duration: Duration(seconds: 1),
            backgroundColor: AppColors.midnightNavy,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  'job_match.paste_text'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _pasteFromClipboard(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.subtleSlateTint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderHairline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.content_paste_rounded,
                        size: 14,
                        color: AppColors.midnightNavy,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'job_match.paste_clipboard'.tr,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.midnightNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 5,
            maxLines: 10,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'job_match.text_hint'.tr,
              hintStyle: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.oysterCanvas,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderHairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderHairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.midnightNavy, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
