import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/chatbot_button.dart';
import '../../data/home_data.dart';
import '../../domain/models/popular_service_model.dart';
import '../../domain/models/service_category_model.dart';
import '../../../service/presentation/controllers/service_controller.dart';
import '../../../service/presentation/pages/service_detail_page.dart';
import '../widgets/popular_service_card.dart';
import '../widgets/service_category_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                          categories: HomeData.categories,
                          onViewAll: () => _openServices(context),
                          onServiceSelected: (serviceId) =>
                              _openServiceDetail(context, serviceId),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _PopularServicesSection(
                          services: HomeData.popularServices,
                          cardWidth: cardWidth,
                          onViewAll: () => _openServices(context),
                          onServiceSelected: (serviceId) =>
                              _openServiceDetail(context, serviceId),
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
          onDestinationSelected: (index) {
            if (index == 1) {
              _openServices(context);
            }
          },
        ),
      ),
    );
  }

  void _openServices(BuildContext context) {
    context.read<ServiceController>().resetFilters();
    Navigator.pushNamed(context, AppRoutes.services);
  }

  void _openServiceDetail(BuildContext context, String? serviceId) {
    final controller = context.read<ServiceController>();
    final service = controller.findServiceById(serviceId);

    if (service == null) {
      _openServices(context);
      return;
    }

    controller.selectService(service);
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ServiceDetailPage()));
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
        children: [
          _HomeHeader(),
          _PromoSection(bannerPaths: HomeData.promoBanners),
        ],
      ),
    );
  }
}

class _ServiceCategoriesSection extends StatelessWidget {
  const _ServiceCategoriesSection({
    required this.categories,
    required this.onViewAll,
    required this.onServiceSelected,
  });

  final List<ServiceCategoryModel> categories;
  final VoidCallback onViewAll;
  final ValueChanged<String?> onServiceSelected;

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
          _SectionHeader(
            title: 'Layanan',
            actionLabel: 'Lihat semua',
            bottomPadding: 12,
            onActionPressed: onViewAll,
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
                onTap: () => onServiceSelected(category.serviceId),
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

class _PromoSection extends StatefulWidget {
  const _PromoSection({required this.bannerPaths});

  final List<String> bannerPaths;

  @override
  State<_PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends State<_PromoSection> {
  late final PageController _pageController;
  int _activePage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 3,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.bannerPaths.length,
              onPageChanged: (page) {
                setState(() => _activePage = page);
              },
              itemBuilder: (context, index) {
                return Semantics(
                  image: true,
                  label: 'Promo ${index + 1} dari ${widget.bannerPaths.length}',
                  child: Image.asset(
                    widget.bannerPaths[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.bannerPaths.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index == widget.bannerPaths.length - 1 ? 0 : 8,
                ),
                child: _CarouselIndicator(
                  selected: _activePage == index,
                  onTap: () => _selectPage(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselIndicator extends StatelessWidget {
  const _CarouselIndicator({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? 'Promo aktif' : 'Buka promo',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: selected ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.bottomPadding,
    required this.onActionPressed,
  });

  final String title;
  final String actionLabel;
  final double bottomPadding;
  final VoidCallback onActionPressed;

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
            onPressed: onActionPressed,
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
    required this.onViewAll,
    required this.onServiceSelected,
  });

  final List<PopularServiceModel> services;
  final double cardWidth;
  final VoidCallback onViewAll;
  final ValueChanged<String> onServiceSelected;

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
                    onPressed: onViewAll,
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
                    service: service,
                    onTap: () => onServiceSelected(service.serviceId),
                    onAdd: () => onServiceSelected(service.serviceId),
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
