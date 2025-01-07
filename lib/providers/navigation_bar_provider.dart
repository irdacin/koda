import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationBarProvider extends ChangeNotifier {
  late String _store;
  late String _storage;
  late String _activities;
  String get store => _store;
  String get storage => _storage;
  String get activities => _activities;

  NavigationBarProvider() {
    _initiliazeNavigationBar();
  }

  Future<void> _initiliazeNavigationBar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _store = prefs.getString(KEY_NAVIGATION_BAR_STORE) ?? "STORE";
    _storage = prefs.getString(KEY_NAVIGATION_BAR_STORAGE) ?? "STORAGE";
    _activities = prefs.getString(KEY_NAVIGATION_BAR_ACTIVITIES) ?? "ACTIVITIES";
    notifyListeners();
  }
  
  void changeStoreName(String value) {
    _store = value;
    _saveNavigationBarName(KEY_NAVIGATION_BAR_STORE, value);
    notifyListeners();
  }

  void changeStorageName(String value) {
    _storage = value;
    _saveNavigationBarName(KEY_NAVIGATION_BAR_STORAGE, value);
    notifyListeners();
  }

  void changeActivitiesName(String value) {
    _activities = value;
    _saveNavigationBarName(KEY_NAVIGATION_BAR_ACTIVITIES, value);
    notifyListeners();
  }

  Future<void> _saveNavigationBarName(String key, String newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, newValue);
  }
}
