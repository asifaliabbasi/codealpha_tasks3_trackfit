import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Purple/Blue Gradient Theme
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color deepPurple = Color(0xFF4C1D95);
  static const Color darkPurple = Color(0xFF1A0033);

  // Background Colors
  static const Color backgroundDark = Color(0xFF0F0B1E);
  static const Color backgroundCard = Color(0xFF1A0B2E);
  static const Color backgroundGradientStart = Color(0xFF1A0033);
  static const Color backgroundGradientEnd = Color(0xFF2D1B69);

  // Accent Colors
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentYellow = Color(0xFFEAB308);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Card Colors
  static const Color cardBackground = Color(0xFF1A0B2E);
  static const Color cardBorder = Color(0xFF374151);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF6B46C1);
  static const Color buttonSecondary = Color(0xFF374151);
  static const Color buttonSuccess = Color(0xFF10B981);
  static const Color buttonDanger = Color(0xFFEF4444);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryBlue],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundGradientStart, backgroundGradientEnd],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A0B2E), Color(0xFF2D1B69)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryPurple, accentCyan],
  );

  // Icon Colors
  static const Color iconPrimary = Color(0xFFFFFFFF);
  static const Color iconSecondary = Color(0xFF9CA3AF);
  static const Color iconAccent = Color(0xFF6B46C1);

  // Progress Colors
  static const Color progressBackground = Color(0xFF374151);
  static const Color progressFill = Color(0xFF3B82F6);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Exercise Colors
  static const Color steps = Color(0xFF3B82F6);
  static const Color pushUps = Color(0xFFEF4444);
  static const Color plank = Color(0xFFF59E0B);
  static const Color lungs = Color(0xFF10B981);
  static const Color water = Color(0xFF06B6D4);
}
