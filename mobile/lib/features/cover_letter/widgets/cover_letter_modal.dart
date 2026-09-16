import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/signature_service.dart';
import '../../cv_editor/models/cv_model.dart';
import '../../pdf_engine/pdf_generator.dart';
import '../models/cover_letter_model.dart';
import 'signature_pad_modal.dart';

/// Quiet Luxury AI Cover Letter Modal Bottom Sheet
/// Complies 100% with UI UX Pro Max and Bespoke Executive Standards
class CoverLetterModal extends StatefulWidget {
  final CvDocument cv;
  final String? profileName;

  const CoverLetterModal({
    super.key,
    required this.cv,
    this.profileName,
  });

  static Future<void> show(BuildContext context, CvDocument cv, {String? profileName}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoverLetterModal(cv: cv, profileName: profileName),
    );
  }

  @override
  State<CoverLetterModal> createState() => _CoverLetterModalState();
}

class _CoverLetterModalState extends State<CoverLetterModal> {
  late TextEditingController _companyController;
  late TextEditingController _roleController;
  bool _isLoading = false;
  CoverLetterModel? _generatedLetter;
  Uint8List? _signatureBytes;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController();
    _roleController = TextEditingController(
      text: widget.cv.personalInfo.professionalTitle.isNotEmpty
          ? widget.cv.personalInfo.professionalTitle
          : '',
    );
    _loadSignature();
  }

  Future<void> _loadSignature() async {
    final bytes = await SignatureService.instance.getSignature();
    if (mounted) setState(() => _signatureBytes = bytes);
  }

  Future<void> _handleSignature() async {
    final bytes = await SignaturePadModal.show(context);
    if (bytes != null && mounted) {
      setState(() => _signatureBytes = bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('cover_letter.signature_saved'.tr),
          backgroundColor: AppColors.forestPine,
        ),
      );
    }
  }

  Future<void> _deleteSignature() async {
    await SignatureService.instance.deleteSignature();
    if (mounted) {
      setState(() => _signatureBytes = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('cover_letter.signature_removed'.tr),
          backgroundColor: AppColors.mutedSteelSlate,
        ),
      );
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final company = _companyController.text.trim();
    final role = _roleController.text.trim();
    if (company.isEmpty || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cover_letter.empty_error'.tr)),
      );
      return;
    }

    // Rewarded Ad 4 Gating
    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_cover_letter'.tr,
      onRewarded: () => _executeGenerate(company, role),
    );
  }

  Future<void> _executeGenerate(String company, String role) async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.instance.generateCoverLetter(
        widget.cv.toPlainText(),
        company,
        role,
      );

      if (response['success'] == true && mounted) {
        final rawLetter = (response['cover_letter'] ?? {}) as Map<String, dynamic>;
        setState(() {
          _generatedLetter = CoverLetterModel.fromJson(rawLetter, company: company, role: role);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'common.error'.tr}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard() {
    if (_generatedLetter == null) return;
    Clipboard.setData(ClipboardData(
      text: _generatedLetter!.toFormattedText(candidateName: widget.cv.personalInfo.fullName),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('cover_letter.copied'.tr),
        backgroundColor: AppColors.forestPine,
      ),
    );
  }

  Future<void> _exportPdf() async {
    if (_generatedLetter == null) return;
    final pdfBytes = await PdfGenerator.generateCoverLetterPdf(
      _generatedLetter!,
      widget.cv,
      signatureBytes: _signatureBytes,
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Cover_Letter_${widget.cv.personalInfo.fullName.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 14,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedSteelSlate.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'cover_letter.title'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.midnightNavy,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: _generatedLetter == null ? _buildInputForm() : _buildLetterPreview(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvReferenceCard() {
    final title = widget.profileName ?? 'CV';
    final role = widget.cv.personalInfo.professionalTitle.isNotEmpty
        ? widget.cv.personalInfo.professionalTitle
        : widget.cv.personalInfo.fullName;
    final skills = widget.cv.skills.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.midnightNavy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  role,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'cover_letter.cv_reference_note'.tr,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: Text(
                  s,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedSteelSlate,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCvReferenceCard(),
        Text(
          'cover_letter.subtitle'.tr,
          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        _buildTextField('cover_letter.company_label'.tr, _companyController, 'cover_letter.company_hint'.tr),
        const SizedBox(height: 14),
        _buildTextField('cover_letter.role_label'.tr, _roleController, 'cover_letter.role_hint'.tr),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleGenerate,
          icon: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.auto_awesome_outlined, size: 20, color: Colors.white),
          label: Text(
            _isLoading ? 'common.loading'.tr : 'cover_letter.generate_btn'.tr,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.midnightNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.midnightNavy),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.oysterCanvas,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderHairline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderHairline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.midnightNavy)),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.subtleSlateTint,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderHairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.forestPine),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${'cover_letter.cv_reference_title'.tr}: ${widget.profileName ?? "CV"} • ${widget.cv.personalInfo.fullName}',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.midnightNavy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.oysterCanvas,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderHairline),
          ),
          child: SelectableText(
            _generatedLetter!.toFormattedText(candidateName: widget.cv.personalInfo.fullName),
            style: GoogleFonts.outfit(fontSize: 13, height: 1.5, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 14),
        _buildSignatureSection(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.midnightNavy),
                label: Text('cover_letter.copy_btn'.tr, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.midnightNavy)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: const BorderSide(color: AppColors.borderHairline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.white),
                label: Text('cover_letter.pdf_btn'.tr, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.midnightNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _generatedLetter = null),
            child: Text(
              'cover_letter.edit_btn'.tr,
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    if (_signatureBytes != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.oysterCanvas,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderHairline),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.6)),
              ),
              child: Image.memory(
                _signatureBytes!,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'cover_letter.signature_status'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.midnightNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'form.photo_notice'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: AppColors.midnightNavy,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderHairline),
              ),
              color: Colors.white,
              elevation: 3,
              onSelected: (val) {
                if (val == 'change') {
                  _handleSignature();
                } else if (val == 'delete') {
                  _deleteSignature();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'change',
                  child: Row(
                    children: [
                      const Icon(Icons.draw_outlined, size: 18, color: AppColors.midnightNavy),
                      const SizedBox(width: 10),
                      Text(
                        'cover_letter.change_signature'.tr,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.midnightNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.crimsonBordeaux),
                      const SizedBox(width: 10),
                      Text(
                        'cover_letter.clear_signature'.tr,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.crimsonBordeaux,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _handleSignature,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.oysterCanvas,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderHairline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.midnightNavy.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.draw_outlined,
                size: 18,
                color: AppColors.midnightNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'cover_letter.add_signature'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.midnightNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'cover_letter.signature_hint'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
