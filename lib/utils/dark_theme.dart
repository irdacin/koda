import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koda/utils/app_colors.dart';

class DarkTheme {
  static ThemeData theme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      foregroundColor: AppColors.darkText,
      color: AppColors.darkBackground,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: AppColors.darkText,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.darkText,
      displayColor: AppColors.darkText,
    ),
  );
}
