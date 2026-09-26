import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.currentIndex,
    this.onDestinationSelected,
    this.inactiveColor = AppColors.slate400,
    this.showOrderBadge = true,
    this.showActiveIndicator = true,
    super.key,
  });

  static const double contentHeight = 82;

  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Color inactiveColor;
  final bool showOrderBadge;
  final bool showActiveIndicator;

  static const List<_NavigationDestinationData> _destinations = [
    _NavigationDestinationData(
      activeIconPath: 'assets/icons/home.svg',
      inactiveIconPath: 'assets/icons/nav_home_inactive.svg',
      label: 'Beranda',
    ),
    _NavigationDestinationData(
      activeIconPath: 'assets/icons/nav_services_active.svg',
      inactiveIconPath: 'assets/icons/services.svg',
      label: 'Layanan',
    ),
    _NavigationDestinationData(
      activeIconPath: 'assets/icons/nav_orders_inactive.svg',
      inactiveIconPath: 'assets/icons/nav_orders_inactive.svg',
      label: 'Pesanan',
    ),
    _NavigationDestinationData(
      activeIconPath: 'assets/icons/nav_messages_inactive.svg',
      inactiveIconPath: 'assets/icons/nav_messages_inactive.svg',
      label: 'Pesan',
    ),
    _NavigationDestinationData(
      activeIconPath: 'assets/icons/nav_profile_inactive.svg',
      inactiveIconPath: 'assets/icons/nav_profile_inactive.svg',
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
                      final active = currentIndex == index;
                      return _BottomNavigationItem(
                        iconPath: active
                            ? destination.activeIconPath
                            : destination.inactiveIconPath,
                        label: destination.label,
                        active: active,
                        iconExtent: 24,
                        inactiveColor: inactiveColor,
                        showBadge: showOrderBadge && index == 2,
                        showActiveIndicator: showActiveIndicator,
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
    required this.inactiveColor,
    required this.showBadge,
    required this.showActiveIndicator,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool active;
  final double iconExtent;
  final Color inactiveColor;
  final bool showBadge;
  final bool showActiveIndicator;
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
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        SizedBox.square(
                          dimension: iconExtent,
                          child: SvgPicture.asset(
                            iconPath,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              active ? AppColors.primary : inactiveColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        if (showBadge)
                          const Positioned(
                            right: 1,
                            top: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.primaryAction,
                                shape: BoxShape.circle,
                              ),
                              child: SizedBox.square(dimension: 8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: active ? AppColors.primary : inactiveColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.27,
                    letterSpacing: 0.2,
                  ),
                ),
                if (showActiveIndicator) ...[
                  const SizedBox(height: 2),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 4),
                  ),
                ],
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
    required this.activeIconPath,
    required this.inactiveIconPath,
    required this.label,
  });

  final String activeIconPath;
  final String inactiveIconPath;
  final String label;
}
