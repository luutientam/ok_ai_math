// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package/core/package_di/package_di.dart';

// import 'dart:io';
import 'app.dart';
import 'core/routes/app_routes.dart' hide AppTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await init();
  await initSub();

  // Build trực tiếp cho iPhone - không dùng DevicePreview
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}
// 👇 thêm dòng này
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      title: 'Stamp Identifier',
      // initialRoute: AppRoutes.onboard,
      // initialRoute: AppRoutes.subTest,
      initialRoute: AppRoutes.home,
      routes: routes,
      restorationScopeId: null,
      navigatorObservers: [routeObserver],
    );
  }
}
