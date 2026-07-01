import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // Cyber Tech Palette
  // =========================

  static const Color background = Color(0xFF06141D);
  static const Color surface = Color(0xFF0C1E29);
  static const Color surfaceLight = Color(0xFF112734);

  static const Color primary = Color(0xFF35F58A);
  static const Color primaryDark = Color(0xFF14C768);

  static const Color accent = Color(0xFF28D7FF);

  static const Color textPrimary = Color(0xFFEAFBF4);
  static const Color textSecondary = Color(0xFF9DC5B5);

  static const Color border = Color(0xFF1D4E42);

  static const Color glow = Color(0x8035F58A);

  static const Color alertaConflictoFondo = Color(0xFFFFEBEE);
  static const Color alertaConflictoTexto = Color(0xFFC62828);
  static const Color alertaDisponibilidadFondo = Color(0xFFFFF3E0);
  static const Color alertaDisponibilidadTexto = Color(0xFFE65100);
  static const Color alertaSistemaFondo = Color(0xFFE3F2FD);
  static const Color alertaSistemaTexto = Color(0xFF1565C0);

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      primary: primary,
      onPrimary: Colors.black,

      secondary: accent,
      onSecondary: Colors.black,

      error: Colors.redAccent,
      onError: Colors.white,

      surface: surface,
      onSurface: textPrimary,
    ),

    scaffoldBackgroundColor: background,

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 12,
      shadowColor: glow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: border,
          width: 1,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF010C12),

      labelStyle: const TextStyle(
        color: textSecondary,
      ),

      hintStyle: const TextStyle(
        color: textSecondary,
      ),

      prefixIconColor: primary,
      suffixIconColor: primary,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),

        backgroundColor: primary,
        foregroundColor: Colors.black,

        shadowColor: glow,
        elevation: 10,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(
          color: primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
      ),
    ),

    dividerColor: border,

    iconTheme: const IconThemeData(
      color: primary,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
      ),

      headlineMedium: TextStyle(
        color: primary,
        fontWeight: FontWeight.bold,
        fontSize: 26,
      ),

      titleLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: textPrimary,
      ),

      bodyMedium: TextStyle(
        color: textSecondary,
      ),

      bodySmall: TextStyle(
        color: textSecondary,
      ),
    ),
  );
}