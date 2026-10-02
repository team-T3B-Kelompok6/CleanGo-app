import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../domain/models/payment_method_model.dart';
import '../widgets/payment_method_icon.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({
    required this.method,
    required this.totalPayment,
    super.key,
  });

  final PaymentMethodModel method;
  final String totalPayment;

  bool get _isCash => method.type == PaymentMethodType.cash;

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
                    subtitle: 'Selesaikan pembayaran dengan ${method.name}',
                    onBack: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                      child: Column(
                        children: [
                          _TotalPaymentCard(
                            method: method,
                            totalPayment: totalPayment,
                          ),
                          const SizedBox(height: 14),
                          _PaymentInstructionCard(method: method),
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
        bottomNavigationBar: _PaymentActionBar(
          label: _isCash
              ? 'Konfirmasi Pembayaran Tunai'
              : 'Saya Sudah Membayar',
          onPressed: () => _showPaymentInformation(context),
        ),
      ),
    );
  }

  Future<void> _showPaymentInformation(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(
          _isCash ? Icons.payments_outlined : Icons.verified_outlined,
          color: AppColors.primaryAction,
          size: 34,
        ),
        title: Text(
          _isCash ? 'Pembayaran Tunai Dipilih' : 'Konfirmasi Pembayaran',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.slate900,
            fontFamily: AppTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          _isCash
              ? 'Siapkan pembayaran $totalPayment dan bayarkan setelah layanan selesai.'
              : 'Pembayaran Anda akan diverifikasi setelah layanan pembayaran tersedia.',
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
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryAction,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mengerti'),
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

class _TotalPaymentCard extends StatelessWidget {
  const _TotalPaymentCard({
    required this.method,
    required this.totalPayment,
  });

  final PaymentMethodModel method;
  final String totalPayment;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}

class _PaymentInstructionCard extends StatelessWidget {
  const _PaymentInstructionCard({required this.method});

  final PaymentMethodModel method;

  bool get _isCash => method.type == PaymentMethodType.cash;
  bool get _isQris => method.type == PaymentMethodType.qris;

  @override
  Widget build(BuildContext context) {
    final title = _isCash
        ? 'Pembayaran Tunai'
        : _isQris
            ? 'Pindai QRIS untuk Membayar'
            : 'Bayar dengan ${method.name}';
    final description = _isCash
        ? 'Bayarkan sesuai total tagihan kepada petugas setelah layanan selesai.'
        : _isQris
            ? 'Buka aplikasi pembayaran atau mobile banking, lalu pindai kode QRIS berikut.'
            : 'Buka aplikasi ${method.name}, lalu selesaikan pembayaran sesuai total tagihan.';

    return _PaymentSurface(
      child: Column(
        children: [
          Container(
            width: _isQris ? 150 : 76,
            height: _isQris ? 150 : 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isQris ? Colors.white : const Color(0xFFE8FAF7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.slate100),
            ),
            child: _isQris
                ? const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.slate900,
                    size: 124,
                  )
                : PaymentMethodIcon(method: method, size: 54),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate900,
              fontFamily: AppTheme.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.slate500,
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
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
  final VoidCallback onPressed;

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
