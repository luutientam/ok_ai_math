import 'package:package/domain/model/subscription_status.dart';

abstract class FetchSubDataSource {
  /// Fetch subscription status from iOS native receipt verification
  Future<SubscriptionStatus> fetchSubscriptionStatus();

  /// Check if subscription is active for specific product
  Future<bool> isSubscriptionActive(String productId);
}
