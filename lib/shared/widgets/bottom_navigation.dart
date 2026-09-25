import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.currentIndex,
    this.onDestinationSelected,
    super.key,
  });

  static const double contentHeight = 82;

  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;

  static const List<_NavigationDestinationData> _destinations = [
    _NavigationDestinationData(
      iconPath: 'assets/icons/home.svg',
      label: 'Beranda',
    ),
    _NavigationDestinationData(
      iconPath: 'assets/icons/services.svg',
      label: 'Layanan',
    ),
    _NavigationDestinationData(
      iconPath: 'assets/icons/orders.svg',
      label: 'Pesanan',
      iconExtent: 32,
    ),
    _NavigationDestinationData(
      iconPath: 'assets/icons/messages.svg',
      label: 'Pesan',
    ),
    _NavigationDestinationData(
      iconPath: 'assets/icons/profile.svg',
      label: 'Akun',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: contentHeight,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Row(
                    children: List.generate(_destinations.length, (index) {
                      final destination = _destinations[index];
                      return _BottomNavigationItem(
                        iconPath: destination.iconPath,
                        label: destination.label,
                        active: currentIndex == index,
                        iconExtent: destination.iconExtent,
                        onTap: () => onDestinationSelected?.call(index),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    required this.iconPath,
    required this.label,
    required this.active,
    required this.iconExtent,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool active;
  final double iconExtent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 34,
                  child: Center(
                    child: SizedBox.square(
                      dimension: iconExtent,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SvgPicture.asset(iconPath),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: active ? AppColors.primary : AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.27,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationDestinationData {
  const _NavigationDestinationData({
    required this.iconPath,
    required this.label,
    this.iconExtent = 24,
  });

  final String iconPath;
  final String label;
  final double iconExtent;
}
