import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_routes.dart';
import '../../features/booking/controllers/booking_controller.dart';
import '../../features/checkout/pages/pending_payment_page.dart';
import '../../features/order/controllers/order_controller.dart';
import '../../shared/widgets/app_notice.dart';

final _opens = Expando<({String bookingId, Object token})>();

/// Both push and inbox taps resolve current owned server state, never create a charge.
Future<bool> openBookingNotification(
  BuildContext context, {
  required String type,
  required String? bookingId,
}) async {
  if ((type != 'order' && type != 'payment') ||
      bookingId == null ||
      !RegExp(r'^[1-9][0-9]*$').hasMatch(bookingId)) {
    return false;
  }
  final navigator = Navigator.of(context);
  if (_opens[navigator]?.bookingId == bookingId) return true;
  final token = Object();
  _opens[navigator] = (bookingId: bookingId, token: token);
  bool isCurrent() => context.mounted && _opens[navigator]?.token == token;
  try {
    final orders = context.read<OrderController>();
    final booking = await context.read<BookingController>().fetchBookingSummary(
      bookingId,
    );
    if (!isCurrent()) return true;
    if (booking.id != bookingId) {
      throw StateError('Respons tidak cocok dengan booking.');
    }
    if (!booking.isFinished &&
        (booking.status == 'Menunggu Pembayaran' ||
            (booking.paymentStatus != 'paid' &&
                booking.paymentMethod.toLowerCase() != 'cash'))) {
      navigator
          .push<void>(
            MaterialPageRoute(
              builder: (_) => PendingPaymentPage(booking: booking),
            ),
          )
          .then((_) => orders.loadFromApi());
      return true;
    }
    await orders.loadFromApi();
    if (!isCurrent()) return true;
    for (final order in orders.scheduledOrders) {
      if (!booking.isFinished && order.backendBookingId == bookingId) {
        orders.selectScheduledOrder(order.orderNumber);
        navigator.pushNamed(AppRoutes.orderStatus);
        return true;
      }
    }
    navigator.pushNamed(AppRoutes.orders);
  } catch (_) {
    if (context.mounted && isCurrent()) {
      AppNotice.show(
        context,
        'Status pesanan belum dapat dimuat. Coba lagi.',
        type: AppNoticeType.error,
      );
    }
  } finally {
    if (_opens[navigator]?.token == token) {
      _opens[navigator] = null;
    }
  }
  return true;
}
