import 'package:flutter/material.dart';

import 'remote_or_asset_image.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.source, this.size = 56, this.borderColor});

  final String? source;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final value = source?.trim() ?? '';
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderColor == null ? 0 : 2),
      decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor),
      child: ClipOval(child: value.isEmpty ? _fallback() : _image(value)),
    );
  }

  Widget _image(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, _, _) => _fallback(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _fallback(),
      );
    }
    return RemoteOrAssetImage(
      source: value,
      fit: BoxFit.cover,
      width: size,
      height: size,
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: const Color(0xFFE8FAF7),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.56,
        color: const Color(0xFF00685F),
      ),
    );
  }
}
