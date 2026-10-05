import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../booking/pages/booking_page.dart';
import '../../service/data/service_data.dart';
import '../controllers/order_controller.dart';
import '../domain/models/order_model.dart';
import '../widgets/order_tracking_map.dart';
import 'orders_page.dart';
import 'review_rating_page.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({this.openedAfterPayment = false, super.key});

  final bool openedAfterPayment;

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  bool _hasNavigatedToRating = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _sheetSize = 0.56;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_syncMapControlsWithSheet);
  }

  void _syncMapControlsWithSheet() {
    if (!_sheetController.isAttached || !mounted) return;
    final nextSize = _sheetController.size;
    if ((nextSize - _sheetSize).abs() < 0.002) return;
    setState(() => _sheetSize = nextSize);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_syncMapControlsWithSheet);
    _sheetController.dispose();
    super.dispose();
  }

  void _navigateBackToScheduled(BuildContext context) {
    final navigator = Navigator.of(context);
    if (!widget.openedAfterPayment && navigator.canPop()) {
      navigator.pop();
      return;
    }
    final hasScheduledOrder = context.read<OrderController>().hasScheduledOrder;
    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OrdersPage(
          initialTab: hasScheduledOrder
              ? OrdersTab.scheduled
              : OrdersTab.history,
        ),
      ),
    );
  }

  void _autoNavigateToRating(ScheduledOrderModel order) {
    if (_hasNavigatedToRating) return;
    _hasNavigatedToRating = true;

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewRatingPage(
            orderId: order.orderNumber,
            serviceName: order.serviceName,
            serviceImagePath: order.serviceImagePath,
          ),
        ),
      );
    });
  }

  void _openWhatsApp(BuildContext context, String target, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Image.asset(
              'assets/icons/whatsapp.png',
              width: 20,
              height: 20,
              errorBuilder: (_, _, _) => const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Membuka chat WhatsApp dengan $target ($phone)...',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF159466),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderController = context.watch<OrderController>();
    final order = orderController.scheduledOrder;
    final currentStage = orderController.currentStage;
    final isFinished = currentStage == OrderStatusStage.selesai;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _navigateBackToScheduled(context);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              Positioned.fill(
                child: OrderTrackingMap(
                  order: order,
                  height: MediaQuery.sizeOf(context).height,
                  borderRadius: 0,
                  controlsBottomInset:
                      MediaQuery.sizeOf(context).height * _sheetSize + 12,
                ),
              ),
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.56,
                minChildSize: 0.27,
                maxChildSize: 0.93,
                snap: true,
                snapSizes: const [0.27, 0.56, 0.93],
                builder: (context, scrollController) {
                  return Material(
                    color: const Color(0xFFF8FAFC),
                    elevation: 12,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildEstimatedArrivalCard(order),
                        const SizedBox(height: 14),
                        _buildCleanerCard(context, order),
                        const SizedBox(height: 14),
                        _buildServiceStagesCard(
                          context,
                          orderController,
                          currentStage,
                          order,
                        ),
                        const SizedBox(height: 14),
                        _buildAddressCard(order),
                        const SizedBox(height: 14),
                        _buildOrderDetailCard(order),
                        if (isFinished) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _autoNavigateToRating(order),
                                  icon: const Icon(Icons.star_rounded),
                                  label: const Text('Beri Ulasan'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    foregroundColor: const Color(0xFF00685F),
                                    side: const BorderSide(
                                      color: Color(0xFF00685F),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _reorder(context, order),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Pesan Lagi'),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    backgroundColor: const Color(0xFF00685F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),
                        _buildSupportHelpCard(context),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 12,
                left: 16,
                child: _buildBackButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reorder(BuildContext context, ScheduledOrderModel order) {
    final service = ServiceData.services.firstWhere(
      (item) => item.title.toLowerCase() == order.serviceName.toLowerCase(),
      orElse: () => ServiceData.services.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookingPage(service: service)),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: Color(0xFFE2E8F0))),
      elevation: 3,
      shadowColor: const Color(0x33000000),
      child: IconButton(
        tooltip: 'Kembali',
        onPressed: () => _navigateBackToScheduled(context),
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF1E293B),
          size: 22,
        ),
        style: IconButton.styleFrom(
          fixedSize: const Size.square(44),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildAddressCard(ScheduledOrderModel order) {
    return _informationCard(
      title: 'Alamat Pengerjaan',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.destinationAddress,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.4,
            ),
          ),
          if (order.destinationSubAddress.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              order.destinationSubAddress,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${order.customerName} • ${order.customerPhone}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailCard(ScheduledOrderModel order) {
    return _informationCard(
      title: 'Rincian Pesanan',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _detailRow('Layanan', order.serviceName),
          _detailRow('Pembayaran', order.paymentStatus),
          _detailRow('Total', order.price, emphasized: true),
          _detailRow(
            'Catatan',
            order.note.trim().isEmpty ? 'Tidak ada catatan' : order.note,
          ),
          _detailRow('No. Pesanan', order.orderNumber),
        ],
      ),
    );
  }

  Widget _informationCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF00685F)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool emphasized = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: emphasized ? 14 : 12.5,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
                color: emphasized
                    ? const Color(0xFF00685F)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedArrivalCard(ScheduledOrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE6FAF7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF00685F),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perkiraan Waktu Tiba',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    text: 'Cleaner tiba pukul ',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: order.estimatedArrivalTime,
                        style: const TextStyle(
                          color: Color(0xFF00685F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FAF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    color: Color(0xFF00685F),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  order.estimatedMinutes,
                  style: const TextStyle(
                    color: Color(0xFF00685F),
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanerCard(BuildContext context, ScheduledOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00685F), width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    order.cleanerAvatarPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.person,
                      size: 28,
                      color: Color(0xFF00685F),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.cleanerName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${order.cleanerRating}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${order.cleanerCompletedTasks}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () =>
                _openWhatsApp(context, order.cleanerName, order.cleanerPhone),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9FAF2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/whatsapp.png',
                    width: 18,
                    height: 18,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.chat_bubble_rounded,
                      color: Color(0xFF159466),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Chat',
                    style: TextStyle(
                      color: Color(0xFF159466),
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStagesCard(
    BuildContext context,
    OrderController controller,
    OrderStatusStage activeStage,
    ScheduledOrderModel order,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tahapan Layanan',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FAF7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: Text(
                  controller.currentStepLabel,
                  style: const TextStyle(
                    color: Color(0xFF00685F),
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Daftar 5 langkah layanan interaktif
          ...List.generate(OrderStatusStage.values.length, (index) {
            final stage = OrderStatusStage.values[index];
            final isCompleted = index < activeStage.index;
            final isCurrent = index == activeStage.index;
            final isLast = index == OrderStatusStage.values.length - 1;

            return InkWell(
              onTap: () {
                if (stage != OrderStatusStage.selesai) {
                  _hasNavigatedToRating = false;
                }
                if (stage == OrderStatusStage.selesai) {
                  controller.completeScheduledOrder();
                } else {
                  controller.setStage(stage);
                }
              },
              child: _buildStageStepItem(
                stage: stage,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: isLast,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStageStepItem({
    required OrderStatusStage stage,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom icon & garis penghubung
        Column(
          children: [
            if (isCompleted)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF00685F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              )
            else if (isCurrent)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FAF7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00685F), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00685F),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            if (!isLast)
              Container(
                width: 2,
                height: isCurrent ? 64 : 38,
                color: isCompleted
                    ? const Color(0xFF00685F)
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        // Konten keterangan tahap
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: isCurrent
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFCCFBF1),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              stage.title,
                              style: const TextStyle(
                                color: Color(0xFF0F766E),
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF2DD4BF),
                                ),
                              ),
                              child: const Text(
                                'Sekarang',
                                style: TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stage.description,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stage.title,
                            style: TextStyle(
                              color: isCompleted
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                              fontFamily: 'Inter',
                              fontSize: 13.5,
                              fontWeight: isCompleted
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                          Text(
                            stage.timeLabel,
                            style: TextStyle(
                              color: isCompleted
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage.description,
                        style: TextStyle(
                          color: isCompleted
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportHelpCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ada kendala pesanan?',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () =>
                _openWhatsApp(context, 'Admin CleanGo', '+62 811-2233-4455'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9FAF2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/whatsapp.png',
                    width: 16,
                    height: 16,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.chat_bubble_rounded,
                      color: Color(0xFF159466),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Chat admin',
                    style: TextStyle(
                      color: Color(0xFF159466),
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
