import 'package:cleango_app/core/constants/app_routes.dart';
import 'package:cleango_app/core/notifications/open_booking_notification.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/booking/data/customer_booking_api.dart';
import 'package:cleango_app/features/checkout/pages/pending_payment_page.dart';
import 'package:cleango_app/features/checkout/pages/midtrans_checkout_page.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/message/controllers/message_controller.dart';
import 'package:cleango_app/features/message/domain/models/message_notification_model.dart';
import 'package:cleango_app/features/message/pages/messages_page.dart';

import 'dart:async';
import 'dart:convert';

import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakeTokens implements TokenStorage {
  FakeTokens(this.token);
  final String token;
  @override
  Future<String?> readAccessToken() async => token;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BookingApi extends CustomerBookingApi {
  String status = 'awaiting_payment';
  final requests = <String, Completer<void>>{};
  String method = 'qris';
  String paymentStatus = 'pending';
  bool fail = false;
  int reads = 0;
  int payments = 0;

  CustomerBookingSummary get booking => CustomerBookingSummary.fromJson({
    'id': '77',
    'code': 'CG-77',
    'status': status,
    'paymentMethod': method,
    'paymentStatus': paymentStatus,
    'service': 'Basic Home Cleaning',
    'date': '2026-11-15',
    'time': '14:00',
    'totalAmount': 100000,
  });

  @override
  Future<CustomerBookingSummary> fetchBookingSummary(String bookingId) async {
    reads++;
    await requests[bookingId]?.future;
    if (fail) throw StateError('offline');
    return CustomerBookingSummary.fromJson({
      'id': bookingId,
      'status': status,
      'paymentMethod': method,
      'paymentStatus': paymentStatus,
      if (status == 'awaiting_payment' && method != 'cash' && paymentStatus == 'pending')
        'checkoutUrl': 'https://app.sandbox.midtrans.com/snap/v2/vtweb/test-token',
    });
  }

  @override
  Future<List<CustomerBookingSummary>> fetchBookings() async => [booking];

  @override
  Future<BookingPayment> pay({
    required String bookingId,
    required String method,
  }) {
    payments++;
    throw StateError('Opening notifications must not charge');
  }
}

void main() {
  test('detail DB statuses and list labels share one normalized contract', () {
    const labels = {
      'awaiting_payment': 'Menunggu Pembayaran',
      'confirmed': 'Menunggu Assign',
      'assigned': 'Menunggu Lokasi',
      'departed': 'Menuju Lokasi',
      'en_route': 'Menuju Lokasi',
      'in_progress': 'Sedang Dikerjakan',
      'completed': 'Selesai',
      'cancelled': 'Batal',
      'rescheduled': 'Dijadwalkan Ulang',
    };
    for (final entry in labels.entries) {
      expect(
        CustomerBookingSummary.fromJson({'status': entry.key}).status,
        entry.value,
      );
      expect(
        CustomerBookingSummary.fromJson({'status': entry.value}).status,
        entry.value,
      );
    }
  });

  test('CustomerBookingApi.fetchBookingSummary parses real backend response and normalizes database status', () async {
    final client = ApiClient(
      client: MockClient((request) async {
        expect(request.url.path, '/api/customer/bookings/42');
        return http.Response(
          jsonEncode({
            'data': {
              'id': 42,
              'code': 'CG-42',
              'status': 'awaiting_payment',
              'paymentStatus': 'pending',
              'paymentMethod': 'qris',
              'service': 'Deep Cleaning',
              'date': '2026-11-15',
              'time': '10:00',
              'totalAmount': 200000,
            },
          }),
          200,
        );
      }),
      baseUrl: 'http://localhost:3001',
    );
    addTearDown(client.close);

    final api = CustomerBookingApi(
      client: client,
      tokenStorage: FakeTokens('mock-token'),
    );
    final summary = await api.fetchBookingSummary('42');
    expect(summary.id, '42');
    expect(summary.status, 'Menunggu Pembayaran');
    expect(summary.isFinished, isFalse);
  });

  Future<void> pumpApp(
    WidgetTester tester,
    _BookingApi api, {
    String type = 'order',
    String id = '77',
  }) async {
    final booking = BookingController(bookingApi: api);
    final orders = OrderController(bookingApi: api);
    addTearDown(booking.dispose);
    addTearDown(orders.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: booking),
          ChangeNotifierProvider.value(value: orders),
        ],
        child: MaterialApp(
          routes: {
            AppRoutes.orderStatus: (_) =>
                const Scaffold(body: Text('Order detail')),
            AppRoutes.orders: (_) => const Scaffold(body: Text('Orders list')),
          },
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    openBookingNotification(context, type: type, bookingId: id),
                child: const Text('Open notification'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open notification'));
    await tester.pumpAndSettle();
  }

  testWidgets('pending notification opens original payment without charging', (
    tester,
  ) async {
    final api = _BookingApi();
    await pumpApp(tester, api);
    expect(find.byType(PendingPaymentPage), findsOneWidget);
    expect(
      tester
          .widget<PendingPaymentPage>(find.byType(PendingPaymentPage))
          .booking
          .id,
      '77',
    );
    expect(
      tester.widget<MidtransCheckoutPage>(find.byType(MidtransCheckoutPage)).checkoutUri.toString(),
      'https://app.sandbox.midtrans.com/snap/v2/vtweb/test-token',
    );
    expect(api.reads, 1);
    expect(api.payments, 0);
  });

  testWidgets('old pending notification uses latest paid status', (
    tester,
  ) async {
    final api = _BookingApi()
      ..status = 'confirmed'
      ..paymentStatus = 'paid';
    await pumpApp(tester, api);
    expect(find.text('Order detail'), findsOneWidget);
    expect(find.byType(PendingPaymentPage), findsNothing);
    expect(api.payments, 0);
  });

  testWidgets('confirmed cash opens order, not QRIS', (tester) async {
    final api = _BookingApi()
      ..status = 'confirmed'
      ..method = 'cash';
    await pumpApp(tester, api, type: 'payment');
    expect(find.text('Order detail'), findsOneWidget);
    expect(api.payments, 0);
  });

  testWidgets('cancelled booking never reopens payment', (tester) async {
    final api = _BookingApi()..status = 'cancelled';
    await pumpApp(tester, api);
    expect(find.text('Orders list'), findsOneWidget);
    expect(find.byType(PendingPaymentPage), findsNothing);
    expect(api.payments, 0);
  });

  testWidgets('completed raw detail status never opens payment', (
    tester,
  ) async {
    final api = _BookingApi()..status = 'completed';
    await pumpApp(tester, api);
    expect(find.text('Orders list'), findsOneWidget);
    expect(find.byType(PendingPaymentPage), findsNothing);
    expect(api.payments, 0);
  });

  testWidgets('failed refresh does not navigate using stale booking', (
    tester,
  ) async {
    final api = _BookingApi()..fail = true;
    await pumpApp(tester, api);
    expect(find.text('Open notification'), findsOneWidget);
    expect(find.byType(PendingPaymentPage), findsNothing);
    expect(api.payments, 0);
  });

  testWidgets('invalid ID and unrelated type never fetch or charge', (
    tester,
  ) async {
    final api = _BookingApi();
    await pumpApp(tester, api, id: '../77');
    expect(api.reads, 0);
    await pumpApp(tester, api, type: 'promo');
    expect(api.reads, 0);
    expect(api.payments, 0);
  });

  testWidgets(
    'tapping an inbox card with bookingId routes to pending payment without charging',
    (tester) async {
      final api = _BookingApi();
      final booking = BookingController(bookingApi: api);
      final orders = OrderController(bookingApi: api);
      final messages = MessageController(
        initialMessages: [
          MessageNotificationModel(
            id: '1',
            type: 'order',
            bookingId: '77',
            title: 'Menunggu Pembayaran',
            description: 'Selesaikan pembayaran',
            timeLabel: 'Baru saja',
            category: MessageCategory.order,
            iconType: MessageIconType.payment,
            isUnread: true,
          ),
        ],
      );
      addTearDown(booking.dispose);
      addTearDown(orders.dispose);
      addTearDown(messages.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: booking),
            ChangeNotifierProvider.value(value: orders),
            ChangeNotifierProvider.value(value: messages),
          ],
          child: const MaterialApp(home: MessagesPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final card = find.byKey(const ValueKey('notification-1'));
      expect(card, findsOneWidget);
      await tester.tap(card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PendingPaymentPage), findsOneWidget);
      expect(api.reads, 1);
      expect(api.payments, 0);
    },
  );

  testWidgets(
    'double-tap coalesces into a single fetch and avoids duplicate route pushes',
    (tester) async {
      final api = _BookingApi();
      final pause = Completer<void>();
      api.requests['77'] = pause;
      api.requests['88'] = Completer<void>();

      final booking = BookingController(bookingApi: api);
      final orders = OrderController(bookingApi: api);
      addTearDown(booking.dispose);
      addTearDown(orders.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: booking),
            ChangeNotifierProvider.value(value: orders),
          ],
          child: MaterialApp(
            routes: {
              AppRoutes.orderStatus: (_) =>
                  const Scaffold(body: Text('Order detail')),
              AppRoutes.orders: (_) =>
                  const Scaffold(body: Text('Orders list')),
            },
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () => openBookingNotification(
                        context,
                        type: 'order',
                        bookingId: '77',
                      ),
                      child: const Text('Open 77'),
                    ),
                    TextButton(
                      onPressed: () => openBookingNotification(
                        context,
                        type: 'order',
                        bookingId: '88',
                      ),
                      child: const Text('Open 88'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Tap twice quickly while the API request is still pending
      await tester.tap(find.text('Open 77'));
      await tester.pump();
      await tester.tap(find.text('Open 77'));
      await tester.pump();

      expect(api.reads, 1); // Second tap on same ID coalesced

      // Tap 88 supersedes 77
      await tester.tap(find.text('Open 88'));
      await tester.pump();
      expect(api.reads, 2);

      // When 77 finishes late, it is ignored because 88 is current
      pause.complete();
      await tester.pump();
      expect(find.byType(PendingPaymentPage), findsNothing);

      // When 88 finishes, it navigates
      api.requests['88']!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(PendingPaymentPage), findsOneWidget);
      expect(
        tester
            .widget<PendingPaymentPage>(find.byType(PendingPaymentPage))
            .booking
            .id,
        '88',
      );
      expect(api.payments, 0);
    },
  );
}
