import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Precision Radial ATS Score Gauge with smooth cubic animation
class AtsScoreGauge extends StatefulWidget {
  final int? score; // 0 - 100, or null if untested
  final String? verdict;

  const AtsScoreGauge({
    super.key,
    this.score,
    this.verdict,
  });

  @override
  State<AtsScoreGauge> createState() => _AtsScoreGaugeState();
}

class _AtsScoreGaugeState extends State<AtsScoreGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    final targetVal = widget.score != null ? (widget.score! / 100.0) : 0.0;
    _animation = Tween<double>(begin: 0, end: targetVal).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.score != null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AtsScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      final beginVal = oldWidget.score != null ? (oldWidget.score! / 100.0) : 0.0;
      final endVal = widget.score != null ? (widget.score! / 100.0) : 0.0;
      _animation = Tween<double>(
        begin: beginVal,
        end: endVal,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      if (widget.score != null) {
        _controller.forward(from: 0);
      } else {
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTested = widget.score != null;
    final scoreColor = isTested
        ? AppColors.getScoreColor(widget.score!)
        : AppColors.mutedSteelSlate;

    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final currentDisplayScore = isTested ? (_animation.value * 100).toInt() : null;

              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: isTested ? _animation.value : 0.0,
                      strokeWidth: 10,
                      backgroundColor: AppColors.subtleSlateTint,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isTested ? '$currentDisplayScore' : '—',
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: isTested ? scoreColor : AppColors.textSecondary,
                          letterSpacing: isTested ? -1.5 : 0,
                        ),
                      ),
                      Text(
                        'ats.score_label'.tr.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isTested
                ? scoreColor.withValues(alpha: 0.1)
                : AppColors.mutedSteelSlate.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isTested ? scoreColor.withValues(alpha: 0.3) : AppColors.borderHairline,
            ),
          ),
          child: Text(
            widget.verdict ??
                (isTested
                    ? (widget.score! >= 85
                        ? 'Top 5% ATS Ready'
                        : (widget.score! >= 60 ? 'Skor Menengah' : 'Perlu Optimasi'))
                    : 'ats.untested_verdict'.tr),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isTested ? scoreColor : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
