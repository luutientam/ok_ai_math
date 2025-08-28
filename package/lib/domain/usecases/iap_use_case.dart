import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package/core/exceptions/iap_exceptions.dart';
import 'package:package/domain/repository/iap_repository.dart';

/// Use case for handling In-App Purchase operations
///
/// This class encapsulates all business logic related to IAP operations
/// following Clean Architecture principles
class IAPUseCase {
  const IAPUseCase({required IAPRepository repository}) : _repository = repository;

  final IAPRepository _repository;

  /// Get purchase stream for listening to purchase updates
  Stream<List<PurchaseDetails>> get purchaseStream => _repository.purchaseStream;

  /// Get cached purchases without listening to stream
  List<PurchaseDetails> get latestPurchases => _repository.latestPurchases;

  /// Get product details by ID
  ///
  /// Throws [ProductNotFoundException] if product is not found
  /// Throws [IAPServiceUnavailableException] if IAP service is not available
  Future<ProductDetails> getProduct(String productId) async {
    if (productId.trim().isEmpty) {
      throw const ProductNotFoundException('Product ID cannot be empty');
    }

    return await _repository.getProduct(productId);
  }

  /// Get multiple product details by IDs
  ///
  /// Returns empty list if no product IDs provided
  /// Throws [ProductNotFoundException] if all IDs are invalid
  /// Throws [IAPServiceUnavailableException] if IAP service is not available
  Future<List<ProductDetails>> getProducts(List<String> productIds) async {
    return await _repository.getProducts(productIds);
  }

  /// Purchase a non-consumable product (like premium subscription)
  ///
  /// Throws [PurchaseFailedException] if purchase fails
  /// Throws [IAPServiceUnavailableException] if IAP service is not available
  Future<void> buyPremiumProduct(ProductDetails product) async {
    return await _repository.buyNonConsumable(product);
  }

  /// Purchase a consumable product (like coins, gems)
  ///
  /// Throws [PurchaseFailedException] if purchase fails
  /// Throws [IAPServiceUnavailableException] if IAP service is not available
  Future<void> buyConsumableProduct(ProductDetails product) async {
    return await _repository.buyConsumable(product);
  }

  /// Restore previous purchases
  ///
  /// This is important for non-consumable products when user reinstalls app
  /// or switches devices
  ///
  /// Throws [RestorePurchasesFailedException] if restore fails
  /// Throws [IAPServiceUnavailableException] if IAP service is not available
  Future<void> restorePurchases() async {
    return await _repository.restorePurchases();
  }

  /// Complete a purchase transaction
  ///
  /// This should be called after successful purchase verification
  ///
  /// Throws [PurchaseCompletionException] if completion fails
  Future<void> completePurchase(PurchaseDetails purchase) async {
    return await _repository.completePurchase(purchase);
  }

  /// Check if a specific product has been purchased
  ///
  /// This checks the cached purchases for the given product ID
  bool isProductPurchased(String productId) {
    return _repository.latestPurchases.any(
      (purchase) =>
          purchase.productID == productId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored),
    );
  }

  /// Get all successfully purchased products
  ///
  /// Returns list of product IDs that have been purchased or restored
  List<String> getPurchasedProducts() {
    return _repository.latestPurchases
        .where(
          (purchase) =>
              purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored,
        )
        .map((purchase) => purchase.productID)
        .toList();
  }

  /// Get pending purchases
  ///
  /// Returns list of purchases that are still pending
  List<PurchaseDetails> getPendingPurchases() {
    return _repository.latestPurchases
        .where((purchase) => purchase.status == PurchaseStatus.pending)
        .toList();
  }

  /// Get failed purchases
  ///
  /// Returns list of purchases that have failed
  List<PurchaseDetails> getFailedPurchases() {
    return _repository.latestPurchases
        .where((purchase) => purchase.status == PurchaseStatus.error)
        .toList();
  }

  /// Clear purchase cache
  ///
  /// This should be called when user logs out or when appropriate
  void clearCache() {
    _repository.clearCache();
  }

  /// Business logic: Check if user has premium access
  ///
  /// This is an example of business logic that can be in use case
  bool hasPremiumAccess() {
    const premiumProductIds = [
      'premium_subscription',
      'premium_lifetime',
      'premium_monthly',
      'premium_yearly',
    ];

    return premiumProductIds.any((productId) => isProductPurchased(productId));
  }

  /// Business logic: Get user's coin balance
  ///
  /// This would typically be combined with backend data
  /// This is just an example of how business logic can be handled
  int getCoinBalance() {
    // In real app, this would be stored in local database or backend
    // This is just a mock implementation
    final coinPurchases = _repository.latestPurchases
        .where(
          (purchase) =>
              purchase.productID.startsWith('coins_') &&
              (purchase.status == PurchaseStatus.purchased ||
                  purchase.status == PurchaseStatus.restored),
        )
        .toList();

    int totalCoins = 0;
    for (final purchase in coinPurchases) {
      // Extract coin amount from product ID (e.g., "coins_100" -> 100)
      final coinAmount = int.tryParse(purchase.productID.replaceAll('coins_', '')) ?? 0;
      totalCoins += coinAmount;
    }

    return totalCoins;
  }
}
