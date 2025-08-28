# IAP (In-App Purchase) Module Documentation

## Tổng quan

Module IAP được xây dựng theo Clean Architecture với các layer:

- **Presentation**: BLoC cho state management
- **Domain**: Use cases và repository interface
- **Data**: Repository implementation và data sources
- **Core**: Exceptions, DI, và helpers

## Cấu trúc thư mục

```
lib/
├── core/
│   ├── exceptions/
│   │   └── iap_exceptions.dart          # Custom exceptions
│   ├── package_di/
│   │   └── package_di.dart              # Dependency injection
│   └── iap_helper.dart                  # Helper cho main app
├── domain/
│   ├── repository/
│   │   └── iap_repository.dart          # Repository interface
│   └── usecases/
│       └── iap_use_case.dart            # Business logic
├── data/
│   ├── repository/
│   │   └── iap_repository_impl.dart     # Repository implementation
│   └── services/
│       └── iap_service.dart             # Example service
├── bloc/
│   ├── iap_bloc.dart                    # BLoC cho state management
│   ├── iap_event.dart                   # IAP events
│   └── iap_state.dart                   # IAP states
└── presentation/
    └── pages/
        └── iap_example_page.dart        # Example usage
```

## Cách sử dụng

### 1. Khởi tạo Dependencies

```dart
// Trong main app, khởi tạo package dependencies
await initSub();
```

### 2. Sử dụng trong Widget

```dart
// Sử dụng BlocProvider
BlocProvider(
  create: (context) => IAPHelper.getIAPBloc()
    ..add(const IAPInitializeEvent())
    ..add(IAPLoadProductsEvent(IAPHelper.allProductIds)),
  child: YourWidget(),
)
```

### 3. Lắng nghe State Changes

```dart
BlocConsumer<IAPBloc, IAPState>(
  listener: (context, state) {
    if (state is IAPErrorState) {
      // Handle error
    } else if (state is IAPPurchaseCompletedState) {
      // Handle successful purchase
    }
  },
  builder: (context, state) {
    return YourUI();
  },
)
```

### 4. Thực hiện Purchase

```dart
// Purchase premium product
context.read<IAPBloc>().add(
  IAPPurchaseProductEvent(
    product: productDetails,
    isConsumable: false, // true for coins, false for premium
  ),
);
```

### 5. Kiểm tra Premium Status

```dart
// Quick check without BLoC
final hasPremium = IAPHelper.hasPremiumAccess();
final coinBalance = IAPHelper.getCoinBalance();
```

## Product IDs Configuration

Cập nhật product IDs trong `IAPHelper`:

```dart
static const String premiumSubscription = 'your_premium_subscription_id';
static const String premiumLifetime = 'your_premium_lifetime_id';
static const String coins100 = 'your_coins_100_id';
// ... thêm product IDs khác
```

## Events Available

- `IAPInitializeEvent`: Khởi tạo IAP system
- `IAPLoadProductsEvent`: Load danh sách products
- `IAPPurchaseProductEvent`: Mua sản phẩm
- `IAPRestorePurchasesEvent`: Restore purchases
- `IAPCompletePurchaseEvent`: Complete purchase manually
- `IAPClearCacheEvent`: Clear cache

## States Available

- `IAPInitial`: Initial state
- `IAPLoadingState`: Loading operations
- `IAPInitializedState`: Successfully initialized
- `IAPProductsLoadedState`: Products loaded
- `IAPPurchasingState`: Purchase in progress
- `IAPPurchaseCompletedState`: Purchase completed
- `IAPPurchasesUpdatedState`: Purchases updated from stream
- `IAPErrorState`: Error occurred

## Error Handling

Module sử dụng custom exceptions:

- `ProductNotFoundException`: Product không tìm thấy
- `PurchaseFailedException`: Purchase thất bại
- `IAPServiceUnavailableException`: IAP service không khả dụng
- `PurchaseCompletionException`: Không thể complete purchase
- `RestorePurchasesFailedException`: Restore thất bại

## Testing

```dart
// Mock repository cho testing
final mockRepo = MockIAPRepository();
final useCase = IAPUseCase(repository: mockRepo);
final bloc = IAPBloc(iapUseCase: useCase);
```

## Best Practices

1. **Luôn check IAP availability** trước khi thực hiện operations
2. **Verify purchases** với backend trước khi grant content
3. **Handle all purchase states** properly (pending, failed, etc.)
4. **Implement proper error handling** cho user experience tốt
5. **Clear cache** khi user logout
6. **Test thoroughly** trên cả iOS và Android

## Integration với Main App

1. Add dependency vào `pubspec.yaml`:

```yaml
dependencies:
  package:
    path: ./package
```

2. Initialize trong `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSub(); // Initialize package dependencies
  runApp(MyApp());
}
```

3. Sử dụng trong app:

```dart
// Trong any widget
final iapBloc = IAPHelper.getIAPBloc();
final hasPremium = IAPHelper.hasPremiumAccess();
```
