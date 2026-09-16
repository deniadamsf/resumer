import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/frosted_app_bar.dart';

/// Full-screen PDF Preview with Save & Share — No Print Dialog
/// Replaces Printing.layoutPdf() to eliminate unreadable OS toolbar icons in exported PDFs.
/// Adheres 100% to UI UX Pro Max and Quiet Luxury standards.
class PdfPreviewScreen extends StatefulWidget {
  final Future<Uint8List> Function() pdfBuilder;
  final String fileName;

  const PdfPreviewScreen({
    super.key,
    required this.pdfBuilder,
    required this.fileName,
  });

  /// Open PDF Preview as a full-screen route
  static Future<void> open(
    BuildContext context, {
    required Future<Uint8List> Function() pdfBuilder,
    required String fileName,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          pdfBuilder: pdfBuilder,
          fileName: fileName,
        ),
      ),
    );
  }

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _buildPdf();
  }

  Future<void> _buildPdf() async {
    try {
      final bytes = await widget.pdfBuilder();
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<File> _writeTempFile() async {
    final dir = await getTemporaryDirectory();
    final sanitized = widget.fileName.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
    final file = File('${dir.path}/$sanitized');
    await file.writeAsBytes(_pdfBytes!);
    return file;
  }

  Future<void> _handleSave() async {
    if (_pdfBytes == null) return;
    setState(() => _isSaving = true);

    try {
      // Save to Downloads directory on Android, Documents on iOS
      Directory? saveDir;
      if (Platform.isAndroid) {
        saveDir = Directory('/storage/emulated/0/Download');
        if (!await saveDir.exists()) {
          saveDir = await getExternalStorageDirectory();
        }
      } else {
        saveDir = await getApplicationDocumentsDirectory();
      }

      if (saveDir == null) {
        throw Exception('Cannot access storage');
      }

      final sanitized = widget.fileName.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
      final filePath = '${saveDir.path}/$sanitized';
      final file = File(filePath);
      await file.writeAsBytes(_pdfBytes!);

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'pdf_preview.saved'.tr} $sanitized',
              style: GoogleFonts.outfit(fontSize: 13),
            ),
            backgroundColor: AppColors.forestPine,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'common.error'.tr}: $e'),
            backgroundColor: AppColors.crimsonBordeaux,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleShare() async {
    if (_pdfBytes == null) return;

    try {
      final file = await _writeTempFile();
      HapticFeedback.lightImpact();
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: widget.fileName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'common.error'.tr}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oysterCanvas,
      appBar: FrostedAppBar(
        title: 'pdf_preview.title'.tr,
        showBackButton: true,
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(
              onPressed: _handleShare,
              icon: const Icon(Icons.share_rounded, size: 20, color: AppColors.midnightNavy),
              tooltip: 'pdf_preview.share'.tr,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.midnightNavy,
                strokeWidth: 2.5,
              ),
            )
          : _error != null
              ? _buildErrorView()
              : _buildPreview(),
      bottomNavigationBar: _pdfBytes != null ? _buildBottomActions() : null,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.crimsonBordeaux),
            const SizedBox(height: 16),
            Text(
              'pdf_preview.error'.tr,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.midnightNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return PdfPreview(
      build: (_) async => _pdfBytes!,
      allowPrinting: false,
      allowSharing: false,
      canChangePageFormat: false,
      canDebug: false,
      pdfFileName: widget.fileName,
      loadingWidget: const CircularProgressIndicator(
        color: AppColors.midnightNavy,
        strokeWidth: 2.5,
      ),
      scrollViewDecoration: const BoxDecoration(
        color: AppColors.oysterCanvas,
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: const Border(top: BorderSide(color: AppColors.borderHairline)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Save PDF Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                label: Text(
                  _isSaving ? 'common.loading'.tr : 'pdf_preview.save_btn'.tr,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.midnightNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Share PDF Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleShare,
                icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.midnightNavy),
                label: Text(
                  'pdf_preview.share'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  side: const BorderSide(color: AppColors.borderHairline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
