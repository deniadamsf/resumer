import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Shareable ATS Score Card widget (Spotify Wrapped Style)
class AtsShareCard extends StatelessWidget {
  final String candidateName;
  final String targetRole;
  final int score;
  final String verdict;
  final Map<String, dynamic>? breakdown;

  const AtsShareCard({
    super.key,
    required this.candidateName,
    required this.targetRole,
    required this.score,
    required this.verdict,
    this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppColors.getScoreColor(score);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.midnightNavy, Color(0xFF16203D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2A3958)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Brand
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RESUMER ATS REPORT',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        verdict.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: scoreColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Candidate Info
                Text(
                  candidateName.isEmpty ? 'Kandidat Resumer' : candidateName,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  targetRole.isEmpty ? 'Professional Role' : targetRole,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 20),

                // Hero Score
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: GoogleFonts.outfit(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ 100',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mini Metric Breakdown
                if (breakdown != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        _buildMiniRow('Keywords Match', '${breakdown!['keyword_match'] ?? 24} / 25'),
                        const SizedBox(height: 4),
                        _buildMiniRow('Impact & Action Verbs', '${breakdown!['impact_verbs'] ?? 25} / 25'),
                        const SizedBox(height: 4),
                        _buildMiniRow('Format & Readability', '${breakdown!['readability'] ?? 24} / 25'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Watermark
                Center(
                  child: Text(
                    'Dibuat & Diuji di Resumer • resumer.cellanoma.my.id',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = 'ats.share_card_copy_template'.trArgs([score.toString(), verdict]);
                    Clipboard.setData(ClipboardData(text: text));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ats.share_copied_snack'.tr)),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text('ats.share_copy_btn'.tr, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.midnightNavy,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  minimumSize: const Size(48, 48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF94A3B8))),
        Text(value, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }
}
