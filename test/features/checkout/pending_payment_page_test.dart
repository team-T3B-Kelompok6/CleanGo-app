import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/checkout/pages/pending_payment_page.dart';
import 'package:cleango_app/features/checkout/pages/midtrans_checkout_page.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

final pending = CustomerBookingSummary.fromJson({
  'id': 42, 'code': 'CG-42', 'date': '2030-01-02', 'time': '10:00',
  'status': 'awaiting_payment', 'paymentMethod': 'qris', 'paymentStatus': 'pending',
  'checkoutUrl': 'https://app.midtrans.com/snap/token',
});

class _Api extends CustomerBookingApi {
  final paid = <String>[];
  final fetched = <String>[];
  bool offline = false;
  @override
  Future<CustomerBookingSummary> fetchBookingSummary(String id) async {
    fetched.add(id);
    if (offline) throw StateError('Offline');
    return pending;
  }
  @override
  Future<BookingPayment> pay({required String bookingId, required String method}) async {
    paid.add(bookingId);
    throw StateError('Resume must not charge');
  }
  @override
  Future<List<CustomerBookingSummary>> fetchBookings() async => [];
}

void main() {
  testWidgets('resume opens QRIS directly; checks and Back never charge', (tester) async {
    final api = _Api();
    final booking = BookingController(bookingApi: api);
    final orders = OrderController(bookingApi: api);
    addTearDown(booking.dispose);
    addTearDown(orders.dispose);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider.value(value: booking), ChangeNotifierProvider.value(value: orders)],
      child: MaterialApp(home: Builder(builder: (context) => Scaffold(body: TextButton(
        onPressed: () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => PendingPaymentPage(booking: pending))),
        child: const Text('Open'),
      )))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(MidtransCheckoutPage), findsOneWidget);
    expect(find.text('Buka Pembayaran QRIS'), findsNothing);
    expect(api.fetched, isEmpty);
    await tester.tap(find.text('Cek Status Pembayaran'));
    await tester.pumpAndSettle();
    expect(api.fetched, ['42']);
    expect(find.byType(MidtransCheckoutPage), findsOneWidget);
    api.offline = true;
    await tester.tap(find.text('Cek Status Pembayaran'));
    await tester.pumpAndSettle();
    expect(find.byType(MidtransCheckoutPage), findsOneWidget);
    expect(api.paid, isEmpty);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(api.paid, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final url in [null, '', '   ']) {
    testWidgets('resume fetches stored QRIS URL when local URL is "$url"', (tester) async {
      final api = _Api();
      final booking = BookingController(bookingApi: api);
      addTearDown(booking.dispose);
      final stale = CustomerBookingSummary.fromJson({
        'id': 42, 'status': 'awaiting_payment', 'paymentMethod': 'qris',
        'paymentStatus': 'pending', 'checkoutUrl': url,
      });
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: booking,
        child: MaterialApp(home: PendingPaymentPage(booking: stale)),
      ));
      await tester.pumpAndSettle();
      expect(api.fetched, ['42']);
      final page = tester.widget<MidtransCheckoutPage>(find.byType(MidtransCheckoutPage));
      expect(page.checkoutUri.toString(), pending.checkoutUrl);
      expect(find.textContaining('Tautan pembayaran tidak tersedia'), findsNothing);
      expect(api.paid, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('failed URL recovery can retry without charging', (tester) async {
    final api = _Api()..offline = true;
    final booking = BookingController(bookingApi: api);
    addTearDown(booking.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: booking,
      child: MaterialApp(home: PendingPaymentPage(booking: CustomerBookingSummary.fromJson({
        'id': 42, 'status': 'awaiting_payment', 'paymentMethod': 'qris',
      }))),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(MidtransCheckoutPage), findsNothing);
    api.offline = false;
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(find.byType(MidtransCheckoutPage), findsOneWidget);
    expect(api.fetched, ['42', '42']);
    expect(api.paid, isEmpty);
    expect(tester.takeException(), isNull);
  });

  test('booking detail retains stored checkout URL', () {
    final summary = CustomerBookingSummary.fromJson({'id': 42, 'checkoutUrl': 'https://app.midtrans.com/snap/token'});
    expect(summary.checkoutUrl, 'https://app.midtrans.com/snap/token');
  });
}
