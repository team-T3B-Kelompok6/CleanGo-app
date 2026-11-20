import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/home_controller.dart';

class PromoBannerSection extends StatefulWidget {
  const PromoBannerSection({
    super.key,
    required this.bannerPaths,
    required this.status,
    required this.onRetry,
  });

  final List<String> bannerPaths;
  final BannerStatus status;
  final VoidCallback onRetry;

  @override
  State<PromoBannerSection> createState() => _PromoBannerSectionState();
}

class _PromoBannerSectionState extends State<PromoBannerSection>
    with WidgetsBindingObserver {
  late PageController _pages;
  Timer? _timer;
  int _page = 0;
  bool _foreground = true;
  bool _touching = false;
  bool _scrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _pages = PageController();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant PromoBannerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.bannerPaths, widget.bannerPaths)) {
      final previous = _pages;
      _pages = PageController();
      _page = 0;
      _scrolling = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (!_foreground ||
        _touching ||
        _scrolling ||
        widget.bannerPaths.length < 2) {
      return;
    }
    _timer = Timer(const Duration(seconds: 6), () {
      if (!mounted || !_pages.hasClients) return;
      _pages.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _schedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  Widget _failure() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('Gagal memuat promo'),
      TextButton(onPressed: widget.onRetry, child: const Text('Coba lagi')),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final paths = widget.bannerPaths;
    Widget content;
    if (paths.isEmpty) {
      content = switch (widget.status) {
        BannerStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        BannerStatus.error => _failure(),
        BannerStatus.success => Image.asset(
          'assets/images/no_active_promos.png',
          fit: BoxFit.contain,
          semanticLabel: 'Belum Ada Promo',
        ),
      };
    } else if (paths.length == 1) {
      content = _BannerImage(source: paths.single);
    } else {
      content = Listener(
        onPointerDown: (_) {
          _touching = true;
          _schedule();
        },
        onPointerUp: (_) {
          _touching = false;
          _schedule();
        },
        onPointerCancel: (_) {
          _touching = false;
          _schedule();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.depth != 0) return false;
            if (notification is ScrollStartNotification) {
              _scrolling = true;
              _schedule();
            } else if (notification is ScrollEndNotification) {
              _scrolling = false;
              _schedule();
            }
            return false;
          },
          child: PageView.builder(
            key: ObjectKey(_pages),
            controller: _pages,
            onPageChanged: (page) => setState(() => _page = page),
            // Indeks virtual terus maju; modulo hanya memilih gambar.
            itemBuilder: (context, index) => Semantics(
              image: true,
              label: 'Promo ${index % paths.length + 1} dari ${paths.length}',
              child: _BannerImage(source: paths[index % paths.length]),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2170 / 725,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: content,
            ),
          ),
          if (paths.isNotEmpty && widget.status == BannerStatus.error)
            _failure(),
          if (paths.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(paths.length, (index) {
                final selected = _page % paths.length == index;
                return Semantics(
                  selected: selected,
                  label: 'Buka promo ${index + 1}',
                  child: IconButton(
                    onPressed: () {
                      _schedule();
                      final delta =
                          (index - _page % paths.length + paths.length) %
                          paths.length;
                      _pages.animateToPage(
                        _page + delta,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    icon: Icon(
                      Icons.circle,
                      size: selected ? 10 : 6,
                      color: selected
                          ? AppColors.primary
                          : AppColors.primarySoft,
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.source});
  final String source;

  @override
  Widget build(BuildContext context) {
    Widget failure(BuildContext context, Object error, StackTrace? stack) =>
        const Center(child: Text('Gagal memuat gambar promo'));
    final uri = Uri.tryParse(source);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https')
        ? Image.network(source, fit: BoxFit.cover, errorBuilder: failure)
        : Image.asset(source, fit: BoxFit.cover, errorBuilder: failure);
  }
}
