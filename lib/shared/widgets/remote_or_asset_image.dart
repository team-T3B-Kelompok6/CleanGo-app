import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/network/api_config.dart';

/// Shows a network image when [source] is an http(s) URL or backend-relative
/// upload path, and a bundled asset otherwise. SVG assets are supported.
class RemoteOrAssetImage extends StatelessWidget {
  const RemoteOrAssetImage({
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    super.key,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;

  bool get _isSvg => source.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    final value = source.trim();
    if (value.isEmpty) return _placeholder();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return _network(value);
    }
    if (value.startsWith('/')) {
      final resolved = ApiConfig.mediaUrl(value);
      if (resolved != null) return _network(resolved);
      return _placeholder();
    }
    if (_isSvg) {
      return SvgPicture.asset(
        value,
        fit: fit,
        width: width,
        height: height,
        placeholderBuilder: (_) => _placeholder(),
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return Image.asset(
      value,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _network(String url) {
    if (_isSvg) {
      return SvgPicture.network(
        url,
        fit: fit,
        width: width,
        height: height,
        placeholderBuilder: (_) => _placeholder(),
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => _placeholder(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(),
    );
  }

  Widget _placeholder() => SizedBox(
    width: width,
    height: height,
    child: ColoredBox(
      color: const Color(0xFFE8FAF7),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/service_placeholder.svg',
          width: (width ?? 48) * 0.5,
          height: (height ?? 48) * 0.5,
          colorFilter: const ColorFilter.mode(
            Color(0xFF00685F),
            BlendMode.srcIn,
          ),
        ),
      ),
    ),
  );
}
