import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Hobbies & Interests Section with dynamic toggle ON/OFF & Wrap chips
class HobbiesSection extends StatefulWidget {
  final List<String> hobbies;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onAddHobby;
  final ValueChanged<int> onRemoveHobby;

  const HobbiesSection({
    super.key,
    required this.hobbies,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddHobby,
    required this.onRemoveHobby,
  });

  @override
  State<HobbiesSection> createState() => _HobbiesSectionState();
}

class _HobbiesSectionState extends State<HobbiesSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitHobby() {
    final val = _controller.text.trim();
    if (val.isNotEmpty) {
      widget.onAddHobby(val);
      _controller.clear();
    }
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
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      'form.hobbies'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                    if (widget.hobbies.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.subtleSlateTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.hobbies.length}',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedSteelSlate,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.subtleSlateTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'form.optional_badge'.tr,
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: widget.isEnabled,
                activeTrackColor: AppColors.midnightNavy,
                onChanged: widget.onToggle,
              ),
            ],
          ),
          if (widget.isEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'form.hobbies_hint'.tr,
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
                    onSubmitted: (_) => _submitHobby(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _submitHobby,
                  tooltip: 'form.add_hobby_tooltip'.tr,
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
            if (widget.hobbies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'form.empty_hobbies'.tr,
                  style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  for (int i = 0; i < widget.hobbies.length; i++)
                    Chip(
                      label: Text(
                        widget.hobbies[i],
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.midnightNavy,
                        ),
                      ),
                      backgroundColor: AppColors.subtleSlateTint,
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => widget.onRemoveHobby(i),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.borderHairline),
                      ),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
