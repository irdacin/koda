import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorPreferences {
  static Future<void> saveColor(String key, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, color.value);
  }

  static Future<Map<String, Color>> loadAllColors(Map<String, Color> defaultColors) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, Color> loadedColors = {};
    defaultColors.forEach((key, defaultColor) {
      int? colorValue = prefs.getInt(key);
      loadedColors[key] = colorValue != null ? Color(colorValue) : defaultColor;
    });
    return loadedColors;
  }
}
