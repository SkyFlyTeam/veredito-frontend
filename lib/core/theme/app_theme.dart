import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.purple200,
      scaffoldBackgroundColor: AppColors.background,

      // Color Scheme (Recommended)
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple200,
        secondary: AppColors.blue500,
        surface: AppColors.gray800,
        error: AppColors.red500,
        onPrimary: AppColors.gray100,
        onSurface: AppColors.gray100, // Text on background
        onError: AppColors.gray100,
      ),

      // Cursor and Selection Color
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.gray100,
        selectionColor: AppColors.purple400,
        selectionHandleColor: AppColors.gray100,
      ),

      // Typography Based on Figma Tokens
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            headlineMedium: GoogleFonts.montserrat(
              color: AppColors.gray100,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
            titleMedium: GoogleFonts.montserrat(
              color: AppColors.gray100,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 0.8,
              letterSpacing: 0.4,
            ),
            titleSmall: GoogleFonts.montserrat(
              color: AppColors.gray100,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
            bodyMedium: GoogleFonts.montserrat(
              color: AppColors.gray100,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.33,
              letterSpacing: 0.4,
            ),
            bodySmall: GoogleFonts.montserrat(
              color: AppColors.gray100,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),

      // Customizing Text Fields (Inputs)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.montserrat(
          color: AppColors.gray100,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: 0.4,
        ),
        hintStyle: GoogleFonts.montserrat(
          color: AppColors.gray500,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.4,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray100, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red500),
        ),
      ),

      // Personalization of primary buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple500,
          foregroundColor: AppColors.gray100,
          minimumSize: const Size(double.infinity, 41),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Outlining Buttons (secondary buttons)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purple300,
          side: const BorderSide(color: AppColors.purple500),
          minimumSize: const Size(double.infinity, 41),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
