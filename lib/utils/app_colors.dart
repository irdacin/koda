import 'package:flutter/material.dart';

class AppColors {
  static bool _isDarkMode = false;

  static void updateTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
  }

  static Color main = const Color(0xffffffff);
  static Color secondary = const Color(0xffd9d9d9);
  static Color lightText = const Color(0xff000000);
  static Color darkText = const Color(0xffffffff);
  static Color secondaryText = const Color(0xffffffff);
  static Color lightDisableText = const Color(0xffb3b3b3);
  static Color darkDisableText = const Color(0xff6b6b6b);
  static Color selected = const Color(0xff0095ff);
  static Color lightBackground = const Color(0xfff0f0f0);
  static Color darkBackground = const Color(0xff2c2c2c);

  static Color get background => _isDarkMode ? darkBackground : lightBackground;
  static Color get text => _isDarkMode ? darkText : lightText;
  static Color get disableText => _isDarkMode ? darkDisableText : lightDisableText;
}
