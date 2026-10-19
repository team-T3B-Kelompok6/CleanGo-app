import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_notice.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/widgets/chatbot_button.dart';
import '../../chatbot/pages/chatbot_page.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../booking/pages/booking_page.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../service/controllers/service_controller.dart';
import '../controllers/order_controller.dart';
import '../domain/models/order_model.dart';
import 'history_order_detail_page.dart';
import 'review_rating_page.dart';

enum OrdersTab { scheduled, history }

class OrdersPage extends StatefulWidget {
  const OrdersPage({
    this.initialTab = OrdersTab.scheduled,
    this.onTrackOrder,
    super.key,
  });

  final OrdersTab initialTab;
  final VoidCallback? onTrackOrder;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late OrdersTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is OrdersTab) {
      _selectedTab = args;
    } else if (args is String) {
      if (args == 'history') {
        _selectedTab = OrdersTab.history;
      } else if (args == 'scheduled') {
        _selectedTab = OrdersTab.scheduled;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bookingAddress = context.watch<BookingController>().address;
    final scheduledAddress = bookingAddress.fullAddress;
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
                          child: _selectedTab == OrdersTab.scheduled
                              ? _ScheduledOrdersView(
                                  key: const ValueKey('scheduled'),
                                  bottomSpacing: bottomSpacing,
                                  address: scheduledAddress,
                                  onTrackOrder:
                                      widget.onTrackOrder ??
                                      () =>
                                          Navigator.of(context)
                                              .pushNamed(AppRoutes.orderStatus),
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

  final OrdersTab selectedTab;
  final ValueChanged<OrdersTab> onSelected;

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
            selected: selectedTab == OrdersTab.scheduled,
            onTap: () => onSelected(OrdersTab.scheduled),
          ),
          _OrderTabButton(
            label: 'Riwayat',
            icon: Icons.receipt_long_outlined,
            selected: selectedTab == OrdersTab.history,
            onTap: () => onSelected(OrdersTab.history),
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
    final controller = context.watch<OrderController>();
    if (!controller.hasScheduledOrder) {
      return ListView(
        padding: EdgeInsets.fromLTRB(24, 54, 24, bottomSpacing),
        children: const [
          Icon(
            Icons.event_available_rounded,
            size: 68,
            color: AppColors.primaryBorder,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada pesanan terjadwal',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pesanan baru dan layanan yang belum selesai akan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    final orders = controller.scheduledOrders;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomSpacing),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final scheduledOrder = orders[index];
        final displayAddress = scheduledOrder.destinationAddress.isNotEmpty
            ? scheduledOrder.destinationAddress
            : address;
        return _ScheduledOrderCard(
          key: ValueKey(scheduledOrder.orderNumber),
          order: scheduledOrder,
          address: displayAddress,
          onTrackOrder: () {
            if (controller.selectScheduledOrder(scheduledOrder.orderNumber)) {
              onTrackOrder();
            }
          },
          onReschedule: () {
            if (controller.selectScheduledOrder(scheduledOrder.orderNumber)) {
              _pickNewSchedule(context, controller);
            }
          },
          onDetail: () {
            if (controller.selectScheduledOrder(scheduledOrder.orderNumber)) {
              _showScheduledDetail(
                context,
                controller,
                scheduledOrder,
                displayAddress,
              );
            }
          },
        );
      },
    );
  }

  Future<void> _pickNewSchedule(
    BuildContext context,
    OrderController controller,
  ) async {
    if (!controller.canModifyScheduledOrder) {
      AppNotice.show(
        context,
        'Jadwal tidak dapat diubah karena sudah melewati batas maksimal H-1.',
        type: AppNoticeType.error,
      );
      return;
    }

    final orderNumber = controller.scheduledOrder.orderNumber;
    final current =
        controller.scheduledOrder.scheduledAt ??
        DateTime.now().add(const Duration(days: 2));
    final now = DateTime.now();
    final firstDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(firstDate) ? firstDate : current,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 180)),
      helpText: 'Pilih jadwal baru',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryAction,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !context.mounted) return;
    final result =
        controller.selectScheduledOrder(orderNumber) &&
        controller.rescheduleOrder(
          DateTime(
            picked.year,
            picked.month,
            picked.day,
            current.hour,
            current.minute,
          ),
        );
    AppNotice.show(
      context,
      result
          ? 'Jadwal pesanan berhasil diperbarui.'
          : 'Jadwal tidak dapat diubah karena sudah melewati batas H-1.',
      type: result ? AppNoticeType.success : AppNoticeType.error,
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    OrderController controller,
  ) async {
    final orderNumber = controller.scheduledOrder.orderNumber;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: 'Batalkan pesanan?',
        message:
            'Pesanan akan dipindahkan ke Riwayat. '
            'Pembatalan hanya tersedia maksimal H-1.',
        confirmLabel: 'Batalkan Pesanan',
        onConfirm: () => Navigator.pop(context, true),
        cancelLabel: 'Kembali',
        isDestructive: true,
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result =
        controller.selectScheduledOrder(orderNumber) &&
        controller.cancelScheduledOrder();
    AppNotice.show(
      context,
      result
          ? 'Pesanan dibatalkan dan dipindahkan ke Riwayat.'
          : 'Pesanan tidak dapat dibatalkan karena sudah melewati batas H-1.',
      type: result ? AppNoticeType.success : AppNoticeType.error,
    );
  }

  Future<void> _showScheduledDetail(
    BuildContext context,
    OrderController controller,
    ScheduledOrderModel order,
    String address,
  ) async {
    final schedule = order.scheduledAt;
    final now = DateTime.now();
    final isSameDay =
        schedule != null &&
        schedule.year == now.year &&
        schedule.month == now.month &&
        schedule.day == now.day;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AppSheet(
        title: 'Detail Pesanan',
        actions: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.canModifyScheduledOrder
                    ? () {
                        Navigator.pop(sheetContext);
                        _pickNewSchedule(context, controller);
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  foregroundColor: AppColors.primaryAction,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ubah Jadwal'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: controller.canModifyScheduledOrder
                    ? () {
                        Navigator.pop(sheetContext);
                        _confirmCancellation(context, controller);
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  foregroundColor: AppColors.notification,
                  side: const BorderSide(color: AppColors.slate200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Batalkan Pesanan'),
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSameDay ? 'Pesan Langsung Hari Ini' : 'Booking Terjadwal',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSameDay
                  ? 'Cleaner diproses untuk datang pada hari yang sama. Jadwal tidak dapat diubah setelah cleaner ditugaskan.'
                  : controller.modificationDeadlineLabel,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                height: 1.45,
                color: AppColors.slate500,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: AppColors.slate100),
            ),
            _ScheduledDetailRow(label: 'Layanan', value: order.serviceName),
            _ScheduledDetailRow(label: 'No. Pesanan', value: order.orderNumber),
            _ScheduledDetailRow(
              label: 'Jadwal',
              value: schedule == null
                  ? 'Belum ditentukan'
                  : _formatOrderSchedule(schedule),
            ),
            _ScheduledDetailRow(label: 'Alamat', value: address),
            _ScheduledDetailRow(
              label: 'Catatan',
              value: order.note.trim().isEmpty
                  ? 'Tidak ada catatan'
                  : order.note,
            ),
            _ScheduledDetailRow(
              label: 'Pembayaran',
              value: order.paymentStatus,
            ),
            _ScheduledDetailRow(
              label: 'Total',
              value: order.price,
              emphasized: true,
            ),
            const SizedBox(height: 12),
            if (!controller.canModifyScheduledOrder)
              Text(
                isSameDay
                    ? 'Pesanan hari ini tidak dapat dibatalkan atau diubah setelah diproses.'
                    : 'Batas perubahan H-1 sudah lewat atau cleaner telah diberangkatkan.',
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduledOrderCard extends StatelessWidget {
  const _ScheduledOrderCard({
    super.key,
    required this.order,
    required this.address,
    required this.onTrackOrder,
    required this.onReschedule,
    required this.onDetail,
  });

  final ScheduledOrderModel order;
  final String address;
  final VoidCallback onTrackOrder;
  final VoidCallback onReschedule;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final schedule = order.scheduledAt;
    final today = DateTime(now.year, now.month, now.day);
    final serviceDay = schedule == null
        ? null
        : DateTime(schedule.year, schedule.month, schedule.day);
    final isScheduledBooking =
        order.stage == OrderStatusStage.dikonfirmasi &&
        serviceDay != null &&
        serviceDay.isAfter(today);
    final statusLabel = isScheduledBooking ? 'BOOKING TERJADWAL' : order.status;
    final headline = isScheduledBooking
        ? _formatOrderSchedule(schedule!)
        : order.arrivalEstimate;
    final description = isScheduledBooking
        ? 'Pesanan sudah dikonfirmasi dan menunggu hari layanan.'
        : order.travelDescription;
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
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryAction,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            statusLabel,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      headline,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8FAF7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isScheduledBooking ||
                          order.stage == OrderStatusStage.dikonfirmasi
                      ? Icons.event_available_outlined
                      : order.stage == OrderStatusStage.dalamPerjalanan
                      ? Icons.directions_bike_outlined
                      : order.stage == OrderStatusStage.sedangDikerjakan
                      ? Icons.cleaning_services_outlined
                      : Icons.person_pin_circle_outlined,
                  color: AppColors.primaryAction,
                  size: 24,
                ),
              ),
            ],
          ),
          if (!isScheduledBooking)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.slate100),
            ),
          if (!isScheduledBooking)
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                width: double.infinity,
                height: 6,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Color(0xFFD9EFED)),
                    ),
                    FractionallySizedBox(
                      widthFactor: order.progress.clamp(0.0, 1.0),
                      alignment: Alignment.centerLeft,
                      child: const SizedBox.expand(
                        child: ColoredBox(color: Color(0xFF00685F)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.slate100),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceVisual(assetPath: order.serviceImagePath, size: 44),
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                    ),
                  ),
                  Text(
                    order.paymentStatus,
                    style: const TextStyle(
                      color: AppColors.slate400,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryAction,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.slate600,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: isScheduledBooking ? onReschedule : onTrackOrder,
                  icon: Icon(
                    isScheduledBooking
                        ? Icons.edit_calendar_outlined
                        : Icons.navigation_outlined,
                    size: 17,
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    backgroundColor: AppColors.primaryAction,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: Text(
                    isScheduledBooking ? 'Ganti Jadwal' : 'Lacak Pesanan',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDetail,
                  icon: const Icon(Icons.receipt_long_outlined, size: 17),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: AppColors.primaryAction,
                    side: const BorderSide(color: AppColors.primaryBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: const Text('Lihat Detail'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduledDetailRow extends StatelessWidget {
  const _ScheduledDetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                color: AppColors.slate500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: emphasized ? 18 : 14,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
                color: emphasized
                    ? AppColors.primaryAction
                    : AppColors.slate900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatOrderSchedule(DateTime value) {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${days[value.weekday - 1]}, ${value.day} ${months[value.month - 1]} ${value.year} • $hour:$minute WIB';
}

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView({required this.bottomSpacing, super.key});

  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<OrderController>().historyOrders;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomSpacing),
      itemCount: history.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _HistoryOrderCard(order: history[index]);
      },
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  const _HistoryOrderCard({required this.order});

  final OrderHistoryModel order;

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == 'DIBATALKAN';
    final profileAvatar = context.watch<ProfileController>().avatarAsset;
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
              if (isCancelled) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'DIBATALKAN',
                    style: TextStyle(
                      color: Color(0xFFBE123C),
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
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
                ClipOval(
                  child: Image.asset(
                    profileAvatar,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 30,
                      height: 30,
                      color: const Color(0xFFE8FAF7),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 17,
                        color: AppColors.primaryAction,
                      ),
                    ),
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
                      onPressed: () => _handleReorder(context, order),
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
                        foregroundColor: AppColors.primaryAction,
                        side: const BorderSide(color: AppColors.primaryBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.receipt_long_outlined, size: 16),
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
                      onPressed: () => _handleReorder(context, order),
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (detailContext) => HistoryOrderDetailPage(
          order: order,
          onReorder: () => _handleReorder(detailContext, order),
        ),
      ),
    );
  }

  void _openReviewDialog(BuildContext context, OrderHistoryModel order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewRatingPage(
          orderId: order.orderId,
          serviceName: order.serviceName,
          serviceImagePath: order.serviceAssetPath,
        ),
      ),
    );
  }

  void _handleReorder(BuildContext context, OrderHistoryModel order) {
    final targetService = context
        .read<ServiceController>()
        .findServiceForHistory(order.serviceName);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingPage(service: targetService),
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
