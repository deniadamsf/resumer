import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/signature_service.dart';

/// Quiet Luxury Digital Signature Pad Bottom Sheet (<180 lines)
class SignaturePadModal extends StatefulWidget {
  const SignaturePadModal({super.key});

  static Future<Uint8List?> show(BuildContext context) {
    return showModalBottomSheet<Uint8List>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SignaturePadModal(),
    );
  }

  @override
  State<SignaturePadModal> createState() => _SignaturePadModalState();
}

class _SignaturePadModalState extends State<SignaturePadModal> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSaving = false;

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  Future<void> _saveSignature() async {
    if (_strokes.isEmpty && _currentStroke.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (boundary == null) return;
      final size = boundary.size;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));
      final painter = _SignaturePainter(strokes: _strokes, currentStroke: _currentStroke);
      painter.paint(canvas, size);

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        await SignatureService.instance.saveSignature(bytes);
        if (mounted) Navigator.pop(context, bytes);
      }
    } catch (e) {
      debugPrint('Error capturing signature: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasStrokes = _strokes.isNotEmpty || _currentStroke.isNotEmpty;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                'cover_letter.signature_title'.tr,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.midnightNavy),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'cover_letter.signature_hint'.tr,
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Interactive Signature Canvas Box
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              key: _canvasKey,
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.oysterCanvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderHairline, width: 1.5),
              ),
              child: Stack(
                children: [
                  // Baseline Guide
                  Positioned(
                    bottom: 45,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 1,
                      color: AppColors.mutedSteelSlate.withValues(alpha: 0.2),
                    ),
                  ),
                  Positioned(
                    bottom: 22,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'X  Garis Batas Tanda Tangan',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _currentStroke = [details.localPosition];
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _currentStroke.add(details.localPosition);
                      });
                    },
                    onPanEnd: (_) {
                      setState(() {
                        if (_currentStroke.isNotEmpty) {
                          _strokes.add(List.from(_currentStroke));
                          _currentStroke = [];
                        }
                      });
                    },
                    child: CustomPaint(
                      painter: _SignaturePainter(strokes: _strokes, currentStroke: _currentStroke),
                      size: Size.infinite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Bottom Actions: Clear & Save
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: hasStrokes ? _clearCanvas : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: AppColors.borderHairline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('cover_letter.clear_signature'.tr, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.midnightNavy)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (!hasStrokes || _isSaving) ? null : _saveSignature,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.midnightNavy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('cover_letter.save_signature'.tr, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _SignaturePainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.midnightNavy
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in [...strokes, currentStroke]) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
