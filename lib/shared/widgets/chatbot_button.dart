import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';

class ChatbotButton extends StatelessWidget {
  const ChatbotButton({
    this.onTap,
    this.diameter = height,
    this.iconPath = 'assets/icons/pandy.svg',
    this.outlined = false,
    this.showStatus = true,
    this.labelColor = AppColors.primary,
    super.key,
  });

  static const double height = 56;

  final VoidCallback? onTap;
  final double diameter;
  final String iconPath;
  final bool outlined;
  final bool showStatus;
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
              Container(
                width: diameter,
                height: diameter,
                padding: EdgeInsets.all(outlined ? 2 : 4),
                decoration: BoxDecoration(
                  color: outlined ? Colors.white : AppColors.primary,
                  shape: BoxShape.circle,
                  border: outlined
                      ? Border.all(color: const Color(0xFF14B8A6), width: 2)
                      : null,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 6),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: SvgPicture.asset(iconPath)),
                    ),
                    if (showStatus)
                      const Positioned(
                        right: -4,
                        top: -4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFF6BD8CB),
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Color(0xFFE4FFFB), width: 2),
                            ),
                          ),
                          child: SizedBox.square(dimension: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
