import 'package:flutter/material.dart';

/// App-wide color constants following Material Design 3 principles
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF2196F3); // Modern blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800); // Accent orange
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0F172A); // Deep navy based on Image 0
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B); // Slightly lighter navy for cards
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFF44336); // Red
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);
  
  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);
  
  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  
  // Divider Colors
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF1E293B);
  
  // Gradient Colors for Tool Cards
  static const List<Color> gradientBlue = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];
  
  static const List<Color> gradientOrange = [
    Color(0xFFFF9800),
    Color(0xFFF57C00),
  ];
  
  static const List<Color> gradientPurple = [
    Color(0xFF9C27B0),
    Color(0xFF7B1FA2),
  ];
  
  static const List<Color> gradientGreen = [
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];
  
  static const List<Color> gradientRed = [
    Color(0xFFF44336),
    Color(0xFFD32F2F),
  ];
  
  static const List<Color> gradientTeal = [
    Color(0xFF009688),
    Color(0xFF00796B),
  ];
  
  static const List<Color> gradientIndigo = [
    Color(0xFF3F51B5),
    Color(0xFF303F9F),
  ];
  
  static const List<Color> gradientPink = [
    Color(0xFFE91E63),
    Color(0xFFC2185B),
  ];
  
  static const List<Color> gradientCyan = [
    Color(0xFF00BCD4),
    Color(0xFF0097A7),
  ];
  
  static const List<Color> gradientAmber = [
    Color(0xFFFFC107),
    Color(0xFFFFA000),
  ];
  
  static const List<Color> gradientDeepOrange = [
    Color(0xFFFF5722),
    Color(0xFFE64A19),
  ];
  
  static const List<Color> gradientLime = [
    Color(0xFFCDDC39),
    Color(0xFFAFB42B),
  ];
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);
  
  // Overlay Colors
  static const Color overlayLight = Color(0x0A000000);
  static const Color overlayDark = Color(0x14FFFFFF);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  
  // Shimmer Colors
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF424242);
  static const Color shimmerHighlightDark = Color(0xFF616161);
}
