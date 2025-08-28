import 'package:flutter/material.dart';
import 'package:flutter_ai_math_2/presentation/ui/history/bloc/take_photo_history_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_math_2/presentation/ui/math_ai_chat/bloc/math_ai_chat_bloc.dart';
import 'package:flutter_ai_math_2/presentation/ui/math_ai_chat/pages/math_ai_chat_page.dart';
import 'package:flutter_ai_math_2/presentation/ui/history/bloc/ai_chat_history_bloc.dart';
import 'package:flutter_ai_math_2/presentation/ui/history/page/ai_chat_history_page.dart';
import 'package:flutter_ai_math_2/presentation/ui/favorite/bloc/favorite_bloc.dart';
import 'package:flutter_ai_math_2/presentation/ui/favorite/bloc/favorite_event.dart';
import 'package:flutter_ai_math_2/presentation/ui/favorite/page/favorite_page.dart';
import 'package:flutter_ai_math_2/presentation/ui/formula/pages/formula_detail_screen.dart';
import 'package:package/bloc/config_sub_bloc.dart';
import 'package:package/bloc/iap_bloc.dart';
import 'package:package/bloc/iap_event.dart';
import 'package:package/core/package_di/package_di.dart';

import '../../domain/models/formula.dart';
import '../../domain/models/formula_item.dart';
import '../../presentation/ui/camera/bloc/camera_bloc.dart';
import '../../presentation/ui/camera/bloc/camera_event.dart';
import '../../presentation/ui/camera/page/camera_page.dart';
import '../../presentation/ui/formula/bloc/formula_bloc.dart';
import '../../presentation/ui/formula/bloc/formula_event.dart';
import '../../presentation/ui/formula/bloc/formula_item_bloc.dart';
import '../../presentation/ui/formula/bloc/formula_item_event.dart';
import '../../presentation/ui/formula/pages/formula_page.dart';
import '../../presentation/ui/history/bloc/ai_chat_history_event.dart';
import '../../presentation/ui/history/page/history_tabs_page.dart';
import '../../presentation/ui/history/page/take_photo_history_page.dart';
import '../../presentation/ui/setting/page/setting_page.dart';
import '../../presentation/ui/sub/page/sub_page.dart';
import '../../presentation/ui/sub/page/sub_test_page.dart';
import '../di/di.dart';
import '../navigation/main_shell.dart';
import '../utils/iap_helper.dart';

class AppRoutes {
  static const onboard = '/onboard';
  static const home = '/home';
  static const camera = '/camera';
  static const setting = '/setting';
  static const formula = '/formula';
  static const formulaItem = '/formulaItem';
  static const subTest = '/subTest';
  static const fetchSubTest = '/fetchSubTest';
  static const subPage = '/subPage';
  static const demoSubPage = '/demoSubPage';
  static const mathAiChat = '/mathAiChat';

  static const history = '/history';
  static const favorites = '/favorites';
}

class AppIcons {
  static const String icHome = 'assets/icons/home.svg';
  static const String icCamera = 'assets/icons/camera.svg';
  static const String icAiChat = 'assets/icons/aichat.svg';
  static const String icSettings = 'assets/icons/settings.svg';
}

class AppColors {
  static const Color btnPrimary = Color(0xFF6200EE); // Ví dụ màu
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.btnPrimary,
    scaffoldBackgroundColor: AppColors.black,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.white),
    ),
  );
}
final routes = {
  AppRoutes.home: (_) => const MainShell(),
  AppRoutes.camera: (context) => BlocProvider(
    create: (context) => sl<CameraBloc>()..add(CameraStartedEvent()),
    child: const CameraPage(),
  ),
  AppRoutes.setting: (_) => const SettingPage(),
  AppRoutes.subTest: (context) => MultiBlocProvider(
    providers: [
      BlocProvider<ConfigSubBloc>(
        create: (context) => ConfigSubBloc(
          configSubUseCase: package_sl(),
          fetchSubUseCase: package_sl(),
        ),
      ),
    ],
    child: const SubTestPage(),
  ),
  AppRoutes.subPage: (context) => MultiBlocProvider(
    providers: [
      BlocProvider<IAPBloc>(
        create: (context) => IAPHelper.getIAPBloc()
          ..add(const IAPInitializeEvent())
          ..add(IAPLoadProductsEvent(IAPHelper.allProductIds)),
      ),
      BlocProvider<ConfigSubBloc>(
        create: (context) => ConfigSubBloc(
          configSubUseCase: package_sl(),
          fetchSubUseCase: package_sl(),
        ),
      ),
    ],
    child: const SubPage(),
  ),

  AppRoutes.formula: (context) => MultiBlocProvider(
    providers: [
      BlocProvider<FormulaBloc>(
        create: (context) => sl<FormulaBloc>()..add(FormulaWatchAllEvent()),
      ),
      BlocProvider<FormulaItemBloc>(
        create: (context) =>
        sl<FormulaItemBloc>()..add(FormulaItemWatchSavedEvent()),
      ),
    ],
    child: const FormulaPage(),
  ),
  AppRoutes.formulaItem: (context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final formula = args['formula'] as Formula;
    final item = args['item'] as FormulaItem;

    return MultiBlocProvider(
      providers: [
        BlocProvider<FormulaBloc>.value(
          value: BlocProvider.of<FormulaBloc>(context),
        ),
        BlocProvider<FormulaItemBloc>.value(
          value: BlocProvider.of<FormulaItemBloc>(context),
        ),
      ],
      child: FormulaDetailPage(formula: formula, item: item),
    );
  },
  AppRoutes.mathAiChat: (context) => MultiBlocProvider(
    providers: [
      BlocProvider<MathAiChatBloc>(create: (context) => sl<MathAiChatBloc>()),
    ],
    child: MathAiChatPage(),
  ),
  AppRoutes.history: (context) => MultiBlocProvider(
    providers: [
      BlocProvider<AiChatHistoryBloc>(
        create: (context) => sl<AiChatHistoryBloc>()
      ),
      BlocProvider<TakePhotoHistoryBloc>(
        create: (context) => sl<TakePhotoHistoryBloc>()
      ),
    ],
    child:  HistoryTabsPage(initialTabIsPhoto: true),
  ),

  AppRoutes.favorites: (context) => BlocProvider(
    create: (context) => sl<FavoritesPhotoBloc>()..add(LoadFavoritesPhoto()),
    child:  FavoritesPage(),
  ),
};