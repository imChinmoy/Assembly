import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Base - darker, more sophisticated palette
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF12161F);
  static const Color card = Color(0xFF1A1E2E);
  
  // Glassmorphism overlays
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x0D000000);

  // Primary gradient colors - more vibrant
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7FFF);
  static const Color secondary = Color(0xFFA29BFE);

  // Accent colors
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentSecondary = Color(0xFF4ECDC4);
  static const Color success = Color(0xFF00D9A3);
  static const Color error = Color(0xFFFF6B9D);
  static const Color warning = Color(0xFFFECA57);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8BFCE);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // Shadows for claymorphism
  static const Color shadowLight = Color(0x1AFFFFFF);
  static const Color shadowDark = Color(0x40000000);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    // fontFamily: 'Hunters K-Pop',

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    // AppBar with glassmorphism
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Hunters K-Pop',
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    ),

    // Cards with claymorphism effect
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.glassLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      hintStyle: const TextStyle(color: AppColors.textTertiary),
    ),

    // Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      ),
    ),

    // Icons
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),

    // Divider
    dividerColor: AppColors.glassLight,
  );

  /// Primary gradient for claymorphism highlights
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      AppColors.primary,
      AppColors.primaryLight,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Accent gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      AppColors.accent,
      AppColors.accentSecondary,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Glassmorphism gradient overlay
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      AppColors.glassLight,
      Colors.transparent,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Claymorphism box decoration
  static BoxDecoration claymorphicDecoration({
    BorderRadius? borderRadius,
    Color? color,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      gradient: gradient,
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.glassLight,
        width: 1.5,
      ),
      boxShadow: const [
        // Outer shadow (dark)
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(8, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        // Inner highlight (light)
        BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(-4, -4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  /// Pressed/inset claymorphism effect
  static BoxDecoration claymorphicDecorationInset({
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.glassDark,
        width: 1,
      ),
      boxShadow: const [
        // Inner shadow (dark) - creates inset effect
        BoxShadow(
          color: AppColors.shadowDark,
          offset: Offset(4, 4),
          blurRadius: 12,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(-2, -2),
          blurRadius: 8,
          spreadRadius: -2,
        ),
      ],
    );
  }
}