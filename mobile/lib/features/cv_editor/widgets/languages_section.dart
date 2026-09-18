import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/cv_model.dart';

/// Languages Section with proficiency level dropdown & dynamic toggle ON/OFF
class LanguagesSection extends StatefulWidget {
  final List<LanguageItem> languages;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<LanguageItem> onAddLanguage;
  final ValueChanged<int> onRemoveLanguage;
  final void Function(int index, LanguageItem updated)? onUpdateLanguage;

  const LanguagesSection({
    super.key,
    required this.languages,
    required this.isEnabled,
    required this.onToggle,
    required this.onAddLanguage,
    required this.onRemoveLanguage,
    this.onUpdateLanguage,
  });

  @override
  State<LanguagesSection> createState() => _LanguagesSectionState();
}

class _LanguagesSectionState extends State<LanguagesSection> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedProficiency = 'Native / Bilingual';

  final List<String> _proficiencyOptions = [
    'Native / Bilingual',
    'Fluent (Fasih)',
    'Professional Working',
    'Intermediate (Menengah)',
    'Elementary / Basic (Dasar)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addCurrentLanguage() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.onAddLanguage(LanguageItem(
        name: name,
        proficiency: _selectedProficiency,
      ));
      _nameController.clear();
      setState(() {
        _selectedProficiency = 'Native / Bilingual';
      });
    }
  }

  void _showEditDialog(BuildContext context, int index) {
    final item = widget.languages[index];
    final editController = TextEditingController(text: item.name);
    String editProficiency = item.proficiency;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'form.edit_language'.tr,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'form.language_name'.tr,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: editController,
                autofocus: true,
                style: GoogleFonts.outfit(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'form.language_name_hint'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'form.proficiency'.tr,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _proficiencyOptions.contains(editProficiency) ? editProficiency : _proficiencyOptions.first,
                    isExpanded: true,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
                    items: _proficiencyOptions.map((opt) {
                      return DropdownMenuItem(value: opt, child: Text(opt));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => editProficiency = val);
                      }
                    },
                  ),
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
                final name = editController.text.trim();
                if (name.isNotEmpty) {
                  widget.onUpdateLanguage?.call(
                    index,
                    LanguageItem(name: name, proficiency: editProficiency),
                  );
                }
                Navigator.pop(ctx);
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
                      'form.languages'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midnightNavy,
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
            // Input Row: Language Name + Proficiency Dropdown + Add Button
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'form.language_name_hint'.tr,
                      hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
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
                    onSubmitted: (_) => _addCurrentLanguage(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.subtleSlateTint.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderHairline),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProficiency,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textSecondary),
                        style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.midnightNavy),
                        items: _proficiencyOptions.map((opt) {
                          return DropdownMenuItem(
                            value: opt,
                            child: Text(opt, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedProficiency = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addCurrentLanguage,
                  tooltip: 'form.add_language'.tr,
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
            // Chips wrap for added languages
            if (widget.languages.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'form.empty_languages'.tr,
                  style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  for (int i = 0; i < widget.languages.length; i++)
                    _buildLanguageChip(context, i, widget.languages[i]),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageChip(BuildContext context, int index, LanguageItem item) {
    return InkWell(
      onTap: () => _showEditDialog(context, index),
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
            Text(
              item.name,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.midnightNavy,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Text(
                item.proficiency,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentSteel,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => widget.onRemoveLanguage(index),
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
