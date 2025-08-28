import 'dart:io';

import 'package:flutter_ai_math_2/app.dart';

class IAPHelper {
  /// Get IAP BLoC instance from dependency injection
  static IAPBloc getIAPBloc() {
    return package_sl<IAPBloc>();
  }

  /// Get IAP Use Case instance from dependency injection
  static IAPUseCase getIAPUseCase() {
    return package_sl<IAPUseCase>();
  }

  /// Quick check if user has premium access
  static bool hasPremiumAccess() {
    return package_sl<IAPUseCase>().hasPremiumAccess();
  }

  /// Quick get coin balance
  static int getCoinBalance() {
    return package_sl<IAPUseCase>().getCoinBalance();
  }

  /// Get all product IDs
  static List<String> get allProductIds {
    if (Platform.isIOS) {
      return IapIos.allProductIds;
    } else {
      return IapAndroid.allProductIds;
    }
  }
}
