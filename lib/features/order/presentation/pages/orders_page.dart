import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/chatbot_button.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../../service/presentation/pages/service_detail_page.dart';
import '../../data/order_data.dart';
import '../../domain/models/order_model.dart';

enum _OrdersTab { scheduled, history }

class OrdersPage extends StatefulWidget {
  const OrdersPage({this.onTrackOrder, super.key});

  final VoidCallback? onTrackOrder;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  _OrdersTab _selectedTab = _OrdersTab.scheduled;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bookingAddress = context.watch<BookingController>().address;
    final scheduledAddress =
        '${bookingAddress.street}, ${bookingAddress.city} '
        '(${bookingAddress.landmark})';
    final contentSideInset = ((mediaQuery.size.width - 480) / 2 + 16).clamp(
      16.0,
      double.infinity,
    );
    final bottomSpacing =
        BottomNavigation.contentHeight + mediaQuery.viewPadding.bottom + 86;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.screenBackground,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _OrdersHeader(),
                      _OrdersTabs(
                        selectedTab: _selectedTab,
                        onSelected: (tab) {
                          if (tab == _selectedTab) {
                            return;
                          }
                          setState(() => _selectedTab = tab);
                        },
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _selectedTab == _OrdersTab.scheduled
                              ? _ScheduledOrdersView(
                                  key: const ValueKey('scheduled'),
                                  bottomSpacing: bottomSpacing,
                                  address: scheduledAddress,
                                  onTrackOrder: widget.onTrackOrder ?? () {},
                                )
                              : _OrderHistoryView(
                                  key: const ValueKey('history'),
                                  bottomSpacing: bottomSpacing,
                                ),
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
                  12,
              child: ChatbotButton(onTap: () => _openChatbot(context)),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: 2,
          showOrderBadge: false,
          onDestinationSelected: (index) => _handleNavigation(context, index),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.services);
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, AppRoutes.messages);
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    }
  }

  void _openChatbot(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const ChatbotPage()));
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Text(
        'Pesanan',
        style: TextStyle(
          color: AppColors.slate900,
          fontFamily: AppTheme.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}

class _OrdersTabs extends StatelessWidget {
  const _OrdersTabs({required this.selectedTab, required this.onSelected});

  final _OrdersTab selectedTab;
  final ValueChanged<_OrdersTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: Row(
        children: [
          _OrderTabButton(
            label: 'Terjadwal',
            icon: Icons.calendar_month_outlined,
            selected: selectedTab == _OrdersTab.scheduled,
            onTap: () => onSelected(_OrdersTab.scheduled),
          ),
          _OrderTabButton(
            label: 'Riwayat',
            icon: Icons.receipt_long_outlined,
            selected: selectedTab == _OrdersTab.history,
            onTap: () => onSelected(_OrdersTab.history),
          ),
        ],
      ),
    );
  }
}

class _OrderTabButton extends StatelessWidget {
  const _OrderTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryAction : AppColors.slate400;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                height: 2,
                color: selected ? AppColors.primaryAction : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduledOrdersView extends StatelessWidget {
  const _ScheduledOrdersView({
    required this.bottomSpacing,
    required this.address,
    required this.onTrackOrder,
    super.key,
  });

  final double bottomSpacing;
  final String address;
  final VoidCallback onTrackOrder;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomSpacing),
      children: [
        _ScheduledOrderCard(
          order: OrderData.scheduledOrder,
          address: address,
          onTrackOrder: onTrackOrder,
        ),
      ],
    );
  }
}

class _ScheduledOrderCard extends StatelessWidget {
  const _ScheduledOrderCard({
    required this.order,
    required this.address,
    required this.onTrackOrder,
  });

  final ScheduledOrderModel order;
  final String address;
  final VoidCallback onTrackOrder;

  @override
  Widget build(BuildContext context) {
    return _OrderSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryAction,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            order.status,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.arrivalEstimate,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.travelDescription,
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8FAF7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bike_outlined,
                  color: AppColors.primaryAction,
                  size: 23,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: AppColors.primary),
                  ),
                  FractionallySizedBox(
                    widthFactor: order.progress,
                    child: const ColoredBox(color: AppColors.primaryAction),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceVisual(assetPath: order.serviceImagePath, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceName,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.price,
                    style: const TextStyle(
                      color: AppColors.primaryAction,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    order.paymentStatus,
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryAction,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: onTrackOrder,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryAction,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.navigation_outlined, size: 16),
              label: const Text(
                'Lacak Pesanan',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView({required this.bottomSpacing, super.key});

  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomSpacing),
      itemCount: OrderData.history.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _HistoryOrderCard(order: OrderData.history[index]);
      },
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  const _HistoryOrderCard({required this.order});

  final OrderHistoryModel order;

  @override
  Widget build(BuildContext context) {
    return _OrderSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceVisual(assetPath: order.serviceAssetPath),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceName,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.schedule,
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FAF2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    color: Color(0xFF159466),
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.screenBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8FAF7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: AppColors.primaryAction,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(
                      color: AppColors.slate600,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                Text(
                  order.price,
                  style: const TextStyle(
                    color: AppColors.primaryAction,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (order.canReview)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () => _openReviewDialog(context, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryAction,
                        backgroundColor: const Color(0xFFF8FCFB),
                        side: const BorderSide(color: AppColors.primaryBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(
                        Icons.star_rounded,
                        size: 17,
                        color: Color(0xFFF59E0B),
                      ),
                      label: const Text(
                        'Beri Ulasan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: () => _handleReorder(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryAction,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text(
                        'Pesan Lagi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () => _openOrderDetail(context, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slate600,
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: const BorderSide(color: AppColors.slate200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        size: 16,
                        color: AppColors.slate500,
                      ),
                      label: const Text(
                        'Lihat Detail',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: () => _handleReorder(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryAction,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text(
                        'Pesan Lagi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openOrderDetail(BuildContext context, OrderHistoryModel order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x730F172A),
      builder: (context) => _HistoryOrderDetailBottomSheet(
        order: order,
        onReorder: () {
          Navigator.pop(context);
          _handleReorder(context);
        },
      ),
    );
  }

  void _openReviewDialog(BuildContext context, OrderHistoryModel order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x730F172A),
      builder: (context) => _ReviewBottomSheet(order: order),
    );
  }

  void _handleReorder(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ServiceDetailPage(),
      ),
    );
  }
}

class _ServiceVisual extends StatelessWidget {
  const _ServiceVisual({required this.assetPath, this.size = 42});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isImage = assetPath.endsWith('.jpeg') || assetPath.endsWith('.jpg');

    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: isImage
            ? Image.asset(assetPath, fit: BoxFit.cover)
            : ColoredBox(
                color: const Color(0xFFE8FAF7),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryAction,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  const _ReviewBottomSheet({required this.order});

  final OrderHistoryModel order;

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedTags = {};

  static const List<String> _quickTags = [
    'Tepat Waktu',
    'Bersih & Rapi',
    'Peralatan Lengkap',
    'Ramah & Sopan',
    'Puas Banget',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFBEB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Beri Ulasan Layanan',
                            style: TextStyle(
                              color: AppColors.slate900,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.order.serviceName,
                            style: const TextStyle(
                              color: AppColors.slate500,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Bagaimana kepuasan Anda?',
                        style: TextStyle(
                          color: AppColors.slate600,
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          final isSelected = star <= _selectedRating;
                          return IconButton(
                            onPressed: () {
                              setState(() => _selectedRating = star);
                            },
                            iconSize: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.star_rounded,
                              color: isSelected
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFE2E8F0),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hal yang disukai:',
                  style: TextStyle(
                    color: AppColors.slate600,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTags.remove(tag);
                          } else {
                            _selectedTags.add(tag);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8FAF7)
                              : AppColors.screenBackground,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryAction
                                : AppColors.slate200,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryAction
                                : AppColors.slate600,
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: AppColors.slate900,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar atau pengalaman Anda (opsional)...',
                    hintStyle: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      color: AppColors.slate400,
                    ),
                    filled: true,
                    fillColor: AppColors.screenBackground,
                    contentPadding: const EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.slate200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primaryAction),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Terima kasih! Ulasan Anda telah terkirim.',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.primaryAction,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryAction,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Kirim Ulasan',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _OrderSurface extends StatelessWidget {
  const _OrderSurface({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HistoryOrderDetailBottomSheet extends StatelessWidget {
  const _HistoryOrderDetailBottomSheet({
    required this.order,
    required this.onReorder,
  });

  final OrderHistoryModel order;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8FAF7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primaryAction,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Riwayat Pesanan',
                            style: TextStyle(
                              color: AppColors.slate900,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.schedule,
                            style: const TextStyle(
                              color: AppColors.slate500,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9FAF2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        order.status,
                        style: const TextStyle(
                          color: Color(0xFF159466),
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (order.rating != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 22,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ulasan Anda: ${order.rating!.toStringAsFixed(1)} / 5.0',
                                style: const TextStyle(
                                  color: Color(0xFF92400E),
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Terima kasih atas penilaian yang telah Anda berikan.',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.screenBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate100),
                  ),
                  child: Column(
                    children: [
                      _HistoryDetailRow(
                        label: 'Layanan',
                        value: order.serviceName,
                      ),
                      const SizedBox(height: 10),
                      _HistoryDetailRow(
                        label: 'Jadwal',
                        value: order.schedule,
                      ),
                      const SizedBox(height: 10),
                      _HistoryDetailRow(
                        label: 'Pelanggan',
                        value: order.customerName,
                      ),
                      const SizedBox(height: 10),
                      _HistoryDetailRow(
                        label: 'Status',
                        value: order.status,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppColors.slate200),
                      ),
                      _HistoryDetailRow(
                        label: 'Total Biaya',
                        value: order.price,
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: onReorder,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryAction,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      'Pesan Layanan Ini Lagi',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _HistoryDetailRow extends StatelessWidget {
  const _HistoryDetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.slate900 : AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: emphasized ? AppColors.primaryAction : AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: emphasized ? 15 : 12,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
