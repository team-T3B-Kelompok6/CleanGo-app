import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServiceIcon extends StatelessWidget {
  const ServiceIcon({
    required this.path,
    this.size,
    this.color = const Color(0xFF00685F),
    super.key,
  });

  final String path;
  final double? size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );
  }
}
