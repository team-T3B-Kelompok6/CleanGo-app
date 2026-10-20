import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum AppNoticeType { success, error, info }

abstract final class AppNotice {
  static void show(
    BuildContext context,
    String message, {
    AppNoticeType type = AppNoticeType.success,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: type == AppNoticeType.error
            ? AppColors.notification
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: EdgeInsets.symmetric(
          horizontal:
              16 +
              ((MediaQuery.sizeOf(context).width - 480) / 2).clamp(
                0,
                double.infinity,
              ),
          vertical: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              switch (type) {
                AppNoticeType.success => Icons.check_circle_outline_rounded,
                AppNoticeType.error => Icons.error_outline_rounded,
                AppNoticeType.info => Icons.info_outline_rounded,
              },
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
