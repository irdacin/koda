import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String? _languageCode = "en";
  String? get languageCode => _languageCode;
  
  LanguageProvider() {
    _initiliazeLanguage();
  }

  void changeLanguageCode(String? newLanguageCode) {
    _languageCode = newLanguageCode;
    notifyListeners();
    _saveLanguage(newLanguageCode);
  }

  Future<void> _saveLanguage(String? newLanguageCode) async {
    if (newLanguageCode == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_LANGUAGE, newLanguageCode);
  }

  Future<void> _initiliazeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(KEY_LANGUAGE);
    if (savedLanguage != null) {
      _languageCode = savedLanguage;
      notifyListeners();
    }
  }
}
