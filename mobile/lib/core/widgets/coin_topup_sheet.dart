import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../constants/colors.dart';
import '../localization/app_localizations.dart';
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

          // Header Title & Current Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                ],
              ),
              // Current Coins Pill
              ValueListenableBuilder<int>(
                valueListenable: CoinService.instance.coinsNotifier,
                builder: (context, balance, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
}
