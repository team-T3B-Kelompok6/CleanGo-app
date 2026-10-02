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
  static const String fontFamily = 'Inter';

  static const TextTheme textTheme = TextTheme(
    titleLarge: TextStyle(
      color: AppColors.slate900,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      color: AppColors.slate900,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleSmall: TextStyle(
      color: AppColors.slate900,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    bodyLarge: TextStyle(
      color: AppColors.slate600,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: AppColors.slate600,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    bodySmall: TextStyle(
      color: AppColors.slate500,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      color: AppColors.slate900,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      color: AppColors.slate600,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      color: AppColors.slate500,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      textTheme: textTheme.apply(fontFamily: fontFamily),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          color: AppColors.slate900,
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
          color: AppColors.slate600,
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppColors.slate500,
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
