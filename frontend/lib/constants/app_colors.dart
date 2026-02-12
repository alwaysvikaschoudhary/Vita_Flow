import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFE0463A);
  static const Color primaryLight = Color(0xFFFF6B5B);
  static const Color primaryDark = Color(0xFFC0361A);

  // Secondary Colors
  static const Color secondary = Color(0xFF26C281);
  static const Color secondaryLight = Color(0xFF3EC6A4);
  static const Color secondaryDark = Color(0xFF1BA85C);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9B9B9B);
  static const Color greyLight = Color(0xFFF1F2F6);
  static const Color greyLighter = Color(0xFFF5F5F5);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;

  // Semantic Colors
  static const Color success = Color(0xFF26C281);
  static const Color error = Color(0xFFE0463A);
  static const Color warning = Color(0xFFFFA500);
  static const Color info = Color(0xFF3498DB);

  // Status Colors
  static const Color activeBlue = Color(0xFF3498DB);
  static const Color pendingOrange = Color(0xFFF39C12);
  static const Color completedGreen = Color(0xFF27AE60);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
