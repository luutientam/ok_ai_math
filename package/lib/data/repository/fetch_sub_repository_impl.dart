import 'package:package/data/network/datasource/fetch_sub_data_source.dart';
import 'package:package/domain/model/subscription_status.dart';
import 'package:package/domain/repository/fetch_sub_repository.dart';

class FetchSubRepositoryImpl implements FetchSubRepository {
  final FetchSubDataSource fetchSubDataSource;

  FetchSubRepositoryImpl({required this.fetchSubDataSource});

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      return await fetchSubDataSource.fetchSubscriptionStatus();
    } catch (e) {
      return SubscriptionStatus.error('Repository error: $e');
    }
  }

  @override
  Future<bool> isProductActive(String productId) async {
    try {
      return await fetchSubDataSource.isSubscriptionActive(productId);
    } catch (e) {
      return false;
    }
  }
}
