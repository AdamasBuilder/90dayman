import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF8B7355);
  static const Color secondary = Color(0xFFC4A77D);
  static const Color accent = Color(0xFFD4AF37);
  static const Color background = Color(0xFF1A1814);
  static const Color surface = Color(0xFF2D2A26);
  static const Color surfaceLight = Color(0xFF3D3A36);
  static const Color textPrimary = Color(0xFFE8E0D5);
  static const Color textSecondary = Color(0xFF9A9285);
  static const Color success = Color(0xFF6B8E6B);
  static const Color warning = Color(0xFFCD853F);
  static const Color error = Color(0xFF8B4513);

  static const List<Color> emotionGradient = [
    Color(0xFF6B8E6B),
    Color(0xFF8B9A6B),
    Color(0xFFC4A77D),
    Color(0xFFCD853F),
    Color(0xFF8B4513),
    Color(0xFF5C3317),
  ];

  static Color getEmotionColor(int level) {
    if (level < 1 || level > 6) return textSecondary;
    return emotionGradient[level - 1];
  }

  static const Map<int, String> emotionLevels = {
    1: 'Tranquillità',
    2: 'Discomfort',
    3: 'Frustrazione',
    4: 'Rabbia/Ansia',
    5: 'Angoscia',
    6: 'Crisi',
  };

  static const Map<int, String> emotionDescriptions = {
    1: 'Accettazione totale',
    2: 'Riconoscimento',
    3: 'Adattamento',
    4: 'Reazione impulsiva',
    5: 'Paralisi',
    6: 'Abbattimento',
  };
}

class AppTheme {
  AppTheme._();

  static TextStyle _cinzel(
      {double? fontSize,
      FontWeight? fontWeight,
      Color? color,
      double? letterSpacing,
      FontStyle? fontStyle}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      fontFamily: 'serif',
    );
  }

  static TextStyle _inter(
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      fontFamily: 'sans-serif',
    );
  }

  static TextStyle _garamond(
      {double? fontSize, FontStyle? fontStyle, Color? color}) {
    return TextStyle(
      fontSize: fontSize,
      fontStyle: fontStyle,
      color: color ?? AppColors.secondary,
      fontFamily: 'serif',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.background,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: _cinzel(
            fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
        displayMedium: _cinzel(
            fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 1.5),
        displaySmall: _cinzel(fontSize: 24, fontWeight: FontWeight.w500),
        headlineLarge: _cinzel(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: _cinzel(fontSize: 20, fontWeight: FontWeight.w500),
        headlineSmall: _cinzel(fontSize: 18, fontWeight: FontWeight.w500),
        titleLarge: _inter(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: _inter(fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: _inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary),
        bodyLarge: _inter(fontSize: 16),
        bodyMedium: _inter(fontSize: 14),
        bodySmall: _inter(fontSize: 12, color: AppColors.textSecondary),
        labelLarge: _garamond(fontSize: 18, fontStyle: FontStyle.italic),
        labelMedium: _garamond(fontSize: 16, fontStyle: FontStyle.italic),
        labelSmall: _garamond(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _cinzel(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(
            color: AppColors.primary,
            width: 0.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: _inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
        labelStyle: _inter(color: AppColors.textSecondary),
        hintStyle: _inter(color: AppColors.textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceLight,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: _inter(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
