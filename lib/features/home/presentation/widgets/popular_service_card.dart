import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/popular_service_model.dart';

class PopularServiceCard extends StatelessWidget {
  const PopularServiceCard({
    required this.width,
    required this.service,
    this.onTap,
    this.onAdd,
    super.key,
  });

  final double width;
  final PopularServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final double imageHeight = width * 0.5625;

    return SizedBox(
      width: width,
      height: 306,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2EEEC)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18002F2A),
              offset: Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ColoredBox(
                            color: AppColors.primaryContainer,
                            child: Image.asset(
                              service.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: _Badge(
                            label: service.badge,
                            backgroundColor: _badgeBackgroundColor,
                            textColor: _badgeTextColor,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _RatingBadge(
                            rating: service.rating,
                            reviewCount: service.reviewCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.heading,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.375,
                    ),
                  ),
                  Text(
                    service.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.body,
                      fontSize: 12,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/clock.svg',
                        width: 13,
                        height: 13,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          service.duration,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            height: 1.33,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Mulai dari',
                              style: TextStyle(
                                color: AppColors.body,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: 0.4,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: service.price,
                                children: service.unit == null
                                    ? const []
                                    : [
                                        TextSpan(
                                          text: service.unit,
                                          style: const TextStyle(
                                            color: AppColors.body,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.375,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          onPressed: onAdd,
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: SvgPicture.asset(
                            'assets/icons/add.svg',
                            width: 12,
                            height: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get _badgeBackgroundColor => switch (service.badgeStyle) {
    PopularServiceBadgeStyle.primary => AppColors.primary,
    PopularServiceBadgeStyle.soft => AppColors.primaryBorder,
    PopularServiceBadgeStyle.dark => const Color(0xFF006A61),
  };

  Color get _badgeTextColor => switch (service.badgeStyle) {
    PopularServiceBadgeStyle.soft => AppColors.primary,
    PopularServiceBadgeStyle.primary ||
    PopularServiceBadgeStyle.dark => Colors.white,
  };
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.reviewCount});

  final String rating;
  final String reviewCount;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/star.svg', width: 11, height: 11),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  color: AppColors.heading,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                reviewCount,
                style: const TextStyle(
                  color: AppColors.body,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
