import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_notice.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../order/controllers/order_controller.dart';
import '../../order/pages/order_status_page.dart';
import '../../order/pages/orders_page.dart';
import '../controllers/payment_flow_controller.dart';

/// Read-only verification. Neither resume nor a status check may create a charge.
Future<void> completeBookingPayment(BuildContext context, String bookingId, {bool allowCash = false}) async {
  final bookings = context.read<BookingController>();
  final orders = context.read<OrderController>();
  final booking = await bookings.fetchBookingSummary(bookingId);
  if (!context.mounted) return;
  if (booking.id != bookingId) throw StateError('Respons tidak cocok dengan booking.');
  if (booking.isFinished) throw StateError('Pesanan sudah selesai atau dibatalkan. Buka tab Pesanan.');
  final cashConfirmed = allowCash && booking.paymentMethod.toLowerCase() == 'cash' && booking.status != 'Menunggu Pembayaran';
  if (booking.paymentStatus != 'paid' && !cashConfirmed) {
    AppNotice.show(context, switch (booking.paymentStatus) {
      'expired' => 'Sesi pembayaran berakhir. Hubungi admin; jangan bayar ulang.',
      'failed' => 'Pembayaran gagal. Hubungi admin sebelum membayar ulang.',
      _ => 'Pembayaran belum diterima. Cek kembali; jangan bayar ulang.',
    });
    return;
  }
  await orders.loadFromApi();
  if (!context.mounted) return;
  final matches = orders.scheduledOrders.where((order) => order.backendBookingId == bookingId);
  if (matches.isEmpty || !orders.selectScheduledOrder(matches.first.orderNumber)) {
    throw StateError('Pembayaran diterima, tetapi pesanan belum dapat dimuat. Cek kembali; jangan bayar ulang.');
  }
  if (bookings.serverBookingId == bookingId) await bookings.clearDraft();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => PaymentFlowController.isServiceToday(booking.date)
        ? const OrderStatusPage(openedAfterPayment: true)
        : const OrdersPage(initialTab: OrdersTab.scheduled)),
    (route) => route.isFirst,
  );
}
