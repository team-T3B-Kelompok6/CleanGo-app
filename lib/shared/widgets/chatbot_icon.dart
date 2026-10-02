import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';

/// Identitas visual Boo beserta lingkaran dan indikator statusnya.
///
/// Seluruh kemunculan Chatbot menggunakan komponen ini agar asset, warna,
/// ketebalan lingkaran, bayangan, dan indikator status selalu konsisten.
class ChatbotIcon extends StatelessWidget {
  const ChatbotIcon({this.size = 56, super.key});

  static const String assetPath = 'assets/icons/boo.svg';

  final double size;

  @override
  Widget build(BuildContext context) {
    final outerPadding = size * (4 / 56);
    final statusSize = size * (12 / 56);
    final statusOffset = size * (4 / 56);
    final statusBorderWidth = size * (2 / 56);
    final shadowOffset = size * (6 / 56);
    final shadowBlur = size * (10 / 56);

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000),
              offset: Offset(0, shadowOffset),
              blurRadius: shadowBlur,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(outerPadding),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                right: -statusOffset,
                top: -statusOffset,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6BD8CB),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE4FFFB),
                      width: statusBorderWidth,
                    ),
                  ),
                  child: SizedBox.square(dimension: statusSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
