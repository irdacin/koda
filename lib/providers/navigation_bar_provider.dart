import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationBarProvider extends ChangeNotifier {
  late int _store;
  late int _storage;
  late int _activities;
  int get store => _store;
  int get storage => _storage;
  int get activities => _activities;

  NavigationBarProvider() {
    _initiliazeNavigationBar();
  }

  Future<void> _initiliazeNavigationBar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _store = prefs.getInt(KEY_NAVIGATION_BAR_STORE) ?? 0;
    _storage = prefs.getInt(KEY_NAVIGATION_BAR_STORAGE) ?? 1;
    _activities = prefs.getInt(KEY_NAVIGATION_BAR_ACTIVITIES) ?? 2;
    notifyListeners();
  }
  
  Future<void> _saveNavigationBarName(String key, String newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, newValue);
  }
}
