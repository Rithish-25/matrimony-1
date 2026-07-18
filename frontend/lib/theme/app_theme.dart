import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFD81B60);
  static const Color secondary = Color(0xFFF8BBD0);
  static const Color accentGold = Color(0xFFC5A059); // Premium muted gold
  static const Color accentGoldLight = Color(0xFFF7F3E9); // Light background gold
  static const Color background = Color(0xFFFFF7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const double borderRadiusValue = 20.0;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: cardColor,
        error: const Color(0xFFD32F2F),
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 6,
        shadowColor: primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue - 4),
          borderSide: BorderSide(color: primary.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue - 4),
          borderSide: BorderSide(color: primary.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue - 4),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue - 4),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue - 4),
          borderSide: const Color(0xFFD32F2F) == Colors.black ? const BorderSide(color: Color(0xFFD32F2F)) : const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: textSecondary.withOpacity(0.6), fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusValue - 4),
          ),
        ),
      ),
    );
  }
}
