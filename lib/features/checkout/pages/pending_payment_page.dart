import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/app_notice.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../booking/data/customer_booking_api.dart';
import 'complete_booking_payment.dart';
import 'midtrans_checkout_page.dart';

/// Digital resumes in-place from a read-only detail request; cash stays explicit.
class PendingPaymentPage extends StatefulWidget {
  const PendingPaymentPage({required this.booking, super.key});
  final CustomerBookingSummary booking;

  @override
  State<PendingPaymentPage> createState() => _PendingPaymentPageState();
}

class _PendingPaymentPageState extends State<PendingPaymentPage> {
  late CustomerBookingSummary _booking;
  bool _busy = false;
  bool _loadingCheckout = false;
  String? _checkoutError;

  bool get _isCash => _booking.paymentMethod.toLowerCase() == 'cash';

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    if (!_isCash && (_booking.checkoutUrl?.trim().isEmpty ?? true)) {
      _fetchLatest();
    }
  }

  Future<void> _fetchLatest() async {
    setState(() {
      _loadingCheckout = true;
      _checkoutError = null;
    });
    try {
      // Read-only recovery: never create a replacement payment on resume.
      final latest = await context.read<BookingController>().fetchBookingSummary(_booking.id);
      if (!mounted) return;
      setState(() => _booking = latest);
    } catch (error) {
      if (!mounted) return;
      setState(() => _checkoutError = error is ApiException
          ? error.message
          : 'Tautan pembayaran belum dapat dimuat. Coba lagi; jangan bayar ulang.');
    } finally {
      if (mounted) setState(() => _loadingCheckout = false);
    }
  }

  Future<void> _check({bool confirmCash = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (confirmCash) {
        await context.read<BookingController>().payBooking(_booking.id, 'cash');
        if (!mounted) return;
      }
      await completeBookingPayment(context, _booking.id, allowCash: _isCash);
    } catch (error) {
      if (mounted) {
        AppNotice.show(
          context,
          switch (error) {
            ApiException() => error.message,
            StateError() => error.message.toString(),
            _ => 'Status pembayaran belum dapat dipastikan. Cek kembali; jangan bayar ulang.',
          },
          type: AppNoticeType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCheckout || _checkoutError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pembayaran QRIS')),
        body: Center(
          child: _loadingCheckout
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_checkoutError!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _fetchLatest, child: const Text('Coba Lagi')),
                  ]),
                ),
        ),
      );
    }
    if (!_isCash) {
      return MidtransCheckoutPage(
        // Missing/legacy URL shows safe recovery, never starts a replacement charge.
        checkoutUri: Uri.tryParse(_booking.checkoutUrl ?? '') ?? Uri(),
        onCheckStatus: _check,
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Tunai')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(BookingController.formatRupiah(_booking.totalAmount)),
        const SizedBox(height: 16),
        Text('${_booking.code}\n${_booking.service}\n${_booking.date}, ${_booking.time}\n${_booking.address}'),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy ? null : () => _check(confirmCash: true),
          child: const Text('Konfirmasi Pembayaran Tunai'),
        ),
      ]),
    );
  }
}
