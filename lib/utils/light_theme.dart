import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koda/utils/app_colors.dart';

class LightTheme {
  static ThemeData theme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      foregroundColor: AppColors.lightText,
      color: AppColors.lightBackground,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: AppColors.lightText,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.lightText,
      displayColor: AppColors.lightText,
    ),
  );
}
