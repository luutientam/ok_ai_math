import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_math_2/presentation/ui/home/page/home_page.dart';
import 'package:flutter_ai_math_2/presentation/ui/math_ai_chat/bloc/math_ai_chat_bloc.dart';
import 'package:flutter_ai_math_2/presentation/ui/math_ai_chat/pages/math_ai_chat_page.dart';
import 'package:flutter_ai_math_2/presentation/ui/setting/page/setting_page.dart';
import '../di/di.dart';
import '../routes/app_routes.dart';
import 'bottom_navigation.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final List<Widget?> _pages;
  final NotchBottomBarController _notchController = NotchBottomBarController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = [
      HomePage(onItemTapped: _onItemTapped),
      null, // Camera
      null, // AI Chat lazy load
      const SettingPage(),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    FocusScope.of(context).unfocus();

    if (index == 1) {
      // Lưu lại tab hiện tại trước khi đi
      final previousIndex = _currentIndex;

      Navigator.pushNamed(context, AppRoutes.camera).then((_) {
        FocusScope.of(context).unfocus();
        // Khi back về → quay lại tab cũ
        setState(() => _currentIndex = previousIndex);
        _notchController.jumpTo(previousIndex);
      });
    } else if (index == 2) {
      // Lazy-load AI Chat page + bloc
      if (_pages[2] == null) {
        _pages[2] = MultiBlocProvider(
          providers: [
            BlocProvider<MathAiChatBloc>(create: (_) => sl<MathAiChatBloc>()),
          ],
          child: const MathAiChatPage(),
        );
      }
      setState(() => _currentIndex = index);
      _notchController.jumpTo(index);
    } else {
      // Home hoặc Setting
      setState(() => _currentIndex = index);
      _notchController.jumpTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          _notchController.jumpTo(0);
          return false;
        }
        return true;
      },
      child: // MainShell
      Scaffold(
        backgroundColor: Colors.transparent, // trong suốt
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: IndexedStack(
            index: _currentIndex,
            children: _pages.map((page) => page ?? const SizedBox.shrink()).toList(),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: false, // sát màn hình
          child: BottomNavigation(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            notchController: _notchController,
          ),
        ),
      ),
    );
  }
}
