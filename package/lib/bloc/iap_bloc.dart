import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package/core/exceptions/iap_exceptions.dart';
import 'package:package/app_package.dart';

/// BLoC for managing In-App Purchase state and events
///
/// This BLoC handles all IAP-related UI interactions and business logic
/// following the BLoC pattern for state management
class IAPBloc extends Bloc<IAPEvent, IAPState> {
  IAPBloc({required this.iapUseCase, required this.configSubUseCase})
    : super(IAPInitial()) {
    on<IAPInitializeEvent>(_onInitialize);
    on<IAPLoadProductsEvent>(_onLoadProducts);
    on<IAPPurchaseProductEvent>(_onPurchaseProduct);
    on<IAPRestorePurchasesEvent>(_onRestorePurchases);
    on<IAPCompletePurchaseEvent>(_onCompletePurchase);
    on<IAPClearCacheEvent>(_onClearCache);
    on<IAPPurchaseUpdatedEvent>(_onPurchaseUpdated);

    _initializePurchaseStream();
  }

  final IAPUseCase iapUseCase;
  final ConfigSubUseCase configSubUseCase;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Check if a product is consumable based on product ID patterns
  bool _isConsumableProductById(String productId) {
    // Check by product ID patterns (customize based on your product IDs)
    final consumablePatterns = [
      'coin',
      'credit',
      'token',
      'consumable',
      'gems',
      'energy',
      'lives',
      'lifetime',
    ];

    final productIdLower = productId.toLowerCase();

    // Check if product ID contains consumable patterns
    for (final pattern in consumablePatterns) {
      if (productIdLower.contains(pattern)) {
        return true;
      }
    }

    // You can also maintain a hardcoded list of consumable product IDs
    final consumableProductIds = [
      'coins_100',
      'coins_500',
      'coins_1000',
      'gems_50',
      'gems_200',
    ];

    if (consumableProductIds.contains(productId)) {
      return true;
    }

    return false; // Default to non-consumable (premium subscriptions, etc.)
  }

  /// Initialize purchase stream listener
  void _initializePurchaseStream() {
    _purchaseSubscription = iapUseCase.purchaseStream.listen(
      (purchases) {
        add(IAPPurchaseUpdatedEvent(purchases));
      },
      onError: (error) {
        dev.log('Purchase stream error: $error', name: 'IAPBloc');
        // Note: Cannot emit state here, will be handled in error event
      },
    );
  }

  /// Handle initialize event
  Future<void> _onInitialize(
    IAPInitializeEvent event,
    Emitter<IAPState> emit,
  ) async {
    try {
      emit(const IAPLoadingState());

      // Get initial cached purchases
      final cachedPurchases = iapUseCase.latestPurchases;

      emit(
        IAPInitializedState(
          hasPremiumAccess: iapUseCase.hasPremiumAccess(),
          coinBalance: iapUseCase.getCoinBalance(),
          purchases: cachedPurchases,
        ),
      );

      dev.log('IAP initialized successfully', name: 'IAPBloc');
    } catch (e) {
      dev.log('Failed to initialize IAP: $e', name: 'IAPBloc');
      emit(IAPErrorState('Failed to initialize: $e'));
    }
  }

  /// Handle load products event
  Future<void> _onLoadProducts(
    IAPLoadProductsEvent event,
    Emitter<IAPState> emit,
  ) async {
    try {
      emit(const IAPLoadingState());

      final products = await iapUseCase.getProducts(event.productIds);

      // Categorize products based on their titles
      ProductDetails? weeklyProduct;
      ProductDetails? yearlyProduct;
      ProductDetails? monthlyProduct;
      ProductDetails? lifetimeProduct;

      for (final product in products) {
        final title = product.title.toLowerCase();

        dev.log(
          'Loaded product: ${product.id} - ${product.title} (${product.price})',
          name: 'IAPBloc',
        );

        if (title.contains('lifetime')) {
          lifetimeProduct = product;
          dev.log('Found Lifetime product: ${product.title}', name: 'IAPBloc');
        } else if (title.contains('weekly')) {
          weeklyProduct = product;
          dev.log('Found Weekly product: ${product.title}', name: 'IAPBloc');
        } else if (title.contains('yearly')) {
          yearlyProduct = product;
          dev.log('Found Yearly product: ${product.title}', name: 'IAPBloc');
        } else if (title.contains('monthly')) {
          monthlyProduct = product;
          dev.log('Found Monthly product: ${product.title}', name: 'IAPBloc');
        }
      }

      emit(
        IAPProductsLoadedState(
          weekly: weeklyProduct,
          yearly: yearlyProduct,
          monthly: monthlyProduct,
          lifetime: lifetimeProduct,
        ),
      );

      dev.log('Loaded ${products.length} products', name: 'IAPBloc');
    } on IAPException catch (e) {
      dev.log('Failed to load products: $e', name: 'IAPBloc');
      emit(IAPErrorState(e.message));
    } catch (e) {
      dev.log('Unexpected error loading products: $e', name: 'IAPBloc');
      emit(IAPErrorState('Failed to load products: $e'));
    }
  }

  /// Handle purchase product event
  Future<void> _onPurchaseProduct(
    IAPPurchaseProductEvent event,
    Emitter<IAPState> emit,
  ) async {
    try {
      emit(const IAPPurchasingState());

      if (event.isConsumable) {
        await iapUseCase.buyConsumableProduct(event.product);
      } else {
        await iapUseCase.buyPremiumProduct(event.product);
      }

      dev.log('Purchase initiated for: ${event.product.id}', name: 'IAPBloc');

      // Set a timeout to prevent infinite loading
      Timer(const Duration(seconds: 30), () {
        if (state is IAPPurchasingState) {
          emit(const IAPErrorState('Purchase timeout - please try again'));
        }
      });

      // Don't emit success state here, wait for purchase stream update
    } on IAPException catch (e) {
      dev.log('Purchase failed: $e', name: 'IAPBloc');
      emit(IAPErrorState(e.message));
    } catch (e) {
      dev.log('Unexpected purchase error: $e', name: 'IAPBloc');
      emit(IAPErrorState('Purchase failed: $e'));
    }
  }

  /// Handle restore purchases event
  Future<void> _onRestorePurchases(
    IAPRestorePurchasesEvent event,
    Emitter<IAPState> emit,
  ) async {
    try {
      emit(const IAPRestoringState());

      await iapUseCase.restorePurchases();

      dev.log('Restore purchases completed', name: 'IAPBloc');

      // Emit success state immediately after restore completes
      // Even if no purchases are restored, we should show completion
      emit(
        IAPRestoreCompletedState(
          hasPremiumAccess: iapUseCase.hasPremiumAccess(),
          coinBalance: iapUseCase.getCoinBalance(),
          restoredPurchases: iapUseCase.latestPurchases
              .where((p) => p.status == PurchaseStatus.restored)
              .toList(),
        ),
      );
    } on IAPException catch (e) {
      dev.log('Restore failed: $e', name: 'IAPBloc');
      emit(IAPErrorState(e.message));
    } catch (e) {
      dev.log('Unexpected restore error: $e', name: 'IAPBloc');
      emit(IAPErrorState('Restore failed: $e'));
    }
  }

  /// Handle complete purchase event
  Future<void> _onCompletePurchase(
    IAPCompletePurchaseEvent event,
    Emitter<IAPState> emit,
  ) async {
    try {
      await iapUseCase.completePurchase(event.purchase);

      dev.log(
        'Purchase completed: ${event.purchase.productID}',
        name: 'IAPBloc',
      );
      // Update state with new purchase status
      emit(
        IAPPurchaseCompletedState(
          purchase: event.purchase,
          hasPremiumAccess: iapUseCase.hasPremiumAccess(),
          coinBalance: iapUseCase.getCoinBalance(),
        ),
      );
    } on IAPException catch (e) {
      dev.log('Complete purchase failed: $e', name: 'IAPBloc');
      emit(IAPErrorState(e.message));
    } catch (e) {
      dev.log('Unexpected completion error: $e', name: 'IAPBloc');
      emit(IAPErrorState('Failed to complete purchase: $e'));
    }
  }

  /// Handle clear cache event
  Future<void> _onClearCache(
    IAPClearCacheEvent event,
    Emitter<IAPState> emit,
  ) async {
    try {
      iapUseCase.clearCache();

      emit(const IAPInitial());

      dev.log('IAP cache cleared', name: 'IAPBloc');
    } catch (e) {
      dev.log('Failed to clear cache: $e', name: 'IAPBloc');
      emit(IAPErrorState('Failed to clear cache: $e'));
    }
  }

  /// Handle purchase updated event from stream
  Future<void> _onPurchaseUpdated(
    IAPPurchaseUpdatedEvent event,
    Emitter<IAPState> emit,
  ) async {
    try {
      final purchases = event.purchases;
      print('Purchase stream updated with ${purchases.length} purchases');

      bool hasProcessedPurchases = false;
      List<PurchaseDetails> processedPurchases = [];

      // Process each purchase
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          // Handle NEW purchases
          try {
            final isConsumable = _isConsumableProductById(purchase.productID);
            var config = await configSubUseCase.select();

            if (!isConsumable) {
              await configSubUseCase.update(config.copyWith(isSub: true));
              dev.log(
                'Updated subscription status for: ${purchase.productID}',
                name: 'IAPBloc',
              );
            } else {
              await configSubUseCase.update(config.copyWith(isLifetime: true));
              dev.log(
                'Updated lifetime status for: ${purchase.productID}',
                name: 'IAPBloc',
              );
            }

            // Complete the purchase
            await iapUseCase.completePurchase(purchase);
            dev.log(
              'Completed purchase: ${purchase.productID}',
              name: 'IAPBloc',
            );

            processedPurchases.add(purchase);
            hasProcessedPurchases = true;
          } catch (e) {
            dev.log(
              'Failed to process purchase ${purchase.productID}: $e',
              name: 'IAPBloc',
            );
          }
        } else if (purchase.status == PurchaseStatus.restored) {
          // Handle RESTORED purchases
          try {
            final isConsumable = _isConsumableProductById(purchase.productID);
            var config = await configSubUseCase.select();

            if (!isConsumable) {
              await configSubUseCase.update(config.copyWith(isSub: true));
              dev.log(
                'Restored subscription: ${purchase.productID}',
                name: 'IAPBloc',
              );
            } else {
              await configSubUseCase.update(config.copyWith(isLifetime: true));
              dev.log(
                'Restored lifetime purchase: ${purchase.productID}',
                name: 'IAPBloc',
              );
            }

            // NOTE: NO completePurchase() for restored purchases
            processedPurchases.add(purchase);
            hasProcessedPurchases = true;
          } catch (e) {
            dev.log(
              'Failed to process restored purchase ${purchase.productID}: $e',
              name: 'IAPBloc',
            );
          }
        } else if (purchase.status == PurchaseStatus.error) {
          dev.log(
            'Purchase error for ${purchase.productID}: ${purchase.error}',
            name: 'IAPBloc',
          );
        } else if (purchase.status == PurchaseStatus.pending) {
          dev.log(
            'Purchase pending for ${purchase.productID}',
            name: 'IAPBloc',
          );
        }
      }

      // Emit state ONCE after processing all purchases
      if (hasProcessedPurchases || purchases.isNotEmpty) {
        emit(
          IAPPurchasesUpdatedState(
            purchases: purchases,
            hasPremiumAccess: iapUseCase.hasPremiumAccess(),
            coinBalance: iapUseCase.getCoinBalance(),
            pendingPurchases: iapUseCase.getPendingPurchases(),
            failedPurchases: iapUseCase.getFailedPurchases(),
          ),
        );

        dev.log(
          'Purchase state updated: ${processedPurchases.length} processed, ${purchases.length} total',
          name: 'IAPBloc',
        );
      }
    } catch (e) {
      dev.log('Failed to process purchase updates: $e', name: 'IAPBloc');
      emit(IAPErrorState('Failed to process purchases: $e'));
    }
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    return super.close();
  }
}
