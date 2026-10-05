import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../address/controllers/address_controller.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../order/controllers/order_controller.dart';
import '../../order/pages/order_status_page.dart';
import '../../order/pages/orders_page.dart';
import '../controllers/payment_countdown_controller.dart';
import '../domain/models/payment_method_model.dart';
import '../widgets/payment_method_icon.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    required this.method,
    required this.totalPayment,
    required this.servicePrice,
    required this.platformFee,
    required this.discountAmount,
    super.key,
  });

  final PaymentMethodModel method;
  final String totalPayment;
  final int servicePrice;
  final int platformFee;
  final int discountAmount;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final PaymentCountdownController _countdownController;

  @override
  void initState() {
    super.initState();
    _countdownController = PaymentCountdownController();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  bool get _isCash => widget.method.type == PaymentMethodType.cash;

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingController>();
    final address = booking.address;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.screenBackground,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _PaymentHeader(
                    subtitle:
                        'Selesaikan pembayaran dengan ${widget.method.name}',
                    onBack: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                      child: Column(
                        children: [
                          _PaymentCountdownCard(
                            controller: _countdownController,
                            isCash: _isCash,
                          ),
                          const SizedBox(height: 14),
                          _TotalPaymentCard(
                            method: widget.method,
                            totalPayment: widget.totalPayment,
                          ),
                          const SizedBox(height: 14),
                          _PaymentOrderCard(
                            serviceName: booking.service?.title ?? '-',
                            schedule:
                                '${booking.formattedSelectedDate}, ${booking.formattedSelectedTime}',
                            address:
                                '${address.label}\n${address.street}, ${address.city}',
                            note: booking.note.trim().isEmpty
                                ? 'Tidak ada catatan'
                                : booking.note.trim(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: _countdownController,
          builder: (context, _) => _PaymentActionBar(
            label: _countdownController.isExpired
                ? 'Waktu Pembayaran Berakhir'
                : _isCash
                ? 'Konfirmasi Pembayaran Tunai'
                : 'Saya Sudah Membayar',
            onPressed: _countdownController.isExpired
                ? null
                : () => _showPaymentInformation(context),
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentInformation(BuildContext context) async {
    final booking = context.read<BookingController>();
    final addressController = context.read<AddressController>();
    final selectedAddr = addressController.selectedAddress;
    final formattedAddress = selectedAddr != null
        ? selectedAddr.fullAddress
        : '${booking.address.street}, ${booking.address.city}';

    final scheduledAt = DateTime(
      booking.selectedDate.year,
      booking.selectedDate.month,
      booking.selectedDate.day,
      int.tryParse(booking.selectedTime.split(':').first) ?? 8,
      int.tryParse(booking.selectedTime.split(':').last) ?? 0,
    );
    final today = DateTime.now();
    final isSameDay =
        scheduledAt.year == today.year &&
        scheduledAt.month == today.month &&
        scheduledAt.day == today.day;

    // Daftarkan/update pesanan di OrderController.
    context.read<OrderController>().createOrderFromBooking(
      serviceName: booking.service?.title ?? 'Deep Cleaning',
      serviceImagePath:
          booking.service?.imagePath ??
          'assets/images/service_deep_cleaning.jpeg',
      price: widget.totalPayment,
      address: formattedAddress.trim().isNotEmpty
          ? formattedAddress
          : 'Jl. Sigura - Gura No. 12, Malang',
      scheduledAt: scheduledAt,
      note: booking.note.trim(),
      paymentMethod: widget.method.name,
      servicePrice: widget.servicePrice,
      platformFee: widget.platformFee,
      discountAmount: widget.discountAmount,
      customerName: booking.address.customerName,
      customerPhone: booking.address.phoneNumber,
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.primaryAction,
          size: 44,
        ),
        title: const Text(
          'Pembayaran Berhasil!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.slate900,
            fontFamily: AppTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          _isCash
              ? 'Pesanan berhasil dibuat. Siapkan pembayaran tunai ${widget.totalPayment} saat staf tiba di lokasi.'
              : 'Pembayaran ${widget.totalPayment} melalui ${widget.method.name} berhasil diverifikasi sistem CleanGo.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.slate500,
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => isSameDay
                        ? const OrderStatusPage(openedAfterPayment: true)
                        : const OrdersPage(initialTab: OrdersTab.scheduled),
                  ),
                  (route) => route.isFirst,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryAction,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isSameDay ? 'Lihat Status Pesanan' : 'Lihat Pesanan Terjadwal',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader({required this.subtitle, required this.onBack});

  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.slate100),
            ),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: 38,
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
                  'Pembayaran',
                  style: TextStyle(
                    color: AppColors.slate900,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
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

class _PaymentCountdownCard extends StatelessWidget {
  const _PaymentCountdownCard({required this.controller, required this.isCash});

  final PaymentCountdownController controller;
  final bool isCash;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final expired = controller.isExpired;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: expired
                  ? const [Color(0xFFFFF1F2), Color(0xFFFFFBFB)]
                  : const [Color(0xFFE8FAF7), Color(0xFFF7FFFE)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: expired
                  ? const Color(0xFFFDA4AF)
                  : AppColors.primaryBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: expired ? const Color(0xFFFFE4E6) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  expired ? Icons.timer_off_outlined : Icons.timer_outlined,
                  color: expired
                      ? const Color(0xFFE11D48)
                      : AppColors.primaryAction,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expired
                          ? 'Waktu pembayaran berakhir'
                          : isCash
                          ? 'Konfirmasi pesanan dalam'
                          : 'Selesaikan pembayaran dalam',
                      style: TextStyle(
                        color: expired
                            ? const Color(0xFFBE123C)
                            : AppColors.slate600,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.formattedRemaining,
                      style: TextStyle(
                        color: expired
                            ? const Color(0xFFE11D48)
                            : AppColors.primary,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (!expired)
                const Text(
                  'Pesanan ditahan\nselama waktu ini',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TotalPaymentCard extends StatelessWidget {
  const _TotalPaymentCard({required this.method, required this.totalPayment});

  final PaymentMethodModel method;
  final String totalPayment;

  @override
  Widget build(BuildContext context) {
    final isCash = method.type == PaymentMethodType.cash;
    final isQris = method.type == PaymentMethodType.qris;
    return _PaymentSurface(
      child: Column(
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              color: AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            totalPayment,
            style: const TextStyle(
              color: AppColors.primaryAction,
              fontFamily: AppTheme.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.slate100),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PaymentMethodIcon(method: method, size: 38),
              const SizedBox(width: 10),
              Text(
                method.name,
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isQris)
            Container(
              width: 142,
              height: 142,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate100),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: AppColors.slate900,
                size: 118,
              ),
            ),
          if (isQris) const SizedBox(height: 12),
          Text(
            isCash
                ? 'Bayarkan kepada cleaner setelah layanan selesai.'
                : isQris
                ? 'Pindai QRIS dengan aplikasi pembayaran atau mobile banking.'
                : 'Buka aplikasi ${method.name} dan selesaikan pembayaran.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOrderCard extends StatelessWidget {
  const _PaymentOrderCard({
    required this.serviceName,
    required this.schedule,
    required this.address,
    required this.note,
  });

  final String serviceName;
  final String schedule;
  final String address;
  final String note;

  @override
  Widget build(BuildContext context) {
    return _PaymentSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pesanan',
            style: TextStyle(
              color: AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _PaymentDetailRow(label: 'Layanan', value: serviceName),
          const SizedBox(height: 10),
          _PaymentDetailRow(label: 'Jadwal', value: schedule),
          const SizedBox(height: 10),
          _PaymentDetailRow(label: 'Alamat', value: address),
          const SizedBox(height: 10),
          _PaymentDetailRow(label: 'Catatan', value: note),
        ],
      ),
    );
  }
}

class _PaymentDetailRow extends StatelessWidget {
  const _PaymentDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentSurface extends StatelessWidget {
  const _PaymentSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PaymentActionBar extends StatelessWidget {
  const _PaymentActionBar({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
        boxShadow: [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryAction,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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
