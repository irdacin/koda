import 'package:flutter/material.dart';
import 'package:koda/helpers/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationBarProvider extends ChangeNotifier {
  List<String> _navBarLabel = ["STORE", "STORAGE", "ACTIVITIES"];

  List<String> get navBarLabel => _navBarLabel;

  NavigationBarProvider() {
    _initializeNavigationBar();
  }

  Future<void> _initializeNavigationBar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _navBarLabel = prefs.getStringList(KEY_NAVIGATION_BAR_LABEL) ??
        ["STORE", "STORAGE", "ACTIVITIES"];
    notifyListeners();
  }

  Future<void> saveNavigationOrder(List<String> newOrder) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _navBarLabel = newOrder;
    await prefs.setStringList(KEY_NAVIGATION_BAR_LABEL, newOrder);
    notifyListeners();
  }
}
