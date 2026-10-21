import 'package:flutter/material.dart';

/// Shows a network image when [source] is an http(s) URL and a bundled asset
/// otherwise. Backend uploads (`/uploads/...`) are resolved to absolute URLs by
/// the service data layer, so a single widget can cover both cases.
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

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _placeholder(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(),
      );
    }
    return Image.asset(
      source,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => SizedBox(width: width, height: height);
}
