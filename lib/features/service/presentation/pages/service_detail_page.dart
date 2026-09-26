import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../../booking/presentation/pages/booking_page.dart';
import '../../domain/models/service_model.dart';
import '../controllers/service_controller.dart';

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({super.key});

  static const _cardBorder = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final service = context.select<ServiceController, ServiceModel?>(
      (controller) => controller.selectedService,
    );

    if (service == null) {
      return const _MissingServicePage();
    }

    final mediaQuery = MediaQuery.of(context);
    final contentBottomPadding = 124 + mediaQuery.padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.screenBackground,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _Hero(service: service)),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        14,
                        16,
                        contentBottomPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _DetailContent(service: service),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BookingBar(
                service: service,
                onPressed: () => _openBooking(context, service),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBooking(BuildContext context, ServiceModel service) {
    context.read<BookingController>().startBooking(service);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookingPage(service: service)),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    final imagePath = service.detail?.heroImagePath ?? service.imagePath;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imagePath != null)
                Image.asset(imagePath, fit: BoxFit.cover)
              else
                const ColoredBox(color: AppColors.slate200),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x20000000), Colors.transparent],
                    stops: [0, 0.42],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 16),
                    child: _BackButton(
                      onPressed: () => Navigator.maybePop(context),
                    ),
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali',
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(
          side: BorderSide(color: ServiceDetailPage._cardBorder),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 40,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/detail_back.svg',
                width: 15,
                height: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    final detail = service.detail;
    final rating = detail?.rating ?? service.rating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ServiceSummaryCard(
          service: service,
          rating: rating,
          reviewCount: detail?.reviewCount,
        ),
        const SizedBox(height: 12),
        _DetailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Deskripsi Layanan'),
              const SizedBox(height: 10),
              Text(
                detail?.description ?? service.description,
                style: const TextStyle(
                  color: AppColors.slate600,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.625,
                ),
              ),
            ],
          ),
        ),
        if (detail != null && detail.benefits.isNotEmpty) ...[
          const SizedBox(height: 12),
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Termasuk:'),
                const SizedBox(height: 14),
                ...detail.benefits.indexed.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.$1 == detail.benefits.length - 1 ? 0 : 12,
                    ),
                    child: _BenefitItem(label: entry.$2),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (detail != null && detail.reviews.isNotEmpty) ...[
          const SizedBox(height: 12),
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ReviewHeader(),
                const SizedBox(height: 14),
                ...detail.reviews.indexed.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.$1 == detail.reviews.length - 1 ? 0 : 10,
                    ),
                    child: _ReviewItem(review: entry.$2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ServiceSummaryCard extends StatelessWidget {
  const _ServiceSummaryCard({
    required this.service,
    required this.rating,
    required this.reviewCount,
  });

  final ServiceModel service;
  final String? rating;
  final String? reviewCount;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title,
            style: const TextStyle(
              color: AppColors.slate900,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: -0.2,
            ),
          ),
          if (rating != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/detail_rating_star.svg',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  rating!,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (reviewCount != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($reviewCount)',
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: _DashedDivider(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  service.price,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: Text(
                  'Durasi: ${service.duration.replaceFirst('±', '').trim()}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ServiceDetailPage._cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.slate900,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary),
          ),
          child: SvgPicture.asset(
            'assets/icons/detail_check.svg',
            width: 12,
            height: 9,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.slate600,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _SectionTitle('Ulasan Pengguna')),
        const Text(
          'Lihat Semua',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        SvgPicture.asset(
          'assets/icons/detail_chevron.svg',
          width: 5,
          height: 8,
        ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review});

  final ServiceReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.screenBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ServiceDetailPage._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.name,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  review.rating,
                  (_) => Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: SvgPicture.asset(
                      'assets/icons/detail_review_star.svg',
                      width: 12,
                      height: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '“${review.comment}”',
            style: const TextStyle(
              color: AppColors.slate600,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.58,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const gap = 5.0;
        final count = (constraints.maxWidth / (dashWidth + gap)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => const SizedBox(
              width: dashWidth,
              height: 1,
              child: ColoredBox(color: AppColors.slate200),
            ),
          ),
        );
      },
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.service, required this.onPressed});

  final ServiceModel service;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            border: const Border(
              top: BorderSide(color: ServiceDetailPage._cardBorder),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 18,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Builder(
              builder: (context) {
                final sideInset =
                    ((MediaQuery.sizeOf(context).width - 480) / 2 + 16).clamp(
                      16.0,
                      double.infinity,
                    );

                return Padding(
                  padding: EdgeInsets.fromLTRB(sideInset, 14, sideInset, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ESTIMASI TOTAL',
                              style: TextStyle(
                                color: AppColors.slate400,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.75,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              service.price,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: onPressed,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Pesan Sekarang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingServicePage extends StatelessWidget {
  const _MissingServicePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        title: const Text('Detail Layanan'),
      ),
      body: const Center(
        child: Text(
          'Layanan belum dipilih.',
          style: TextStyle(color: AppColors.slate600),
        ),
      ),
    );
  }
}
