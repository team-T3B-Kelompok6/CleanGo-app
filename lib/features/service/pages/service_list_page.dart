import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/chatbot_button.dart';
import '../../chatbot/pages/chatbot_page.dart';
import '../domain/models/service_model.dart';
import '../controllers/service_controller.dart';
import '../controllers/service_sort.dart';
import '../widgets/service_card.dart';
import 'service_detail_page.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  ServiceSort? _selectedSort;

  @override
  Widget build(BuildContext context) {
    final serviceController = context.watch<ServiceController>();
    final services = sortServices(
      serviceController.visibleServices,
      _selectedSort,
    );
    final mediaQuery = MediaQuery.of(context);
    final contentSideInset = ((mediaQuery.size.width - 480) / 2 + 16).clamp(
      16.0,
      double.infinity,
    );
    final bottomSpacing =
        BottomNavigation.contentHeight + mediaQuery.viewPadding.bottom + 88;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.screenBackground,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SafeArea(
                  bottom: false,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _ServiceListHeader(
                          filters: ServiceController.filters,
                          selectedFilter: serviceController.selectedFilter,
                          searchQuery: serviceController.searchQuery,
                          serviceCount: services.length,
                          onFilterSelected: serviceController.selectFilter,
                          onSearchChanged: serviceController.updateSearchQuery,
                          onSortTap: _showSortOptions,
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomSpacing),
                        sliver: SliverList.separated(
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return ServiceCard(
                              service: service,
                              onTap: () => _openServiceDetail(context, service),
                            );
                          },
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                        ),
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
                  14,
              child: ChatbotButton(onTap: () => _openChatbot(context)),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: 1,
          showOrderBadge: false,
          onDestinationSelected: (index) {
            if (index == 0) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (index == 2) {
              Navigator.pushNamed(context, AppRoutes.orders);
            } else if (index == 3) {
              Navigator.pushNamed(context, AppRoutes.messages);
            } else if (index == 4) {
              Navigator.pushNamed(context, AppRoutes.profile);
            }
          },
        ),
      ),
    );
  }

  void _openServiceDetail(BuildContext context, ServiceModel service) {
    context.read<ServiceController>().selectService(service);
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ServiceDetailPage()));
  }

  void _openChatbot(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const ChatbotPage()));
  }

  Future<void> _showSortOptions() async {
    final selected = await showModalBottomSheet<ServiceSort>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _SortBottomSheet(selectedSort: _selectedSort),
    );

    if (selected == null || selected == _selectedSort || !mounted) {
      return;
    }

    setState(() => _selectedSort = selected);
  }
}

class _ServiceListHeader extends StatelessWidget {
  const _ServiceListHeader({
    required this.filters,
    required this.selectedFilter,
    required this.searchQuery,
    required this.serviceCount,
    required this.onFilterSelected,
    required this.onSearchChanged,
    required this.onSortTap,
  });

  final List<String> filters;
  final String selectedFilter;
  final String searchQuery;
  final int serviceCount;
  final ValueChanged<String> onFilterSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              _RoundIconButton(
                label: 'Kembali',
                iconPath: 'assets/icons/back.svg',
                onTap: () => Navigator.maybePop(context),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Daftar Layanan',
                  style: TextStyle(
                    color: AppColors.slate900,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            initialValue: searchQuery,
            onChanged: onSearchChanged,
            style: const TextStyle(
              color: AppColors.slate900,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Cari layanan (misal: AC, sofa, deep clean)...',
              hintStyle: const TextStyle(
                color: AppColors.slate400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/service_search.svg',
                  width: 16,
                  height: 16,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 48,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.slate100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final selected = selectedFilter == filter;
              return Material(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () => onFilterSelected(filter),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.slate200,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.slate600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Tersedia $serviceCount Layanan',
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
              ),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: onSortTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/sort.svg',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Urutkan',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.27,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SortBottomSheet extends StatelessWidget {
  const _SortBottomSheet({required this.selectedSort});

  final ServiceSort? selectedSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'Urutkan layanan',
              style: TextStyle(
                color: AppColors.slate900,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          ...ServiceSort.values.map(
            (sort) => _SortOption(
              sort: sort,
              selected: sort == selectedSort,
              onTap: () => Navigator.pop(context, sort),
            ),
          ),
          SizedBox(height: 12 + MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.sort,
    required this.selected,
    required this.onTap,
  });

  final ServiceSort sort;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  sort.label,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.slate600,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox.square(
                dimension: 48,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.slate200,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: Colors.white,
                          )
                        : null,
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

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 40,
            child: Center(
              child: SvgPicture.asset(iconPath, width: 16, height: 16),
            ),
          ),
        ),
      ),
    );
  }
}
