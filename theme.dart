import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF69B4), // Mystical Pink
        secondary: Color(0xFFFFD700), // Gold
        tertiary: Color(0xFF9C27B0), // Deep Purple
        surface: Color(0xFFF8F4FF), // Light mystical background
        error: Color(0xFFFF4444),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFF000000),
        onTertiary: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
        onError: Color(0xFFFFFFFF),
        outline: Color(0xFFE0E0E0),
        background: Color(0xFFF8F4FF),
        onBackground: Color(0xFF000000),
      ),
      brightness: Brightness.light,
      textTheme: TextTheme(
        // Headers - Alex Brush in pink
        displayLarge: GoogleFonts.alexBrush(
          fontSize: 57.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFF69B4),
        ),
        displayMedium: GoogleFonts.alexBrush(
          fontSize: 45.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFF69B4),
        ),
        displaySmall: GoogleFonts.alexBrush(
          fontSize: 36.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF69B4),
        ),
        headlineLarge: GoogleFonts.alexBrush(
          fontSize: 32.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFF69B4),
        ),
        headlineMedium: GoogleFonts.alexBrush(
          fontSize: 28.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFF69B4),
        ),
        headlineSmall: GoogleFonts.alexBrush(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF69B4),
        ),
        
        // Body text - Playfair Display
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF000000),
        ),
        titleMedium: GoogleFonts.playfairDisplay(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF000000),
        ),
        titleSmall: GoogleFonts.playfairDisplay(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF000000),
        ),
        labelLarge: GoogleFonts.playfairDisplay(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF000000),
        ),
        labelMedium: GoogleFonts.playfairDisplay(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF000000),
        ),
        labelSmall: GoogleFonts.playfairDisplay(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF000000),
        ),
        bodyLarge: GoogleFonts.playfairDisplay(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF000000),
        ),
        bodyMedium: GoogleFonts.playfairDisplay(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF000000),
        ),
        bodySmall: GoogleFonts.playfairDisplay(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF000000),
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF69B4), // Mystical Pink
        secondary: Color(0xFFFFD700), // Gold
        tertiary: Color(0xFFBA68C8), // Light Purple
        surface: Color(0xFF0A0A0A), // Deep black cosmic background
        error: Color(0xFFFF6B6B),
        onPrimary: Color(0xFF000000),
        onSecondary: Color(0xFF000000),
        onTertiary: Color(0xFF000000),
        onSurface: Color(0xFFFFFFFF),
        onError: Color(0xFF000000),
        outline: Color(0xFF333333),
        background: Color(0xFF000000),
        onBackground: Color(0xFFFFFFFF),
      ),
      brightness: Brightness.dark,
      textTheme: TextTheme(
        // Headers - Alex Brush in pink
        displayLarge: GoogleFonts.alexBrush(
          fontSize: 57.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFF69B4),
        ),
        displayMedium: GoogleFonts.alexBrush(
          fontSize: 45.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFF69B4),
        ),
        displaySmall: GoogleFonts.alexBrush(
          fontSize: 36.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF69B4),
        ),
        headlineLarge: GoogleFonts.alexBrush(
          fontSize: 32.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFF69B4),
        ),
        headlineMedium: GoogleFonts.alexBrush(
          fontSize: 28.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFF69B4),
        ),
        headlineSmall: GoogleFonts.alexBrush(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF69B4),
        ),
        
        // Body text - Playfair Display  
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        titleMedium: GoogleFonts.playfairDisplay(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        titleSmall: GoogleFonts.playfairDisplay(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        labelLarge: GoogleFonts.playfairDisplay(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        labelMedium: GoogleFonts.playfairDisplay(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        labelSmall: GoogleFonts.playfairDisplay(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        bodyLarge: GoogleFonts.playfairDisplay(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFFFFFF),
        ),
        bodyMedium: GoogleFonts.playfairDisplay(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFFFFFF),
        ),
        bodySmall: GoogleFonts.playfairDisplay(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFFFFFFF),
        ),
      ),
    );

// SoulSeer color constants for consistency
class SoulSeerColors {
  static const Color mysticalPink = Color(0xFFFF69B4);
  static const Color cosmicGold = Color(0xFFFFD700);
  static const Color deepPurple = Color(0xFF9C27B0);
  static const Color lightPurple = Color(0xFFBA68C8);
  static const Color cosmicBlack = Color(0xFF0A0A0A);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color starDust = Color(0xFF333333);
  
  // Gradient combinations
  static const LinearGradient mysticalGradient = LinearGradient(
    colors: [mysticalPink, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [cosmicGold, mysticalPink],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient celestialGradient = LinearGradient(
    colors: [deepPurple, cosmicBlack],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}