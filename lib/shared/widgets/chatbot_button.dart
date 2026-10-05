import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'chatbot_icon.dart';

class ChatbotButton extends StatefulWidget {
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
  State<ChatbotButton> createState() => _ChatbotButtonState();
}

class _ChatbotButtonState extends State<ChatbotButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _bounce = Tween<double>(
      begin: 0,
      end: -7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tanya Boo, buka chatbot CleanGo',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
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
                    color: widget.labelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _bounce,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _bounce.value),
                  child: child,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ChatbotIcon(size: widget.diameter),
                    Positioned(
                      right: 1,
                      top: 1,
                      child: FadeTransition(
                        opacity: Tween<double>(begin: .35, end: 1).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5EEAD4),
                            shape: BoxShape.circle,
                          ),
                        ),
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
