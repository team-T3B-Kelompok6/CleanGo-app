import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/checkout/controllers/payment_flow_controller.dart';
import 'package:cleango_app/features/checkout/pages/complete_booking_payment.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/pages/order_status_page.dart';
import 'package:cleango_app/features/order/pages/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

class _FakeApi extends CustomerBookingApi {
  _FakeApi()
      : super(
          client: ApiClient(
            client: MockClient((_) async => http.Response('{}', 200)),
          ),
        );

  CustomerBookingSummary summary = CustomerBookingSummary.fromJson({
    'id': 77,
    'code': 'CG-77',
    'date': '2030-01-02',
    'time': '10:00',
    'status': 'confirmed',
    'paymentMethod': 'qris',
    'paymentStatus': 'paid',
  });
  List<CustomerBookingSummary> list = [];

  @override
  Future<CustomerBookingSummary> fetchBookingSummary(String id) async => summary;

  @override
  Future<List<CustomerBookingSummary>> fetchBookings() async => list;
}

void main() {
  test('service day follows WIB across UTC midnight', () {
    expect(PaymentFlowController.isServiceToday('2030-01-02', now: DateTime.utc(2030, 1, 1, 18)), isTrue);
    expect(PaymentFlowController.isServiceToday('2030-01-03', now: DateTime.utc(2030, 1, 1, 18)), isFalse);
    expect(PaymentFlowController.isServiceToday('invalid', now: DateTime.utc(2030, 1, 1, 18)), isFalse);
  });

  testWidgets('future date selects matching order by booking ID and opens scheduled orders tab', (tester) async {
    final api = _FakeApi();
    final booking = BookingController(bookingApi: api);
    final orders = OrderController(bookingApi: api);
    addTearDown(booking.dispose);
    addTearDown(orders.dispose);

    // List has two orders: #11 first, #77 second. Must select #77 by backendBookingId!
    api.list = [
      CustomerBookingSummary.fromJson({
        'id': 11, 'code': 'CG-11', 'date': '2030-01-05', 'time': '09:00',
        'status': 'confirmed', 'paymentMethod': 'qris', 'paymentStatus': 'paid',
      }),
      CustomerBookingSummary.fromJson({
        'id': 77, 'code': 'CG-77', 'date': '2030-01-02', 'time': '10:00',
        'status': 'confirmed', 'paymentMethod': 'qris', 'paymentStatus': 'paid',
      }),
    ];

    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider.value(value: booking), ChangeNotifierProvider.value(value: orders)],
      child: MaterialApp(home: Builder(builder: (context) => Scaffold(body: TextButton(
        onPressed: () => completeBookingPayment(context, '77'),
        child: const Text('Complete'),
      )))),
    ));

    await tester.tap(find.text('Complete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(orders.scheduledOrder.backendBookingId, '77');
    expect(find.byType(OrdersPage), findsOneWidget);
    expect(find.byType(OrderStatusPage), findsNothing);
  });

  testWidgets('same-day service selects matching order by booking ID and opens map/order status', (tester) async {
    final api = _FakeApi();
    final nowWib = DateTime.now().toUtc().add(const Duration(hours: 7));
    final todayStr = '${nowWib.year}-${nowWib.month.toString().padLeft(2, '0')}-${nowWib.day.toString().padLeft(2, '0')}';
    api.summary = CustomerBookingSummary.fromJson({
      'id': 88, 'code': 'CG-88', 'date': todayStr, 'time': '10:00',
      'status': 'confirmed', 'paymentMethod': 'qris', 'paymentStatus': 'paid',
    });
    api.list = [
      CustomerBookingSummary.fromJson({
        'id': 88, 'code': 'CG-88', 'date': todayStr, 'time': '10:00',
        'status': 'confirmed', 'paymentMethod': 'qris', 'paymentStatus': 'paid',
      }),
    ];

    final booking = BookingController(bookingApi: api);
    final orders = OrderController(bookingApi: api);
    addTearDown(booking.dispose);
    addTearDown(orders.dispose);

    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider.value(value: booking), ChangeNotifierProvider.value(value: orders)],
      child: MaterialApp(home: Builder(builder: (context) => Scaffold(body: TextButton(
        onPressed: () => completeBookingPayment(context, '88'),
        child: const Text('Complete'),
      )))),
    ));

    await tester.tap(find.text('Complete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(orders.scheduledOrder.backendBookingId, '88');
    expect(find.byType(OrderStatusPage), findsOneWidget);
    expect(find.byType(OrdersPage), findsNothing);
  });

  testWidgets('pending status shows notice and stays on current page without navigation', (tester) async {
    final api = _FakeApi();
    api.summary = CustomerBookingSummary.fromJson({
      'id': 77, 'code': 'CG-77', 'date': '2030-01-02', 'time': '10:00',
      'status': 'awaiting_payment', 'paymentMethod': 'qris', 'paymentStatus': 'pending',
    });

    final booking = BookingController(bookingApi: api);
    final orders = OrderController(bookingApi: api);
    addTearDown(booking.dispose);
    addTearDown(orders.dispose);

    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider.value(value: booking), ChangeNotifierProvider.value(value: orders)],
      child: MaterialApp(home: Builder(builder: (context) => Scaffold(body: TextButton(
        onPressed: () => completeBookingPayment(context, '77'),
        child: const Text('Complete'),
      )))),
    ));

    await tester.tap(find.text('Complete'));
    await tester.pump();
    expect(find.text('Pembayaran belum diterima. Cek kembali; jangan bayar ulang.'), findsOneWidget);
    expect(find.byType(OrdersPage), findsNothing);
    expect(find.byType(OrderStatusPage), findsNothing);
  });

  testWidgets('expired status shows notice and stays on current page', (tester) async {
    final api = _FakeApi();
    api.summary = CustomerBookingSummary.fromJson({
      'id': 77, 'code': 'CG-77', 'date': '2030-01-02', 'time': '10:00',
      'status': 'awaiting_payment', 'paymentMethod': 'qris', 'paymentStatus': 'expired',
    });

    final booking = BookingController(bookingApi: api);
    final orders = OrderController(bookingApi: api);
    addTearDown(booking.dispose);
    addTearDown(orders.dispose);

    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider.value(value: booking), ChangeNotifierProvider.value(value: orders)],
      child: MaterialApp(home: Builder(builder: (context) => Scaffold(body: TextButton(
        onPressed: () => completeBookingPayment(context, '77'),
        child: const Text('Complete'),
      )))),
    ));

    await tester.tap(find.text('Complete'));
    await tester.pump();
    expect(find.text('Sesi pembayaran berakhir. Hubungi admin; jangan bayar ulang.'), findsOneWidget);
    expect(find.byType(OrdersPage), findsNothing);
    expect(find.byType(OrderStatusPage), findsNothing);
  });
}
