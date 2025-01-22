import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koda/utils/app_colors.dart';

class LightTheme {
  static ThemeData theme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(primary: Colors.black),
    appBarTheme: AppBarTheme(
      foregroundColor: AppColors.lightText,
      color: AppColors.lightBackground,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
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
