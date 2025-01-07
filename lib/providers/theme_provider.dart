import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _initiliazeTheme();
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    AppColors.updateTheme(isDarkMode);
    _saveTheme(isDarkMode);
    notifyListeners();
  }

  Future<void> _initiliazeTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(KEY_IS_DARK_MODE);
    if (isDarkMode == null) return;
    
    AppColors.updateTheme(isDarkMode);
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(KEY_IS_DARK_MODE, isDarkMode);
  }
}
