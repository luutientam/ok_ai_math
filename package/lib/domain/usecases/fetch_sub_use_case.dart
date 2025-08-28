import 'package:package/domain/model/subscription_status.dart';
import 'package:package/domain/repository/fetch_sub_repository.dart';

class FetchSubUseCase {
  final FetchSubRepository fetchSubRepository;

  FetchSubUseCase({required this.fetchSubRepository});

  /// Get current subscription status from iOS receipt verification
  Future<SubscriptionStatus> execute() async {
    return await fetchSubRepository.getSubscriptionStatus();
  }

  /// Check if specific product is active
  Future<bool> isProductActive(String productId) async {
    return await fetchSubRepository.isProductActive(productId);
  }

  /// Check if any subscription is active (including lifetime)
  Future<bool> hasActiveSubscription() async {
    final status = await execute();
    return status.isActive;
  }
}
