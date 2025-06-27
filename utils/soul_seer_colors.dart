import 'package:flutter/material.dart';

class SoulSeerColors {
  // Primary mystical colors
  static const Color mysticalPink = Color(0xFFE91E63);
  static const Color cosmicGold = Color(0xFFFFD700);
  static const Color deepPurple = Color(0xFF6F61EF);
  static const Color etherealBlue = Color(0xFF39D2C0);
  
  // Secondary colors
  static const Color starWhite = Color(0xFFF1F4F8);
  static const Color voidBlack = Color(0xFF15161E);
  static const Color shadowGrey = Color(0xFFB0BEC5);
  static const Color errorRed = Color(0xFFFF5963);
  
  // Gradient colors
  static const Color gradientStart = Color(0xFF1A0033);
  static const Color gradientMid = Color(0xFF000000);
  static const Color gradientEnd = Color(0xFF1A0033);
  
  // Mystical gradients
  static const LinearGradient mysticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000),
      Color(0xFF1A0033),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [
      mysticalPink,
      cosmicGold,
    ],
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A0033),
      Color(0xFF000000),
    ],
  );
  
  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Theme-based colors
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? mysticalPink
        : deepPurple;
  }
  
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cosmicGold
        : etherealBlue;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? voidBlack
        : starWhite;
  }
  
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? starWhite
        : voidBlack;
  }
}