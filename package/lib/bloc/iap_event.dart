import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Base class for all IAP events
abstract class IAPEvent extends Equatable {
  const IAPEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize IAP system
class IAPInitializeEvent extends IAPEvent {
  const IAPInitializeEvent();
}

/// Event to load product details
class IAPLoadProductsEvent extends IAPEvent {
  const IAPLoadProductsEvent(this.productIds);

  final List<String> productIds;

  @override
  List<Object?> get props => [productIds];
}

/// Event to purchase a product
class IAPPurchaseProductEvent extends IAPEvent {
  const IAPPurchaseProductEvent({required this.product, required this.isConsumable});

  final ProductDetails product;
  final bool isConsumable;

  @override
  List<Object?> get props => [product, isConsumable];
}

/// Event to restore previous purchases
class IAPRestorePurchasesEvent extends IAPEvent {
  const IAPRestorePurchasesEvent();
}

/// Event to complete a purchase
class IAPCompletePurchaseEvent extends IAPEvent {
  const IAPCompletePurchaseEvent(this.purchase);

  final PurchaseDetails purchase;

  @override
  List<Object?> get props => [purchase];
}

/// Event to clear purchase cache
class IAPClearCacheEvent extends IAPEvent {
  const IAPClearCacheEvent();
}

/// Event when purchases are updated from stream
class IAPPurchaseUpdatedEvent extends IAPEvent {
  const IAPPurchaseUpdatedEvent(this.purchases);

  final List<PurchaseDetails> purchases;

  @override
  List<Object?> get props => [purchases];
}
