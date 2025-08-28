import 'package:get_it/get_it.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package/bloc/config_sub_bloc.dart';
import 'package:package/bloc/iap_bloc.dart';
import 'package:package/data/local/datasource/config_sub_data_source.dart';
import 'package:package/data/local/datasource/config_sub_data_source_impl.dart';
import 'package:package/data/local/sub_database.dart';
import 'package:package/data/network/datasource/fetch_sub_data_source.dart';
import 'package:package/data/network/datasource/fetch_sub_data_source_impl.dart';
import 'package:package/data/repository/config_sub_repository_impl.dart';
import 'package:package/data/repository/fetch_sub_repository_impl.dart';
import 'package:package/data/repository/iap_repository_impl.dart';
import 'package:package/domain/repository/config_sub_repository.dart';
import 'package:package/domain/repository/fetch_sub_repository.dart';
import 'package:package/domain/repository/iap_repository.dart';
import 'package:package/domain/usecases/config_sub_use_case.dart';
import 'package:package/domain/usecases/fetch_sub_use_case.dart';
import 'package:package/domain/usecases/iap_use_case.dart';
import 'package:sqflite/sqflite.dart';

// Separate GetIt instance for package to avoid conflicts
final package_sl = GetIt.asNewInstance();

Future<void> initSub() async {
  // Check if already initialized to avoid duplicate registration
  if (package_sl.isRegistered<Database>()) {
    return;
  }

  try {
    // Database
    final db = await SubDatabase.init();
    package_sl.registerLazySingleton<Database>(() => db);

    // Data Sources
    package_sl.registerLazySingleton<ConfigSubDataSource>(
      () => ConfigSubDataSourceImpl(db: package_sl()),
    );

    package_sl.registerLazySingleton<FetchSubDataSource>(() => FetchSubDataSourceImpl());

    // External Dependencies
    package_sl.registerLazySingleton<InAppPurchase>(() => InAppPurchase.instance);

    // Repositories
    package_sl.registerLazySingleton<ConfigSubRepository>(
      () => ConfigSubRepositoryImpl(dataSource: package_sl()),
    );

    package_sl.registerLazySingleton<FetchSubRepository>(
      () => FetchSubRepositoryImpl(fetchSubDataSource: package_sl()),
    );

    package_sl.registerLazySingleton<IAPRepository>(() => IapRepositoryImpl(iap: package_sl()));

    // Use Cases
    package_sl.registerLazySingleton<ConfigSubUseCase>(
      () => ConfigSubUseCase(repository: package_sl()),
    );

    package_sl.registerLazySingleton<FetchSubUseCase>(
      () => FetchSubUseCase(fetchSubRepository: package_sl()),
    );

    package_sl.registerLazySingleton<IAPUseCase>(() => IAPUseCase(repository: package_sl()));

    // Bloc
    package_sl.registerFactory(
      () => ConfigSubBloc(configSubUseCase: package_sl(), fetchSubUseCase: package_sl()),
    );

    package_sl.registerFactory(() => IAPBloc(iapUseCase: package_sl(), configSubUseCase: package_sl()));

    print('✅ Package dependencies initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize package dependencies: $e');
    rethrow;
  }
}
