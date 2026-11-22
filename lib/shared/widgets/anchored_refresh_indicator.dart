import 'package:flutter/material.dart';

/// RefreshIndicator yang menjaga konten tetap diam saat overscroll.
///
/// ClampingScrollPhysics menahan pixels, tetapi Material 3 tetap menambahkan
/// StretchingOverscrollIndicator yang menggeser konten. ScrollConfiguration
/// di sini mematikan dekorasi overscroll, sehingga hanya indikatornya yang
/// bergerak.
class AnchoredRefreshIndicator extends StatelessWidget {
  const AnchoredRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final RefreshCallback onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: RefreshIndicator(onRefresh: onRefresh, child: child),
    );
  }
}
