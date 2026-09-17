import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../pdf_engine/templates/cv_template_interface.dart';
import '../../pdf_engine/templates/template_registry.dart';

/// Card for choosing CV template (ATS vs Creative Non-ATS), accent color, and ATS standard font.
/// Adheres strictly to UI UX Pro Max, Quiet Luxury, and Bespoke Executive Standards.
class TemplateSelectorCard extends StatefulWidget {
  final String selectedTemplateId;
  final String selectedFont;
  final String selectedColor;
  final ValueChanged<String> onTemplateChanged;
  final ValueChanged<String> onFontChanged;
  final ValueChanged<String> onColorChanged;

  const TemplateSelectorCard({
    super.key,
    required this.selectedTemplateId,
    required this.selectedFont,
    required this.selectedColor,
    required this.onTemplateChanged,
    required this.onFontChanged,
    required this.onColorChanged,
  });

  @override
  State<TemplateSelectorCard> createState() => _TemplateSelectorCardState();
}

class _TemplateSelectorCardState extends State<TemplateSelectorCard> {
  late CvTemplateCategory _activeCategory;

  @override
  void initState() {
    super.initState();
    final currentTemplate = TemplateRegistry.getTemplate(widget.selectedTemplateId);
    _activeCategory = currentTemplate.category;
  }

  @override
  void didUpdateWidget(covariant TemplateSelectorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTemplateId != widget.selectedTemplateId) {
      final currentTemplate = TemplateRegistry.getTemplate(widget.selectedTemplateId);
      if (currentTemplate.category != _activeCategory) {
        setState(() {
          _activeCategory = currentTemplate.category;
        });
      }
    }
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.midnightNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = TemplateRegistry.byCategory(_activeCategory);
    final activeTemplate = TemplateRegistry.getTemplate(widget.selectedTemplateId);
    final isNonAts = !activeTemplate.isAtsFriendly;

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
          // Header: Title and Font Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'form.template_selection'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Font dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.subtleSlateTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: TemplateRegistry.officialFonts.contains(widget.selectedFont)
                        ? widget.selectedFont
                        : TemplateRegistry.officialFonts.first,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 18),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.midnightNavy,
                    ),
                    items: TemplateRegistry.officialFonts.map((f) {
                      return DropdownMenuItem(value: f, child: Text('Font: $f'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) widget.onFontChanged(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category Pill Selector: ATS-Friendly vs Kreatif Non-ATS
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.subtleSlateTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildCategoryTab(
                    label: 'form.template_category_ats'.tr,
                    count: '3',
                    isSelected: _activeCategory == CvTemplateCategory.atsFriendly,
                    onTap: () {
                      setState(() => _activeCategory = CvTemplateCategory.atsFriendly);
                    },
                  ),
                ),
                Expanded(
                  child: _buildCategoryTab(
                    label: 'form.template_category_creative'.tr,
                    count: '3',
                    isSelected: _activeCategory == CvTemplateCategory.creativeNonAts,
                    onTap: () {
                      setState(() => _activeCategory = CvTemplateCategory.creativeNonAts);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Template Cards Carousel/List
          Column(
            children: templates.map((template) {
              final isSelected = widget.selectedTemplateId == template.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTemplateOptionCard(
                  template: template,
                  isSelected: isSelected,
                  onTap: () => widget.onTemplateChanged(template.id),
                ),
              );
            }).toList(),
          ),

          // Non-ATS Educational Warning Banner if non-ATS template is chosen
          if (isNonAts) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.5), // Subtle Amber
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.antiqueBronze.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.antiqueBronze),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'form.non_ats_warning_title'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.antiqueBronze,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'form.non_ats_warning_body'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Color Palette Selector (4 Official Executive Colors)
          Row(
            children: [
              Text(
                'form.color_selection'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                children: TemplateRegistry.officialColors.map((colorOpt) {
                  final isColorSelected = widget.selectedColor.toUpperCase() == colorOpt.hex.toUpperCase();
                  final swatchColor = _parseHex(colorOpt.hex);
                  return GestureDetector(
                    onTap: () => widget.onColorChanged(colorOpt.hex),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: swatchColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isColorSelected ? AppColors.midnightNavy : Colors.white,
                          width: isColorSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          if (isColorSelected)
                            BoxShadow(
                              color: swatchColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: isColorSelected
                          ? const Center(
                              child: Icon(Icons.check, size: 14, color: Colors.white),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required String count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.midnightNavy : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.midnightNavy.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.midnightNavy : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateOptionCard({
    required CvTemplate template,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final atsColor = template.isAtsFriendly ? AppColors.forestPine : AppColors.antiqueBronze;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.subtleSlateTint : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.midnightNavy : AppColors.borderHairline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Schematic layout icon
            Container(
              width: 38,
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: _buildSchematicPreview(template),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.nameKey.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppColors.midnightNavy : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: atsColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          template.atsScoreRange,
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: atsColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.descKey.tr,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 20,
              color: isSelected ? AppColors.midnightNavy : AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchematicPreview(CvTemplate template) {
    if (template.id == 'modern_creative') {
      // 2 column mini schematic
      return Row(
        children: [
          Container(width: 9, color: AppColors.mutedSteelSlate.withValues(alpha: 0.3)),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(height: 3, color: AppColors.midnightNavy),
                Container(height: 2, color: Colors.grey.shade300),
                Container(height: 2, color: Colors.grey.shade300),
                Container(height: 2, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      );
    } else if (template.id == 'compact_portfolio') {
      // Hero top banner schematic
      return Column(
        children: [
          Container(height: 10, color: AppColors.midnightNavy),
          const SizedBox(height: 3),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(height: 2, color: Colors.grey.shade300),
                Container(height: 2, color: Colors.grey.shade300),
                Container(height: 2, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      );
    } else if (template.id == 'executive_split') {
      // Left pillar schematic
      return Row(
        children: [
          Container(width: 3, color: AppColors.antiqueBronze),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(height: 4, color: AppColors.midnightNavy),
                Container(height: 2, color: Colors.grey.shade300),
                Container(height: 2, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      );
    } else {
      // Clean 1-column ATS schematic
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(height: 4, width: 22, color: AppColors.midnightNavy),
          Container(height: 2, width: 14, color: Colors.grey.shade400),
          Container(height: 1, color: Colors.grey.shade300),
          Container(height: 2, color: Colors.grey.shade300),
          Container(height: 2, color: Colors.grey.shade300),
        ],
      );
    }
  }
}
