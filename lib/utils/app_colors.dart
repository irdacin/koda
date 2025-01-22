import 'package:flutter/material.dart';

class AppColors {
  static bool _isDarkMode = false;

  static void updateTheme(bool? isDarkMode) {
    if (isDarkMode != null) _isDarkMode = isDarkMode;
  }

  static Color lightMain = const Color(0xffffffff);
  static Color darkMain = const Color(0xff888888);
  static Color lightSecondary = const Color(0xffd9d9d9);
  static Color darkSecondary = const Color(0xff555555);
  static Color lightBorder = const Color(0xff000000);
  static Color darkBorder = const Color(0xffffffff);
  static Color lightText = const Color(0xff000000);
  static Color darkText = const Color(0xffffffff);
  static Color secondaryText = const Color(0xffffffff);
  static Color lightDisableText = const Color(0xffb3b3b3);
  static Color darkDisableText = const Color(0xff6b6b6b);
  static Color selected = const Color(0xff0095ff);
  static Color lightBackground = const Color(0xffffffff);
  static Color darkBackground = const Color(0xff2c2c2c);

  static Color get background => _isDarkMode ? darkBackground : lightBackground;
  static Color get text => _isDarkMode ? darkText : lightText;
  static Color get disableText => _isDarkMode ? darkDisableText : lightDisableText;
  static Color get secondary => _isDarkMode ? darkSecondary : lightSecondary;
  static Color get main => _isDarkMode ? darkMain : lightMain;
  static Color get border => _isDarkMode ? darkBorder : lightBorder;
}
