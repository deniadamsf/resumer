import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/coin_service.dart';
import 'coin_topup_sheet.dart';

/// Badge Koin Elegan berstandar Quiet Luxury.
/// Menampilkan saldo koin terkini secara reaktif dan membuka modal top-up saat ditekan.
class CoinBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const CoinBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CoinService.instance.coinsNotifier,
      builder: (context, coins, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () => CoinTopupSheet.show(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB), // Soft Amber background
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFDE68A), // Warm Amber border
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.toll_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$coins',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF92400E), // Antique Bronze
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 14,
                    color: Color(0xFFB45309),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
