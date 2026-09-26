import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF00685F);
  static const Color primaryAction = Color(0xFF008378);
  static const Color primaryContainer = Color(0xFFC6FEF8);
  static const Color primaryBorder = Color(0xFFB5EDE7);
  static const Color primarySoft = Color(0xFFBBF3ED);
  static const Color heading = Color(0xFF00201E);
  static const Color sectionHeading = Color(0xFF0F2E2B);
  static const Color body = Color(0xFF3D4947);
  static const Color muted = Color(0xFF6D7A77);
  static const Color categoryText = Color(0xFF1E293B);
  static const Color notification = Color(0xFFBA1A1A);
  static const Color screenBackground = Color(0xFFF8FAFC);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
}

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Plus Jakarta Sans',
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
