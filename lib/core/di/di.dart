import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:flutter_ai_math_2/app.dart';

import '../../presentation/ui/favorite/bloc/favorite_bloc.dart';
import '../../presentation/ui/formula/bloc/formula_item_bloc.dart';
import '../../presentation/ui/history/bloc/take_photo_history_bloc.dart';
import '../../presentation/ui/math_ai_chat/bloc/math_ai_chat_bloc.dart';
import '../../presentation/ui/history/bloc/ai_chat_history_bloc.dart';
import '../../presentation/ui/solve/bloc/solve_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  final db = await DatabaseHelper.init();
  sl.registerLazySingleton<Database>(() => db);

  // Dio
  sl.registerLazySingleton(() => Dio());

  // Data Sources
  sl.registerLazySingleton<GeminiDataSource>(
    () => GeminiDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<MathDataSource>(
    () => MathDataSourceImpl(db: sl<Database>()),
  );
  sl.registerLazySingleton<FormulaDataSource>(
    () => FormulaDataSourceImpl(db: sl<Database>()),
  );
  sl.registerLazySingleton<FormulaItemDataSource>(
    () => FormulaItemDataSourceImpl(db: sl<Database>()),
  );
  sl.registerLazySingleton<MathAiDataSource>(
    () => MathAiDataSourceImpl(db: sl<Database>()),
  );
  sl.registerLazySingleton<MathAiChatDataSource>(
    () => MathAiChatDataSourceImpl(db: sl<Database>()),
  );

  // Repositories
  sl.registerLazySingleton<GeminiRepository>(
    () => GeminiRepositoryImpl(sl<GeminiDataSource>()),
  );
  sl.registerLazySingleton<MathRepository>(
    () => MathRepositoryImpl(dataSource: sl<MathDataSource>()),
  );
  sl.registerLazySingleton<CameraRepository>(() => CameraRepositoryImpl());
  sl.registerLazySingleton<FormulaRepository>(
    () => FormulaRepositoryImpl(dataSource: sl<FormulaDataSource>()),
  );
  sl.registerLazySingleton<FormulaItemRepository>(
    () => FormulaItemRepositoryImpl(dataSource: sl<FormulaItemDataSource>()),
  );
  sl.registerLazySingleton<MathAiRepository>(
    () => MathAiRepositoryImpl(dataSource: sl<MathAiDataSource>()),
  );
  sl.registerLazySingleton<MathAiChatRepository>(
    () => MathAiChatRepositoryImpl(dataSource: sl<MathAiChatDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => GeminiUseCase(repository: sl<GeminiRepository>()),
  );
  sl.registerLazySingleton(() => MathUseCase(repository: sl<MathRepository>()));
  sl.registerLazySingleton(
    () => CameraUseCase(repository: sl<CameraRepository>()),
  );
  sl.registerLazySingleton(
    () => FormulaUseCase(repository: sl<FormulaRepository>()),
  );
  sl.registerLazySingleton(
    () => FormulaItemUseCase(repository: sl<FormulaItemRepository>()),
  );
  sl.registerLazySingleton(
    () => MathAiUseCase(repository: sl<MathAiRepository>()),
  );
  sl.registerLazySingleton(
    () => MathAiChatUseCase(repository: sl<MathAiChatRepository>()),
  );
  sl.registerLazySingleton(
    () => HistoryUseCase(
      mathAiRepository: sl<MathAiRepository>(),
      mathAiChatRepository: sl<MathAiChatRepository>(),
    ),
  );

  // Blocs
  sl.registerFactory(() => CameraBloc(cameraUseCase: sl<CameraUseCase>()));
  sl.registerFactory(() => FormulaBloc(useCase: sl<FormulaUseCase>()));
  sl.registerFactory(() => FormulaItemBloc(useCase: sl<FormulaItemUseCase>()));
  sl.registerFactory(
    () => MathAiChatBloc(
      useCase: sl<MathAiChatUseCase>(),
      geminiRepository: sl<GeminiRepository>(),
    ),
  );


  sl.registerFactory(() => AiChatHistoryBloc(historyUseCase: sl<HistoryUseCase>()));
  sl.registerFactory(() => TakePhotoHistoryBloc(mathUseCase: sl<MathUseCase>()));
  sl.registerFactory(() => FavoritesPhotoBloc(mathUseCase: sl<MathUseCase>()));
  sl.registerFactory(
    () => SolveBloc(
      geminiUseCase: sl<GeminiUseCase>(),
      mathUseCase: sl<MathUseCase>(),
    ),
  );
}
