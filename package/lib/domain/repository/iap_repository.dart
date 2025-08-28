import 'package:in_app_purchase/in_app_purchase.dart';

abstract class IAPRepository {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<ProductDetails> getProduct(String id);
  Future<List<ProductDetails>> getProducts(List<String> ids);
  Future<void> buyNonConsumable(ProductDetails product);
  Future<void> buyConsumable(ProductDetails product);
  Future<void> restorePurchases();
  Future<void> completePurchase(PurchaseDetails purchase);

  /// Gets the latest cached purchases
  List<PurchaseDetails> get latestPurchases;

  /// Clears the purchase cache
  void clearCache();
}
