// lib/core/constants/config_ios.dart
// It contains configuration constants for the iOS platform.
class ConfigIos {
  static const String appName = 'Flutter AI Math';
  static const String bundleId = 'com.flutter_ai_math_2.app';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const bool isDebug = true;
}

class IapIos {
  /// Get all product IDs
  static List<String> get allProductIds => [
    'ExampleAd.Billing.Weekly',
    'ExampleAd.Billing.Yearly',
    'ExampleAd.Billing.Lifetime',
  ];
}
