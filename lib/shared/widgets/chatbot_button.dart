import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'chatbot_icon.dart';

class ChatbotButton extends StatelessWidget {
  const ChatbotButton({
    this.onTap,
    this.diameter = height,
    this.labelColor = AppColors.primary,
    super.key,
  });

  static const double height = 56;

  final VoidCallback? onTap;
  final double diameter;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tanya Boo, buka chatbot CleanGo',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text.rich(
                  const TextSpan(
                    text: 'Tanya Boo! ',
                    children: [TextSpan(text: '✨')],
                  ),
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ChatbotIcon(size: diameter),
            ],
          ),
        ),
      ),
    );
  }
}
