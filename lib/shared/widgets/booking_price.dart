import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Menampilkan harga akhir beserta harga asal tercoret saat promo berlaku.
///
/// Label sudah diformat pemanggil; widget ini sengaja tidak mengimpor
/// controller/format agar dapat dipakai lintas fitur.
class BookingPrice extends StatelessWidget {
  const BookingPrice({
    super.key,
    required this.finalLabel,
    required this.originalLabel,
    required this.hasDiscount,
    this.fontSize = 16,
    this.crossAxisAlignment = CrossAxisAlignment.end,
  });

  final String finalLabel;
  final String originalLabel;
  final bool hasDiscount;
  final double fontSize;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final showsOriginal = hasDiscount && originalLabel.trim().isNotEmpty;
    if (!showsOriginal) {
      return Text(
        finalLabel,
        style: TextStyle(
          color: AppColors.primaryAction,
          fontFamily: AppTheme.fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      );
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          originalLabel,
          style: TextStyle(
            color: AppColors.slate400,
            fontFamily: AppTheme.fontFamily,
            fontSize: fontSize - 3,
            fontWeight: FontWeight.w500,
            height: 1.3,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.slate400,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          finalLabel,
          style: TextStyle(
            color: AppColors.primaryAction,
            fontFamily: AppTheme.fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
