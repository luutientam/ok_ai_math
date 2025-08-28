import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package/data/network/datasource/fetch_sub_data_source.dart';
import 'package:package/domain/model/receipt_info.dart';
import 'package:package/domain/model/subscription_status.dart';

class FetchSubDataSourceImpl implements FetchSubDataSource {
  static const MethodChannel _channel = MethodChannel('com.yourapp.receipt');

  @override
  Future<SubscriptionStatus> fetchSubscriptionStatus() async {
    try {
      if (Platform.isIOS) {
        final result = await _channel.invokeMethod('verifyReceipt');
        if (result is String) {
          return _parseReceiptResult(result);
        } else {
          return SubscriptionStatus.error('Invalid receipt data format');
        }
      } else {
        // For non-iOS platforms, return default status
        return SubscriptionStatus.error('Platform not supported');
      }
    } catch (e) {
      return SubscriptionStatus.error('iOS verifyReceipt error: $e');
    }
  }

  @override
  Future<bool> isSubscriptionActive(String productId) async {
    try {
      final status = await fetchSubscriptionStatus();
      return status.isActive && (status.activeProductId == productId || status.hasLifetime);
    } catch (e) {
      return false;
    }
  }

  SubscriptionStatus _parseReceiptResult(String jsonString) {
    try {
      final jsonMap = jsonDecode(jsonString);

      // Check for lifetime subscription first
      final inAppList = (jsonMap['receipt']?['in_app'] as List<dynamic>? ?? []);
      final hasLifetime = inAppList.any(
        (e) => (e as Map<String, dynamic>)['product_id'] == 'test.lifetime',
      );

      if (hasLifetime) {
        return SubscriptionStatus.active(productId: 'test.lifetime', hasLifetime: true);
      }

      // Check for active subscriptions
      final list = (jsonMap['latest_receipt_info'] as List<dynamic>? ?? [])
          .map((e) => ReceiptInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      final now = DateTime.now().millisecondsSinceEpoch;

      for (final info in list) {
        if (info.expiresDateMs > now) {
          return SubscriptionStatus.active(
            productId: info.productId,
            expiryDate: DateTime.fromMillisecondsSinceEpoch(info.expiresDateMs),
          );
        }
      }

      // If we get here, subscription is expired or not found
      final lastProductId = list.isNotEmpty ? list.last.productId : null;
      return SubscriptionStatus.expired(productId: lastProductId);
    } catch (e) {
      return SubscriptionStatus.error('Parse receipt error: $e');
    }
  }
}
