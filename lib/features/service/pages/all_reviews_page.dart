import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/models/service_model.dart';
import '../widgets/review_card.dart';

class AllReviewsPage extends StatefulWidget {
  const AllReviewsPage({super.key, required this.service});

  final ServiceModel service;

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  static const _filters = ['Semua', 'Terbaru', 'Tertinggi', 'Terendah'];

  String _selectedFilter = _filters.first;

  List<ServiceReviewModel> get _visibleReviews {
    final reviews = List<ServiceReviewModel>.of(
      widget.service.detail?.reviews ?? const [],
    );

    switch (_selectedFilter) {
      case 'Tertinggi':
        reviews.sort((first, second) => second.rating.compareTo(first.rating));
      case 'Terendah':
        reviews.sort((first, second) => first.rating.compareTo(second.rating));
    }

    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.service.detail;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  _ReviewsHeader(serviceName: widget.service.title),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                      itemCount: _visibleReviews.length + 3,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _RatingSummary(
                            rating:
                                detail?.rating ??
                                widget.service.rating ??
                                '0.0',
                            reviewCount: detail?.reviewCount ?? '0 ulasan',
                            satisfactionPercentage:
                                detail?.satisfactionPercentage ?? 0,
                          );
                        }

                        if (index == 1) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: _ReviewFilters(
                              filters: _filters,
                              selectedFilter: _selectedFilter,
                              onSelected: (filter) {
                                setState(() => _selectedFilter = filter);
                              },
                            ),
                          );
                        }

                        if (index == _visibleReviews.length + 2) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: _LoadMoreButton(),
                          );
                        }

                        final review = _visibleReviews[index - 2];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ServiceReviewCard(review: review),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewsHeader extends StatelessWidget {
  const _ReviewsHeader({required this.serviceName});

  final String serviceName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: Row(
        children: [
          Material(
            color: AppColors.screenBackground,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => Navigator.pop(context),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ulasan Pengguna',
                  style: TextStyle(
                    color: AppColors.slate900,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.rating,
    required this.reviewCount,
    required this.satisfactionPercentage,
  });

  final String rating;
  final String reviewCount;
  final int satisfactionPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                const RatingStars(rating: 5, size: 13),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$satisfactionPercentage% Pelanggan Puas',
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$reviewCount terverifikasi',
                style: const TextStyle(
                  color: AppColors.slate400,
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewFilters extends StatelessWidget {
  const _ReviewFilters({
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.primaryAction,
            side: BorderSide(
              color: isSelected ? AppColors.primaryAction : AppColors.slate200,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 9),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.slate500,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: () {},
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
        label: const Text('Tampilkan Lebih Banyak'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.slate600,
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.slate200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
