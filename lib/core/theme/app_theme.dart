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
