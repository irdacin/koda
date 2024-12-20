import 'package:flutter/material.dart';
import 'package:koda/helpers/color_preferences.dart';

class AppColors {
  static Color main = const Color(0xffffffff);
  static Color secondary = const Color(0xffd9d9d9);
  static Color text = const Color(0xff000000);
  static Color secondaryText = const Color(0xffffffff);
  static Color selected = const Color(0xff0095ff);

  static const Map<String, Color> _defaultColors = {
    'main': Color(0xffffffff),
    'secondary': Color(0xffd9d9d9),
    'text': Color(0xff000000),
    'secondaryText': Color(0xffffffff),
    'selected': Color(0xff0095ff),
  };

  static Future<void> initializeColors() async {
    final loadedColors = await ColorPreferences.loadAllColors(_defaultColors);
    main = loadedColors['main']!;
    secondary = loadedColors['secondary']!;
    text = loadedColors['text']!;
    secondaryText = loadedColors['secondaryText']!;
    selected = loadedColors['selected']!;
  }

  static Map<String, Color> get currentColors => {
        'main': main,
        'secondary': secondary,
        'text': text,
        'secondaryText': secondaryText,
        'selected': selected,
      };

  static void updateColor(String key, Color color) async {
    await ColorPreferences.saveColor(key, color);
    switch (key) {
      case 'main':
        main = color;
        break;
      case 'secondary':
        secondary = color;
        break;
      case 'text':
        text = color;
        break;
      case 'secondaryText':
        secondaryText = color;
        break;
      case 'selected':
        selected = color;
        break;
    }
  }
}
