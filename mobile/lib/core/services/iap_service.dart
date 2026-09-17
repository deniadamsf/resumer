import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Service: IapService
/// Menangani komunikasi dengan Google Play Billing & Apple App Store IAP.
/// Dirancang modular sesuai standar Clean Architecture GEMINI.md.
class IapService {
  static final IapService instance = IapService._internal();

  IapService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final ValueNotifier<bool> isAvailableNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPurchasingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<List<ProductDetails>> productsNotifier =
      ValueNotifier<List<ProductDetails>>([]);
  final ValueNotifier<String?> purchaseErrorNotifier =
      ValueNotifier<String?>(null);

  bool get isAvailable => isAvailableNotifier.value;
  bool get isPurchasing => isPurchasingNotifier.value;
  List<ProductDetails> get products => productsNotifier.value;

  /// Inisialisasi pendengar stream pembelian Google Play Billing
  Future<void> init() async {
    debugPrint('IapService: Initializing In-App Purchase...');
    try {
      final available = await _iap.isAvailable();
      isAvailableNotifier.value = available;
      debugPrint('IapService: Google Play Billing available: $available');

      if (!available) {
        debugPrint('IapService: Store is not available on this device/environment.');
        return;
      }

      // Dengarkan update transaksi pembelian secara live
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onDone: () {
          debugPrint('IapService: purchaseStream done');
          _subscription?.cancel();
        },
        onError: (error) {
          debugPrint('IapService: purchaseStream error: $error');
          purchaseErrorNotifier.value = error.toString();
        },
      );
    } catch (e, stack) {
      debugPrint('IapService: Error initializing IAP: $e\n$stack');
    }
  }

  /// Memuat daftar produk dari Play Console berdasarkan Product ID
  Future<List<ProductDetails>> loadProducts(Set<String> productIds) async {
    if (!isAvailableNotifier.value) {
      debugPrint('IapService: Cannot load products, store not available');
      return [];
    }

    try {
      debugPrint('IapService: Querying product details for: $productIds');
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('IapService: queryProductDetails error: ${response.error}');
        purchaseErrorNotifier.value = response.error!.message;
        return [];
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IapService: Products not found in store: ${response.notFoundIDs}');
      }

      productsNotifier.value = response.productDetails;
      debugPrint('IapService: Loaded ${response.productDetails.length} products');
      return response.productDetails;
    } catch (e) {
      debugPrint('IapService: Failed to query products: $e');
      return [];
    }
  }

  /// Memulai proses pembelian produk atau langganan
  Future<bool> buyProduct(
    ProductDetails product, {
    bool isConsumable = false,
  }) async {
    if (!isAvailableNotifier.value) {
      debugPrint('IapService: Cannot buy, store not available');
      return false;
    }

    isPurchasingNotifier.value = true;
    purchaseErrorNotifier.value = null;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      if (isConsumable) {
        return await _iap.buyConsumable(
          purchaseParam: purchaseParam,
          autoConsume: true,
        );
      } else {
        return await _iap.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      }
    } catch (e) {
      debugPrint('IapService: Buy request exception: $e');
      isPurchasingNotifier.value = false;
      purchaseErrorNotifier.value = e.toString();
      return false;
    }
  }

  /// Memulihkan transaksi pembelian sebelumnya (Restore Purchases)
  Future<void> restorePurchases() async {
    if (!isAvailableNotifier.value) return;
    try {
      debugPrint('IapService: Restoring past purchases...');
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IapService: Restore purchases error: $e');
    }
  }

  /// Menangani update status pembelian yang masuk dari stream Google Play
  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      debugPrint(
        'IapService: Purchase update: ${purchase.productID} -> status: ${purchase.status}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          isPurchasingNotifier.value = true;
          break;

        case PurchaseStatus.error:
          isPurchasingNotifier.value = false;
          purchaseErrorNotifier.value = purchase.error?.message ?? 'Purchase error';
          debugPrint('IapService: Purchase error: ${purchase.error}');
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isPurchasingNotifier.value = false;
          purchaseErrorNotifier.value = null;
          // Verifikasi dan konsumsi/selesaikan transaksi
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
            debugPrint('IapService: Completed purchase for ${purchase.productID}');
          }
          break;

        case PurchaseStatus.canceled:
          isPurchasingNotifier.value = false;
          debugPrint('IapService: Purchase canceled by user');
          break;
      }
    }
  }

  /// Membersihkan subscription saat service tidak lagi digunakan
  void dispose() {
    _subscription?.cancel();
    isAvailableNotifier.dispose();
    isPurchasingNotifier.dispose();
    productsNotifier.dispose();
    purchaseErrorNotifier.dispose();
  }
}
