import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../constants/colors.dart';
import '../localization/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/coin_service.dart';
import '../services/iap_service.dart';

/// Modal Bottom Sheet: CoinTopupSheet
/// Desain Quiet Luxury modern untuk pembelian paket koin Google Play Billing.
class CoinTopupSheet extends StatefulWidget {
  const CoinTopupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CoinTopupSheet(),
    );
  }

  @override
  State<CoinTopupSheet> createState() => _CoinTopupSheetState();
}

class _CoinTopupSheetState extends State<CoinTopupSheet> {
  String? _purchasingProductId;

  @override
  void initState() {
    super.initState();
    // Pastikan produk Play Console termuat
    IapService.instance.loadProducts(IapService.coinProductIds);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocalizations.instance.currentLocale.startsWith('en');
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderHairline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title & Actions (Top-Right: Watch Ad for Coin & Current Balance)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Top-up Resumer Coins' : 'Top-up Koin Resumer',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.midnightNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEn
                          ? 'Unlock AI features & skip ads instantly'
                          : 'Buka fitur AI & lewati iklan secara instan',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBalancePill(isEn),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Pojok Kanan Atas: Menu Tambah Poin Lihat Iklan
              _buildWatchAdMenuButton(context, isEn),
            ],
          ),
          const SizedBox(height: 18),

          // Error notification if any
          ValueListenableBuilder<String?>(
            valueListenable: IapService.instance.purchaseErrorNotifier,
            builder: (context, error, _) {
              if (error == null || error.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.crimsonBordeaux.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.crimsonBordeauxLight.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.crimsonBordeaux),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          color: AppColors.crimsonBordeaux,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 3 Coin Packages List
          ValueListenableBuilder<List<ProductDetails>>(
            valueListenable: IapService.instance.productsNotifier,
            builder: (context, products, _) {
              return Column(
                children: [
                  _buildPackageCard(
                    context: context,
                    productId: IapService.coinTier30,
                    coins: 30,
                    title: 'Starter Pack',
                    subtitle: isEn ? '10x Job Matcher or 30x PDF Export' : 'Cukup untuk 10x Job Matcher',
                    fallbackPrice: 'Rp 10.000',
                    isPopular: false,
                    products: products,
                  ),
                  const SizedBox(height: 10),
                  _buildPackageCard(
                    context: context,
                    productId: IapService.coinTier70,
                    coins: 70,
                    title: 'Job Hunter Pack',
                    subtitle: isEn ? 'Best Value (incl. 10 Bonus Coins)' : 'Hemat (Termasuk Bonus 10 Koin)',
                    badgeText: 'BEST VALUE',
                    fallbackPrice: 'Rp 20.000',
                    isPopular: true,
                    products: products,
                  ),
                  const SizedBox(height: 10),
                  _buildPackageCard(
                    context: context,
                    productId: IapService.coinTier200,
                    coins: 200,
                    title: 'Career Pro Pack',
                    subtitle: isEn ? 'Super Saver (incl. 50 Bonus Coins)' : 'Sultan (Termasuk Bonus 50 Koin)',
                    badgeText: 'SULTAN',
                    badgeColor: AppColors.forestPine,
                    fallbackPrice: 'Rp 50.000',
                    isPopular: false,
                    products: products,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Quick Coin Cost Reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.subtleSlateTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCostChip('3 Koin', isEn ? 'Job Matcher' : 'Cocok Loker'),
                Container(width: 1, height: 24, color: AppColors.borderHairline),
                _buildCostChip('2 Koin', isEn ? 'Cover Letter' : 'Surat Lamaran'),
                Container(width: 1, height: 24, color: AppColors.borderHairline),
                _buildCostChip('1 Koin', isEn ? 'Skip Ad/Export' : 'Lewati Iklan'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Safe Play Billing Footer Notice
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                isEn
                    ? '100% Secure via Google Play Billing'
                    : 'Transaksi aman & resmi melalui Google Play Billing',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostChip(String cost, String label) {
    return Column(
      children: [
        Text(
          cost,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF92400E),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard({
    required BuildContext context,
    required String productId,
    required int coins,
    required String title,
    required String subtitle,
    required String fallbackPrice,
    required bool isPopular,
    required List<ProductDetails> products,
    String? badgeText,
    Color? badgeColor,
  }) {
    // Cari ProductDetails resmi dari Play Store jika ada
    ProductDetails? matchedProduct;
    for (final p in products) {
      if (p.id == productId) {
        matchedProduct = p;
        break;
      }
    }

    final priceLabel = matchedProduct?.price ?? fallbackPrice;
    final isThisPurchasing = _purchasingProductId == productId;

    return Container(
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFFFFFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0xFFF59E0B) : AppColors.borderHairline,
          width: isPopular ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPopular ? 0.04 : 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isThisPurchasing ? null : () => _handleBuy(productId, matchedProduct),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Coin Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Center(
                    child: Text(
                      '$coins',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.midnightNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor ?? const Color(0xFFD97706),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Price Action Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPopular ? AppColors.midnightNavy : AppColors.subtleSlateTint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPopular ? AppColors.midnightNavy : AppColors.borderHairline,
                    ),
                  ),
                  child: isThisPurchasing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          priceLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isPopular ? Colors.white : AppColors.midnightNavy,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBuy(String productId, ProductDetails? matchedProduct) async {
    setState(() => _purchasingProductId = productId);

    try {
      if (matchedProduct != null) {
        await IapService.instance.buyProduct(matchedProduct, isConsumable: true);
      } else {
        // Jika offline atau emulator tanpa Google Play Store aktif:
        // Tampilkan simulasi sandbox testing
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              'Menghubungkan ke Google Play Store ($productId)...',
              style: GoogleFonts.outfit(fontSize: 12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Jika Play Store tidak tersedia, reload produk
        await IapService.instance.loadProducts(IapService.coinProductIds);
      }
    } finally {
      if (mounted) {
        setState(() => _purchasingProductId = null);
      }
    }
  }

  Widget _buildBalancePill(bool isEn) {
    return ValueListenableBuilder<int>(
      valueListenable: CoinService.instance.coinsNotifier,
      builder: (context, balance, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.toll_rounded, size: 14, color: Color(0xFFD97706)),
              const SizedBox(width: 4),
              Text(
                '$balance ${isEn ? "Coins" : "Koin"}',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF92400E),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tombol Menu di Pojok Kanan Atas untuk mendapatkan koin dengan melihat iklan
  Widget _buildWatchAdMenuButton(BuildContext context, bool isEn) {
    return ValueListenableBuilder<int>(
      valueListenable: CoinService.instance.adCoinsClaimedTodayNotifier,
      builder: (context, claimedToday, _) {
        final isMax = claimedToday >= CoinService.maxDailyAdCoins;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showWatchAdExplanationDialog(context, isEn),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMax
                      ? [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)]
                      : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMax ? const Color(0xFFD1D5DB) : const Color(0xFFF59E0B),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMax ? Colors.black : const Color(0xFFD97706)).withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMax ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded,
                    size: 18,
                    color: isMax ? AppColors.textSecondary : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEn ? '+1 Free Coin' : '+1 Koin Gratis',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isMax ? AppColors.textSecondary : const Color(0xFF92400E),
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        isMax
                            ? (isEn ? '3/3 Limit' : '3/3 Maks')
                            : (isEn ? '$claimedToday/3 Today' : '$claimedToday/3 Hari Ini'),
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isMax ? AppColors.textSecondary : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: isMax ? AppColors.textSecondary : const Color(0xFFD97706),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Modal Penjelasan Mekanisme Perolehan Koin dari Nonton Iklan (Maksimal 3 Koin/Hari)
  void _showWatchAdExplanationDialog(BuildContext context, bool isEn) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final bottomInset = MediaQuery.paddingOf(sheetCtx).bottom;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(22, 12, 22, bottomInset + 20),
          child: ValueListenableBuilder<int>(
            valueListenable: CoinService.instance.adCoinsClaimedTodayNotifier,
            builder: (ctx, claimedToday, _) {
              const maxDaily = CoinService.maxDailyAdCoins;
              final remaining = (maxDaily - claimedToday).clamp(0, maxDaily);
              final isQuotaFull = claimedToday >= maxDaily;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderHairline,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header with badge
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: Color(0xFFD97706),
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? 'Get 1 Free Coin' : 'Dapatkan 1 Koin Gratis',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.midnightNavy,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEn
                                  ? 'Watch a video ad to add a coin to your balance'
                                  : 'Tonton iklan video singkat untuk menambah koin',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Info Mechanism Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.subtleSlateTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderHairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'HOW IT WORKS' : 'MEKANISME PEROLEHAN KOIN',
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoBullet(
                          icon: Icons.ondemand_video_rounded,
                          title: isEn ? 'Watch Video Ad' : 'Tonton Iklan Video',
                          desc: isEn
                              ? 'Watch 1 short sponsored video ad until it finishes.'
                              : 'Tonton 1 video iklan berdurasi singkat hingga selesai.',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoBullet(
                          icon: Icons.toll_rounded,
                          title: isEn ? '+1 Coin Reward' : '+1 Koin Gratis Ditambahkan',
                          desc: isEn
                              ? '1 free coin is automatically added to your account balance.'
                              : '1 koin gratis langsung masuk ke saldo akun Anda.',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoBullet(
                          icon: Icons.event_repeat_rounded,
                          title: isEn ? 'Daily Limit: Max 3 Coins' : 'Batas Maksimal 3 Koin / Hari',
                          desc: isEn
                              ? 'You can claim up to 3 coins per day by watching ads. Resets automatically at 00:00 midnight.'
                              : 'Maksimal 3 koin setiap hari melalui tonton iklan. Kuota reset otomatis pukul 00:00 tengah malam.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Quota Progress Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isQuotaFull
                          ? AppColors.crimsonBordeaux.withValues(alpha: 0.05)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isQuotaFull
                            ? AppColors.crimsonBordeauxLight.withValues(alpha: 0.3)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEn ? 'Daily Quota Status' : 'Status Kuota Hari Ini',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isQuotaFull
                                    ? AppColors.crimsonBordeaux
                                    : const Color(0xFF92400E),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isQuotaFull
                                    ? AppColors.crimsonBordeaux
                                    : const Color(0xFFD97706),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$claimedToday / $maxDaily ${isEn ? "Claimed" : "Diklaim"}',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 3 Visual Coin Step Badges
                        Row(
                          children: List.generate(maxDaily, (index) {
                            final isClaimed = index < claimedToday;
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: index < maxDaily - 1 ? 8 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isClaimed
                                      ? const Color(0xFFD1FAE5)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isClaimed
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFFDE68A),
                                    width: isClaimed ? 1.4 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      isClaimed
                                          ? Icons.check_circle_rounded
                                          : Icons.toll_rounded,
                                      size: 16,
                                      color: isClaimed
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFD97706),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${isEn ? "Coin" : "Koin"} ${index + 1}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isClaimed
                                            ? const Color(0xFF065F46)
                                            : const Color(0xFF92400E),
                                      ),
                                    ),
                                    Text(
                                      isClaimed
                                          ? (isEn ? 'Claimed' : 'Selesai')
                                          : (isEn ? 'Available' : 'Tersedia'),
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        color: isClaimed
                                            ? const Color(0xFF059669)
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isQuotaFull
                              ? (isEn
                                  ? 'Daily limit of 3 coins reached. Resets tomorrow at 00:00.'
                                  : 'Batas harian 3 koin telah tercapai. Kuota reset otomatis besok pukul 00:00.')
                              : (isEn
                                  ? '$remaining of 3 chances remaining today.'
                                  : 'Tersisa $remaining dari 3 kesempatan hari ini.'),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: isQuotaFull
                                ? AppColors.crimsonBordeaux
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Action Button
                  if (!isQuotaFull)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        AdService.instance.showAdForCoinReward(context: context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.midnightNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_fill_rounded, size: 18, color: Color(0xFFFDE68A)),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? 'Watch Ad (+1 Coin)' : 'Tonton Iklan (+1 Koin)',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5E7EB),
                        foregroundColor: AppColors.textSecondary,
                        disabledBackgroundColor: const Color(0xFFE5E7EB),
                        disabledForegroundColor: AppColors.textSecondary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? 'Daily Limit Reached (3/3)' : 'Batas Harian Tercapai (3/3)',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      isEn ? 'Close' : 'Tutup',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoBullet({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderHairline),
          ),
          child: Icon(icon, size: 14, color: AppColors.midnightNavy),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.midnightNavy,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
