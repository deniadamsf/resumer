import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Precision Radial ATS Score Gauge with smooth cubic animation
class AtsScoreGauge extends StatefulWidget {
  final int score; // 0 - 100
  final String? verdict;

  const AtsScoreGauge({
    super.key,
    required this.score,
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
    _animation = Tween<double>(begin: 0, end: widget.score / 100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AtsScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: oldWidget.score / 100.0,
        end: widget.score / 100.0,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppColors.getScoreColor(widget.score);

    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final currentDisplayScore = (_animation.value * 100).toInt();

              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: _animation.value,
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
                        '$currentDisplayScore',
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                          letterSpacing: -1.5,
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
            color: scoreColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            widget.verdict ?? (widget.score >= 85 ? 'Top 5% ATS Ready' : (widget.score >= 60 ? 'Skor Menengah' : 'Perlu Optimasi')),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scoreColor,
            ),
          ),
        ),
      ],
    );
  }
}
