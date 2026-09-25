import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/chatbot_button.dart';
import '../widgets/popular_service_card.dart';
import '../widgets/service_category_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_CategoryData> _categories = [
    _CategoryData(
      iconPath: 'assets/icons/daily_cleaning.svg',
      label: 'Cleaning',
      accentText: 'harian',
    ),
    _CategoryData(iconPath: 'assets/icons/ac_wash.svg', label: 'Cuci AC'),
    _CategoryData(
      iconPath: 'assets/icons/deep_cleaning.svg',
      label: 'Deep\nCleaning',
    ),
    _CategoryData(
      iconPath: 'assets/icons/ironing.svg',
      label: 'Layanan\nSetrika',
    ),
    _CategoryData(
      iconPath: 'assets/icons/monthly_cleaning.svg',
      label: 'Cleaning',
      accentText: 'bulanan',
    ),
    _CategoryData(
      iconPath: 'assets/icons/sofa_mattress.svg',
      label: 'Sofa &\nKasur',
    ),
    _CategoryData(
      iconPath: 'assets/icons/ac_installation.svg',
      label: 'Pasang AC',
    ),
    _CategoryData(iconPath: 'assets/icons/office.svg', label: 'Kantor'),
  ];

  static const List<_PopularServiceData> _popularServices = [
    _PopularServiceData(
      imagePath: 'assets/images/deep_cleaning.jpeg',
      badge: 'Terlaris',
      badgeColor: AppColors.primary,
      badgeTextColor: Colors.white,
      rating: '4.9',
      reviewCount: '(1.2k)',
      title: 'Deep Cleaning Rumah',
      description: 'Sanitasi menyeluruh & debu vakum',
      duration: '2 - 3 Jam Pengerjaan',
      price: 'Rp150.000',
    ),
    _PopularServiceData(
      imagePath: 'assets/images/sofa_cleaning.jpeg',
      badge: 'Promo',
      badgeColor: AppColors.primaryBorder,
      badgeTextColor: AppColors.primary,
      rating: '4.8',
      reviewCount: '(850)',
      title: 'Cuci Sofa & Springbed',
      description: 'Ekstraksi tungau & noda membandel',
      duration: '1 - 2 Jam Pengerjaan',
      price: 'Rp120.000',
    ),
    _PopularServiceData(
      imagePath: 'assets/images/ac_service.jpeg',
      badge: 'Cepat',
      badgeColor: Color(0xFF006A61),
      badgeTextColor: Colors.white,
      rating: '4.9',
      reviewCount: '(2.1k)',
      title: 'Service & Cuci AC',
      description: 'Cuci unit, cek freon & antibakteri',
      duration: '45 - 60 Menit',
      price: 'Rp75.000',
      unit: '/unit',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double cardWidth = math.min(256, math.max(224, screenWidth * 0.70));
    final double contentSideInset = math.max(16, (screenWidth - 480) / 2 + 16);
    final double bottomContentSpacing =
        BottomNavigation.contentHeight +
        mediaQuery.viewPadding.bottom +
        ChatbotButton.height +
        40;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.white)),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SafeArea(
                  bottom: false,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: _HomeIntroSection()),
                      SliverToBoxAdapter(
                        child: _ServiceCategoriesSection(
                          categories: _categories,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _PopularServicesSection(
                          services: _popularServices,
                          cardWidth: cardWidth,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: bottomContentSpacing),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: contentSideInset,
              bottom:
                  BottomNavigation.contentHeight +
                  mediaQuery.viewPadding.bottom +
                  12,
              child: ChatbotButton(onTap: () {}),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      ),
    );
  }
}

class _HomeIntroSection extends StatelessWidget {
  const _HomeIntroSection();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF2FBFA),
            Color(0xFFF2FBFA),
            Color(0xFFE5FAF7),
            Color(0xFFD8F7F3),
          ],
          stops: [0, 0.52, 0.75, 1],
        ),
      ),
      child: Column(
        children: [_HomeHeader(), _SearchSection(), _PromoSection()],
      ),
    );
  }
}

class _ServiceCategoriesSection extends StatelessWidget {
  const _ServiceCategoriesSection({required this.categories});

  final List<_CategoryData> categories;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD8F7F3),
            Color(0xFFCFF5F0),
            Color(0xFFC5F0EA),
            Color(0xFFDDF7F3),
            Color(0xFFF5FCFB),
            Colors.white,
          ],
          stops: [0, 0.18, 0.55, 0.78, 0.92, 1],
        ),
      ),
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Layanan',
            actionLabel: 'Lihat semua',
            bottomPadding: 12,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              mainAxisExtent: 82,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ServiceCategoryItem(
                iconPath: category.iconPath,
                label: category.label,
                accentText: category.accentText,
                onTap: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBorder,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: const ClipOval(
                    child: Image(
                      image: AssetImage('assets/images/user_profile.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Halo, Krisna',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.heading,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.33,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '👋',
                            style: TextStyle(fontSize: 18, height: 1.33),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      _LocationLabel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Notifikasi',
            child: InkWell(
              onTap: () {},
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/notification.svg',
                        width: 15,
                        height: 19,
                      ),
                      const Positioned(
                        right: 8,
                        top: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.notification,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(width: 10, height: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationLabel extends StatelessWidget {
  const _LocationLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/icons/location.svg', width: 10, height: 12),
        const SizedBox(width: 4),
        const Text(
          'Malang',
          style: TextStyle(
            color: AppColors.body,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.33,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Semantics(
        textField: true,
        label: 'Cari layanan',
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                offset: Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/search.svg',
                width: 17,
                height: 17,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cari layanan deep clean, AC, sofa...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoSection extends StatelessWidget {
  const _PromoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 3,
            child: Image.asset(
              'assets/images/promo_banner.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: SizedBox(width: 24, height: 6),
              ),
              SizedBox(width: 8),
              _CarouselDot(),
              SizedBox(width: 8),
              _CarouselDot(),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarouselDot extends StatelessWidget {
  const _CarouselDot();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: SizedBox(width: 6, height: 6),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.bottomPadding,
  });

  final String title;
  final String actionLabel;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.sectionHeading,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.18,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryAction,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularServicesSection extends StatelessWidget {
  const _PopularServicesSection({
    required this.services,
    required this.cardWidth,
  });

  final List<_PopularServiceData> services;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Layanan Populer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.heading,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.33,
                          ),
                        ),
                        Text(
                          'Paling sering dipesan minggu ini',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.body,
                            fontSize: 12,
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.43,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 314,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: services.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return PopularServiceCard(
                    width: cardWidth,
                    imagePath: service.imagePath,
                    badge: service.badge,
                    badgeColor: service.badgeColor,
                    badgeTextColor: service.badgeTextColor,
                    rating: service.rating,
                    reviewCount: service.reviewCount,
                    title: service.title,
                    description: service.description,
                    duration: service.duration,
                    price: service.price,
                    unit: service.unit,
                    onTap: () {},
                    onAdd: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.iconPath,
    required this.label,
    this.accentText,
  });

  final String iconPath;
  final String label;
  final String? accentText;
}

class _PopularServiceData {
  const _PopularServiceData({
    required this.imagePath,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.rating,
    required this.reviewCount,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
    this.unit,
  });

  final String imagePath;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String rating;
  final String reviewCount;
  final String title;
  final String description;
  final String duration;
  final String price;
  final String? unit;
}
