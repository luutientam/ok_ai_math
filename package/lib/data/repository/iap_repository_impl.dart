import 'dart:developer' as dev;

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package/core/exceptions/iap_exceptions.dart';
import 'package:package/domain/repository/iap_repository.dart';

/// Implementation of [IAPRepository] using the in_app_purchase package
///
/// This class handles all In-App Purchase operations including:
/// - Product queries
/// - Purchase transactions (consumable and non-consumable)
/// - Purchase restoration
/// - Purchase completion
class IapRepositoryImpl implements IAPRepository {
  /// Creates an instance of [IapRepositoryImpl]
  ///
  /// [iap] The InAppPurchase instance to use for IAP operations
  IapRepositoryImpl({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  List<PurchaseDetails> _latestPurchases = [];

  /// Factory constructor for creating an instance with default InAppPurchase
  factory IapRepositoryImpl.create() {
    return IapRepositoryImpl(iap: InAppPurchase.instance);
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream {
    dev.log('Setting up purchase stream listener', name: 'IapRepository');
    return _iap.purchaseStream.map((purchases) {
      dev.log('Received ${purchases.length} purchases', name: 'IapRepository');
      _latestPurchases = purchases;
      return purchases;
    });
  }

  @override
  Future<ProductDetails> getProduct(String id) async {
    if (id.trim().isEmpty) {
      throw const ProductNotFoundException('Product ID cannot be empty');
    }

    try {
      dev.log('Querying product details for: $id', name: 'IapRepository');

      // Check if IAP is available
      final isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        throw const IAPServiceUnavailableException();
      }

      final response = await _iap.queryProductDetails({id});

      if (response.notFoundIDs.isNotEmpty) {
        dev.log('Product not found: $id', name: 'IapRepository');
        throw ProductNotFoundException(id);
      }

      if (response.productDetails.isEmpty) {
        throw ProductNotFoundException(id);
      }

      dev.log(
        'Successfully retrieved product: ${response.productDetails.first.id}',
        name: 'IapRepository',
      );
      return response.productDetails.first;
    } catch (e) {
      dev.log('Error getting product $id: $e', name: 'IapRepository');
      if (e is IAPException) rethrow;
      throw ProductNotFoundException(id);
    }
  }

  @override
  Future<List<ProductDetails>> getProducts(List<String> ids) async {
    if (ids.isEmpty) {
      dev.log('Product IDs list is empty', name: 'IapRepository');
      return [];
    }

    // Validate all IDs
    final validIds = ids.where((id) => id.trim().isNotEmpty).toList();
    if (validIds.isEmpty) {
      throw const ProductNotFoundException('All product IDs are empty');
    }

    try {
      dev.log('Querying product details for: ${validIds.join(', ')}', name: 'IapRepository');

      // Check if IAP is available
      final isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        throw const IAPServiceUnavailableException();
      }

      final response = await _iap.queryProductDetails(validIds.toSet());

      dev.log(
        'Successfully retrieved ${response.productDetails.length} products',
        name: 'IapRepository',
      );

      if (response.notFoundIDs.isNotEmpty) {
        dev.log(
          'Some products not found: ${response.notFoundIDs.join(', ')}',
          name: 'IapRepository',
        );
      }

      return response.productDetails;
    } catch (e) {
      dev.log('Error getting products ${validIds.join(', ')}: $e', name: 'IapRepository');
      if (e is IAPException) rethrow;
      throw ProductNotFoundException('Failed to get products: ${validIds.join(', ')}');
    }
  }

  @override
  Future<void> buyNonConsumable(ProductDetails product) async {
    try {
      dev.log('Starting non-consumable purchase: ${product.id}', name: 'IapRepository');

      // Check if IAP is available
      final isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        throw const IAPServiceUnavailableException();
      }

      final purchaseParam = PurchaseParam(productDetails: product);
      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      if (!result) {
        throw PurchaseFailedException('Failed to initiate purchase for ${product.id}');
      }

      dev.log('Non-consumable purchase initiated: ${product.id}', name: 'IapRepository');
    } catch (e) {
      dev.log('Error buying non-consumable ${product.id}: $e', name: 'IapRepository');
      if (e is IAPException) rethrow;
      throw PurchaseFailedException('Purchase failed for ${product.id}: $e');
    }
  }

  @override
  Future<void> buyConsumable(ProductDetails product) async {
    try {
      dev.log('Starting consumable purchase: ${product.id}', name: 'IapRepository');

      // Check if IAP is available
      final isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        throw const IAPServiceUnavailableException();
      }

      final purchaseParam = PurchaseParam(productDetails: product);
      final result = await _iap.buyConsumable(purchaseParam: purchaseParam);

      if (!result) {
        throw PurchaseFailedException('Failed to initiate purchase for ${product.id}');
      }

      dev.log('Consumable purchase initiated: ${product.id}', name: 'IapRepository');
    } catch (e) {
      dev.log('Error buying consumable ${product.id}: $e', name: 'IapRepository');
      if (e is IAPException) rethrow;
      throw PurchaseFailedException('Purchase failed for ${product.id}: $e');
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      dev.log('Starting restore purchases', name: 'IapRepository');

      // Check if IAP is available
      final isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        throw const IAPServiceUnavailableException();
      }

      await _iap.restorePurchases();

      dev.log('Restore purchases completed', name: 'IapRepository');
    } catch (e) {
      dev.log('Error restoring purchases: $e', name: 'IapRepository');
      if (e is IAPException) rethrow;
      throw RestorePurchasesFailedException('Restore failed: $e');
    }
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    try {
      dev.log(
        'Completing purchase: ${purchase.productID} with status: ${purchase.status}',
        name: 'IapRepository',
      );

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _iap.completePurchase(purchase);
        dev.log('Purchase completed successfully: ${purchase.productID}', name: 'IapRepository');
      } else {
        final errorMessage = 'Cannot complete purchase with status: ${purchase.status}';
        dev.log(errorMessage, name: 'IapRepository');
        throw PurchaseCompletionException(purchase.status.toString());
      }
    } catch (e) {
      dev.log('Error completing purchase ${purchase.productID}: $e', name: 'IapRepository');
      if (e is IAPException) rethrow;
      throw PurchaseCompletionException('Completion failed: $e');
    }
  }

  /// Gets the latest purchases from the cache
  ///
  /// This is useful for getting the current state without listening to the stream
  @override
  List<PurchaseDetails> get latestPurchases => List.unmodifiable(_latestPurchases);

  /// Clears the cached purchases
  ///
  /// This should be called when the user logs out or when appropriate
  @override
  void clearCache() {
    dev.log('Clearing purchase cache', name: 'IapRepository');
    _latestPurchases.clear();
  }
}
