import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.purple500,
      scaffoldBackgroundColor: AppColors.background, 
      
      // Esquema de Cores (Recomendado)
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple500,
        secondary: AppColors.blue500,
        surface: AppColors.gray800,
        error: AppColors.red500,
        onPrimary: Colors.white,
        onSurface: AppColors.gray100, // Textos sobre fundo
        onSecondary: Colors.white,
        onError: Colors.white,
      ),

      // Cursor e Cor de Seleção
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: AppColors.purple400,
        selectionHandleColor: Colors.white,
      ),

      // Tipografia
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        // displayLarge: Título Logo 
        displayLarge: GoogleFonts.montserrat(
          color: AppColors.purple200, 
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.montserrat(
          color: Colors.white, 
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 0.8, // 16px line-height / 20px font-size
          letterSpacing: 0.4,
        ),
        // titleMedium: Inputs Digitados
        titleMedium: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.4,
        ), 
        // bodyLarge: Texto padrão
        bodyLarge: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 12,
        ),
        // bodyMedium: Subtítulos e Textos Secundários
        bodyMedium: GoogleFonts.montserrat(
          color: AppColors.gray200,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.4,
        ),
        // labelLarge: Labels de Input (Email, Nome completo)
        labelLarge: GoogleFonts.montserrat(
          color: Colors.white, 
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: 0.4,
        ),
      ),

      // Personalizando Campos de Texto (Inputs)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray800,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.montserrat(
          color: Colors.white,
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
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red500),
        ),
      ),

      // Personalizando Botões Globais (Primary)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple500,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 41), // 41px de altura no Figma
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16, 
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Outlining Buttons (Botões secundários)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purple300,
          side: const BorderSide(color: AppColors.purple500),
          minimumSize: const Size(double.infinity, 41),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16, 
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      // AppBar Theme (transparente por padrão com tipografia atualizada)
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
