import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

class AtsScoreGauge extends StatefulWidget {
  final int score; // 0 - 100
  final Map<String, dynamic>? breakdown;
  final List<dynamic>? actionableFeedback;
  final VoidCallback? onAutoFixTap;

  const AtsScoreGauge({
    super.key,
    required this.score,
    this.breakdown,
    this.actionableFeedback,
    this.onAutoFixTap,
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
      duration: const Duration(milliseconds: 1500),
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Radial Progress Gauge
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
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'ats.score_label'.tr.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
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
          const SizedBox(height: 24),

          // 1-Click Auto-Fix Button (if score < 90)
          if (widget.score < 90 && widget.onAutoFixTap != null) ...[
            InkWell(
              onTap: widget.onAutoFixTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.midnightNavy, AppColors.mutedSteelSlate],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ats.auto_fix_btn'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Breakdown metrics
          if (widget.breakdown != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ats.breakdown_title'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMetricBar('ats.keyword_match'.tr,
                (widget.breakdown!['keyword_match'] ?? 20) as int, 25),
            _buildMetricBar('ats.impact_verbs'.tr,
                (widget.breakdown!['impact_verbs'] ?? 20) as int, 25),
            _buildMetricBar('ats.readability'.tr,
                (widget.breakdown!['readability'] ?? 20) as int, 25),
            _buildMetricBar('ats.completeness'.tr,
                (widget.breakdown!['completeness'] ?? 20) as int, 25),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, int value, int maxVal) {
    final percentage = (value / maxVal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$value / $maxVal',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppColors.subtleSlateTint,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 0.85
                    ? AppColors.forestPine
                    : (percentage >= 0.60
                        ? AppColors.antiqueBronze
                        : AppColors.crimsonBordeaux),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
