import 'package:package/domain/model/subscription_status.dart';

abstract class FetchSubRepository {
  /// Get current subscription status
  Future<SubscriptionStatus> getSubscriptionStatus();

  /// Check if specific product subscription is active
  Future<bool> isProductActive(String productId);
}
