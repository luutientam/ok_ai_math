import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Base class for all IAP states
abstract class IAPState extends Equatable {
  const IAPState();

  @override
  List<Object?> get props => [];
}

/// Initial state before IAP is initialized
class IAPInitial extends IAPState {
  const IAPInitial();
}

/// Loading state for various IAP operations
class IAPLoadingState extends IAPState {
  const IAPLoadingState();
}

/// State when IAP is successfully initialized
class IAPInitializedState extends IAPState {
  const IAPInitializedState({
    required this.hasPremiumAccess,
    required this.coinBalance,
    required this.purchases,
  });

  final bool hasPremiumAccess;
  final int coinBalance;
  final List<PurchaseDetails> purchases;

  @override
  List<Object?> get props => [hasPremiumAccess, coinBalance, purchases];
}

/// State when products are loaded
class IAPProductsLoadedState extends IAPState {
  const IAPProductsLoadedState({
    this.weekly,
    this.yearly,
    this.monthly,
    this.lifetime,
  });

  final ProductDetails? weekly;
  final ProductDetails? yearly;
  final ProductDetails? monthly;
  final ProductDetails? lifetime;

  @override
  List<Object?> get props => [weekly, yearly, monthly, lifetime];
}

/// State when a purchase is in progress
class IAPPurchasingState extends IAPState {
  const IAPPurchasingState();
}

/// State when restoring purchases
class IAPRestoringState extends IAPState {
  const IAPRestoringState();
}

/// State when a purchase is completed
class IAPPurchaseCompletedState extends IAPState {
  const IAPPurchaseCompletedState({
    required this.purchase,
    required this.hasPremiumAccess,
    required this.coinBalance,
  });

  final PurchaseDetails purchase;
  final bool hasPremiumAccess;
  final int coinBalance;

  @override
  List<Object?> get props => [purchase, hasPremiumAccess, coinBalance];
}

/// State when purchases are updated from stream
class IAPPurchasesUpdatedState extends IAPState {
  const IAPPurchasesUpdatedState({
    required this.purchases,
    required this.hasPremiumAccess,
    required this.coinBalance,
    required this.pendingPurchases,
    required this.failedPurchases,
  });

  final List<PurchaseDetails> purchases;
  final bool hasPremiumAccess;
  final int coinBalance;
  final List<PurchaseDetails> pendingPurchases;
  final List<PurchaseDetails> failedPurchases;

  @override
  List<Object?> get props => [
    purchases,
    hasPremiumAccess,
    coinBalance,
    pendingPurchases,
    failedPurchases,
  ];
}

/// State when restore purchases is completed
class IAPRestoreCompletedState extends IAPState {
  const IAPRestoreCompletedState({
    required this.hasPremiumAccess,
    required this.coinBalance,
    required this.restoredPurchases,
  });

  final bool hasPremiumAccess;
  final int coinBalance;
  final List<PurchaseDetails> restoredPurchases;

  @override
  List<Object?> get props => [hasPremiumAccess, coinBalance, restoredPurchases];
}

/// Error state for IAP operations
class IAPErrorState extends IAPState {
  const IAPErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
