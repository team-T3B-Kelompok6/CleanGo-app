import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_notice.dart';
import '../../address/controllers/address_controller.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../order/controllers/order_controller.dart';
import '../../order/pages/order_status_page.dart';
import '../../order/pages/orders_page.dart';
import '../controllers/payment_flow_controller.dart';
import '../domain/models/payment_method_model.dart';
import '../widgets/payment_method_icon.dart';
import 'midtrans_checkout_page.dart';
import 'complete_booking_payment.dart';

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
  final _paymentFlowController = PaymentFlowController();

  bool _isSubmitting = false;

  bool get _isCash => widget.method.type == PaymentMethodType.cash;

  String _paymentDeadline(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}, '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

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
                          _TotalPaymentCard(
                            method: widget.method,
                            totalPayment: widget.totalPayment,
                          ),
                          const SizedBox(height: 16),
                          if (_isCash)
                            const _CashInstructionCard()
                          else
                            _PaymentSurface(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    switch (_paymentFlowController
                                        .payment
                                        ?.status) {
                                      'failed' => 'Pembayaran gagal',
                                      'expired' => 'Waktu pembayaran berakhir',
                                      _ => 'Menunggu pembayaran',
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _paymentFlowController.bookingId == null
                                        ? 'Kode QRIS akan muncul di langkah berikutnya. Pesanan dikonfirmasi setelah pembayaran diterima.'
                                        : 'Selesaikan pembayaran lalu cek status. Jika sudah membayar, jangan bayar ulang.',
                                  ),
                                  if (_paymentFlowController
                                          .payment
                                          ?.expiresAt !=
                                      null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Bayar sebelum ${_paymentDeadline(_paymentFlowController.payment!.expiresAt!)}',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          if (!_isCash &&
                              _paymentFlowController.bookingId != null)
                            TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _showPaymentInformation(context),
                              child: const Text('Buka / Coba Lagi Pembayaran'),
                            ),
                          const SizedBox(height: 16),
                          _PaymentOrderCard(
                            serviceName: booking.service?.title ?? '-',
                            schedule:
                                '${booking.formattedSelectedDate}, ${booking.formattedSelectedTime}',
                            address: '${address.label}\n${address.fullAddress}',
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
        bottomNavigationBar: _PaymentActionBar(
          label: _isSubmitting
              ? 'Memproses pesanan...'
              : _isCash
              ? 'Konfirmasi Pembayaran Tunai'
              : _paymentFlowController.bookingId == null
              ? 'Lanjutkan Pembayaran'
              : 'Cek Status Pembayaran',
          onPressed: _isSubmitting
              ? null
              : () => _showPaymentInformation(
                  context,
                  checkStatus: _paymentFlowController.bookingId != null,
                ),
        ),
      ),
    );
  }

  Future<void> _showPaymentInformation(
    BuildContext context, {
    bool checkStatus = false,
  }) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final isSameDay = await _paymentFlowController.createOrder(
        booking: context.read<BookingController>(),
        addresses: context.read<AddressController>(),
        orders: context.read<OrderController>(),
        method: widget.method,
        totalPayment: widget.totalPayment,
        servicePrice: widget.servicePrice,
        platformFee: widget.platformFee,
        discountAmount: widget.discountAmount,
        checkStatus: checkStatus,
      );
      if (!context.mounted) return;
      if (isSameDay == null) {
        final payment = _paymentFlowController.payment;
        if (checkStatus) {
          AppNotice.show(context, 'Pembayaran belum diterima. Cek kembali; jangan bayar ulang.');
        }
        if (!checkStatus && !_isCash && payment?.checkoutUrl != null) {
          final uri = PaymentFlowController.checkoutUri(payment!.checkoutUrl);
          if (uri == null) {
            throw StateError('Tautan pembayaran tidak valid. Hubungi admin.');
          }
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (qrisContext) => MidtransCheckoutPage(
                checkoutUri: uri,
                onCheckStatus: () => completeBookingPayment(qrisContext, _paymentFlowController.bookingId!),
              ),
            ),
          );
          if (!context.mounted) return;
          setState(() => _isSubmitting = false);
          return;
        }
        if (context.mounted) setState(() => _isSubmitting = false);
        return;
      }

      AppNotice.show(
        context,
        _isCash
            ? 'Pesanan dikonfirmasi. Siapkan pembayaran tunai ${widget.totalPayment}.'
            : 'Pembayaran berhasil. Pesanan Anda sudah dikonfirmasi.',
      );
      _navigateToOrders(context, isSameDay);
    } catch (error) {
      if (!context.mounted) return;
      setState(() => _isSubmitting = false);
      AppNotice.show(context, switch (error) {
        StateError() => error.message.toString(),
        ApiException() => error.message,
        _ => 'Pesanan belum berhasil diproses. Silakan coba lagi.',
      }, type: AppNoticeType.error);
    }
  }

  void _navigateToOrders(BuildContext context, bool isSameDay) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => isSameDay
            ? const OrderStatusPage(openedAfterPayment: true)
            : const OrdersPage(initialTab: OrdersTab.scheduled),
      ),
      (route) => route.isFirst,
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
                    fontSize: 14,
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

class _CashInstructionCard extends StatelessWidget {
  const _CashInstructionCard();

  @override
  Widget build(BuildContext context) {
    return _PaymentSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.primaryAction,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bayar Tunai di Tempat',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Siapkan uang pas saat cleaner tiba di lokasi Anda. Pesanan langsung dikonfirmasi setelah Anda menekan tombol di bawah.',
            style: TextStyle(
              color: AppColors.slate600,
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

class _TotalPaymentCard extends StatelessWidget {
  const _TotalPaymentCard({required this.method, required this.totalPayment});

  final PaymentMethodModel method;
  final String totalPayment;

  @override
  Widget build(BuildContext context) {
    final isCash = method.type == PaymentMethodType.cash;
    return _PaymentSurface(
      child: Column(
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              color: AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isCash
                ? 'Bayar kepada petugas setelah layanan selesai.'
                : 'Lanjutkan pembayaran untuk melihat kode QRIS.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
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
          Text('Detail Pesanan', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          _PaymentDetailRow(label: 'Layanan', value: serviceName),
          const SizedBox(height: 8),
          _PaymentDetailRow(label: 'Jadwal', value: schedule),
          const SizedBox(height: 8),
          _PaymentDetailRow(label: 'Alamat', value: address),
          const SizedBox(height: 8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.slate500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.slate900),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
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
                      fontSize: 16,
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
