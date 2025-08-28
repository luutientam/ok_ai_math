import 'package:equatable/equatable.dart';

/// Base exception for IAP operations
abstract class IAPException extends Equatable implements Exception {
  const IAPException(this.message);

  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

/// Exception thrown when a product is not found
class ProductNotFoundException extends IAPException {
  const ProductNotFoundException(String productId) : super('Product not found: $productId');

  final String productId = '';

  @override
  List<Object> get props => [productId];
}

/// Exception thrown when purchase cannot be completed
class PurchaseCompletionException extends IAPException {
  const PurchaseCompletionException(this.status)
    : super('Cannot complete purchase with status: $status');

  final String status;

  @override
  List<Object> get props => [status];
}

/// Exception thrown when IAP service is not available
class IAPServiceUnavailableException extends IAPException {
  const IAPServiceUnavailableException() : super('In-App Purchase service is not available');
}

/// Exception thrown when purchase fails
class PurchaseFailedException extends IAPException {
  const PurchaseFailedException(String reason) : super('Purchase failed: $reason');
}

/// Exception thrown when restore purchases fails
class RestorePurchasesFailedException extends IAPException {
  const RestorePurchasesFailedException(String reason) : super('Restore purchases failed: $reason');
}
