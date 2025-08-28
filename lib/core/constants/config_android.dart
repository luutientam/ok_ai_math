// lib/core/constants/config_android.dart
// This file contains Android-specific configuration constants for the Flutter AI Math application.
class ConfigAndroid {
  static const String appName = "Flutter AI Math";

  static const String emailFeedback = "feedback@flutteraimath.com";
  static const String bodyFeedback = "Please provide your feedback here.";

  // terms of use and privacy policy URLs
  static const String termsOfUse = "https://flutteraimath.com/terms-of-use";
  static const String privacyPolicy = "https://flutteraimath.com/privacy-policy";

  //
}

class IapAndroid {
  /// Get all product IDs
  static List<String> get allProductIds => [
    'premium.lifetime',
    'premium.yearly',
    'premium.weekly',
  ];

  /// Common product IDs - can be customized based on your app
  static const String premiumLifetime = 'premium.lifetime';
  static const String premiumYearly = 'premium.yearly';
  static const String premiumWeekly = 'premium.weekly';

  /// Get premium product IDs only
  static List<String> get premiumProductIds => [
    premiumLifetime,
    premiumYearly,
    premiumWeekly,
  ];
}