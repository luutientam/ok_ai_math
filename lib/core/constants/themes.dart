import 'package:flutter/material.dart';
import 'package:flutter_ai_math_2/app.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.darkBackground,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.btnPrimary,
      unselectedItemColor: AppColors.btnSecondary,
      backgroundColor: AppColors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBarBg,
      titleTextStyle: TextStyle(
        color: AppColors.appBarTitle,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        fontFamily: "Nunito",
      ),
      iconTheme: IconThemeData(color: AppColors.white),
    ),
  );
}
