import 'package:flutter/material.dart';

class AppFonts {
  // Font families
  static const String robotoSerif = 'Roboto Serif';
  static const String inter = 'Inter';
  static const String poppins = 'Poppins';

  // Text styles với font khác nhau
  static const TextStyle headingRoboto = TextStyle(
    fontFamily: 'Roboto Serif',
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyInter = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle buttonPoppins = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
