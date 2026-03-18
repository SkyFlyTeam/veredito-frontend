import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Purple) - Principal
  static const Color purple900 = Color(0xFF160B30);
  static const Color purple800 = Color(0xFF1D1C52); // Cor do Glow
  static const Color purple700 = Color(0xFF2E1A6B);
  static const Color purple600 = Color(0xFF3F2391);
  static const Color purple500 = Color(0xFF5532CD); // Cor Primária
  static const Color purple400 = Color(0xFF6B45ED);
  static const Color purple300 = Color(0xFF8667F8);
  static const Color purple200 = Color(0xFFA58CFA);
  static const Color purple100 = Color(0xFFC4B4FC);

  // Status Colors (Blue) - Secundária / Informação
  static const Color blue900 = Color(0xFF10131D); // Fundo Principal Dark
  static const Color blue800 = Color(0xFF121B33);
  static const Color blue700 = Color(0xFF17264A);
  static const Color blue600 = Color(0xFF1E3365);
  static const Color blue500 = Color(0xFF264287);
  static const Color blue400 = Color(0xFF3254AA);
  static const Color blue300 = Color(0xFF456DCA);
  static const Color blue200 = Color(0xFF698FDF);
  static const Color blue100 = Color(0xFF9AB4EE);

  // Error Colors (Red) - Erros / Alertas
  static const Color red900 = Color(0xFF39080B);
  static const Color red800 = Color(0xFF520B10);
  static const Color red700 = Color(0xFF781119);
  static const Color red600 = Color(0xFFA11721);
  static const Color red500 = Color(0xFFC71A26);
  static const Color red400 = Color(0xFFE22634);
  static const Color red300 = Color(0xFFEE4955);
  static const Color red200 = Color(0xFFF3757F);
  static const Color red100 = Color(0xFFF8A2A9);

  // Neutral Colors (Gray) - Fundo / Cards / Textos
  static const Color gray900 = Color(0xFF121214); // Fundo Principal Dark
  static const Color gray800 = Color(0xFF202024); // Fundo de Cards / Inputs
  static const Color gray700 = Color(0xFF29292E);
  static const Color gray600 = Color(0xFF323238);
  static const Color gray500 = Color(0xFF7C7C8A);
  static const Color gray400 = Color(0xFF8D8D99);
  static const Color gray300 = Color(0xFFC4C4CC); // Textos Secundários
  static const Color gray200 = Color(0xFFE1E1E6); // Textos Primários
  static const Color gray100 = Color(0xFFF3F3F5); // Alto contraste

  // Semantic Colors
  static const Color background = blue900;
  static const Color surface = gray800;
  static const Color primary = purple500;
  static const Color error = red500;
}
