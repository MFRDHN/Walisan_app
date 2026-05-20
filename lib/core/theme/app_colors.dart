import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Warna Utama
  static const Color primary = Color(0xFF0A9B72);
  static const Color primaryDark = Color(0xFF087A5A);
  static const Color primaryLight = Color(0xFF4FD1A5);
  static const Color secondary = Color(0xFF03A9F4); // Diperlukan oleh app_theme.dart

  // Latar Belakang
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color backgroundLoginPage = Color(0xFF1D8991);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEEEEE); // Diperlukan oleh exam_screen

  // Teks & Hint (PENTING: Agar error textHint hilang)
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFAAAAAA);      // Diperlukan oleh app_text_styles.dart
  static const Color textOnPrimary = Colors.white;

  // Border & Input (PENTING: Agar error border & borderFocused hilang)
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color border = Color(0xFFE0E0E0);        // Diperlukan oleh app_theme.dart
  static const Color borderFocused = Color(0xFF0A9B72); // Diperlukan oleh app_theme.dart

  // Status & Feedback
  static const Color info = Color(0xFF2196F3);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF0A9B72);
  static const Color accent = Color(0xFF00BCD4);        // Diperlukan oleh report_screen
  static const Color secondaryDark = Color(0xFF00796B); // Diperlukan oleh savings_screen

  // Efek & Lainnya
  static const Color shadow = Colors.black26;           // Diperlukan oleh app_theme.dart & profile_screen
  static const Color white = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color whatsapp = Color(0xFF25D366);
}