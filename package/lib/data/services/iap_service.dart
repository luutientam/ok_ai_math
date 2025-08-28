import 'dart:async';
import 'dart:developer' as dev;

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package/core/exceptions/iap_exceptions.dart';
import 'package:package/data/repository/iap_repository_impl.dart';
import 'package:package/domain/repository/iap_repository.dart';

/// Example usage of the improved IAPRepository
class IAPService {
  IAPService({IAPRepository? repository}) : _repository = repository ?? IapRepositoryImpl.create();

  final IAPRepository _repository;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Initialize the IAP service and start listening to purchases
  Future<void> initialize() async {
    try {
      dev.log('Initializing IAP service', name: 'IAPService');

      // Start listening to purchase updates
      _purchaseSubscription = _repository.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          dev.log('Purchase stream error: $error', name: 'IAPService');
        },
      );

      dev.log('IAP service initialized successfully', name: 'IAPService');
    } catch (e) {
      dev.log('Failed to initialize IAP service: $e', name: 'IAPService');
      rethrow;
    }
  }

  /// Handle purchase updates from the stream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      dev.log(
        'Processing purchase: ${purchase.productID} - ${purchase.status}',
        name: 'IAPService',
      );

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          _handleFailedPurchase(purchase);
          break;
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchase);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchase);
          break;
      }
    }
  }

  /// Handle successful purchase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    try {
      // Verify purchase with your backend here
      final isValid = await _verifyPurchase(purchase);

      if (isValid) {
        // Grant the user access to the purchased content
        await _grantPurchaseContent(purchase);

        // Complete the purchase
        await _repository.completePurchase(purchase);

        dev.log('Purchase completed successfully: ${purchase.productID}', name: 'IAPService');
      } else {
        dev.log('Purchase verification failed: ${purchase.productID}', name: 'IAPService');
      }
    } catch (e) {
      dev.log('Error handling successful purchase: $e', name: 'IAPService');
    }
  }

  /// Handle failed purchase
  void _handleFailedPurchase(PurchaseDetails purchase) {
    dev.log('Purchase failed: ${purchase.productID} - ${purchase.error}', name: 'IAPService');
    // Handle failed purchase (show error message to user)
  }

  /// Handle pending purchase
  void _handlePendingPurchase(PurchaseDetails purchase) {
    dev.log('Purchase pending: ${purchase.productID}', name: 'IAPService');
    // Handle pending purchase (show pending message to user)
  }

  /// Handle canceled purchase
  void _handleCanceledPurchase(PurchaseDetails purchase) {
    dev.log('Purchase canceled: ${purchase.productID}', name: 'IAPService');
    // Handle canceled purchase
  }

  /// Buy a premium subscription
  Future<void> buyPremiumSubscription() async {
    try {
      final product = await _repository.getProduct('premium_subscription');
      await _repository.buyNonConsumable(product);
    } on IAPException catch (e) {
      dev.log('Failed to buy premium subscription: $e', name: 'IAPService');
      rethrow;
    }
  }

  /// Buy consumable coins
  Future<void> buyCoins(String coinPackageId) async {
    try {
      final product = await _repository.getProduct(coinPackageId);
      await _repository.buyConsumable(product);
    } on IAPException catch (e) {
      dev.log('Failed to buy coins: $e', name: 'IAPService');
      rethrow;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _repository.restorePurchases();
    } on IAPException catch (e) {
      dev.log('Failed to restore purchases: $e', name: 'IAPService');
      rethrow;
    }
  }

  /// Get available products
  Future<List<ProductDetails>> getAvailableProducts() async {
    try {
      const productIds = ['premium_subscription', 'coins_100', 'coins_500', 'coins_1000'];

      return await _repository.getProducts(productIds);
    } on IAPException catch (e) {
      dev.log('Failed to get available products: $e', name: 'IAPService');
      rethrow;
    }
  }

  /// Verify purchase with backend (mock implementation)
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // In a real app, you would send the purchase token to your backend
    // for verification with Apple/Google servers
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    return true; // Mock verification result
  }

  /// Grant purchase content to user (mock implementation)
  Future<void> _grantPurchaseContent(PurchaseDetails purchase) async {
    // In a real app, you would update the user's account with the purchased content
    dev.log('Granting content for: ${purchase.productID}', name: 'IAPService');
    // Update local database, sync with backend, etc.
  }

  /// Dispose the service
  void dispose() {
    _purchaseSubscription?.cancel();
    _repository.clearCache();
    dev.log('IAP service disposed', name: 'IAPService');
  }
}
