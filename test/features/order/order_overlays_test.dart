import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/pages/orders_page.dart';
import 'package:cleango_app/features/order/pages/review_rating_page.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/shared/widgets/app_dialog.dart';
import 'package:cleango_app/shared/widgets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _host(OrderController orders, Widget page) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: orders),
      ChangeNotifierProvider(create: (_) => BookingController()),
      ChangeNotifierProvider(create: (_) => ProfileController()),
      ChangeNotifierProvider(create: (_) => ServiceController()),
    ],
    child: MaterialApp(theme: AppTheme.light, home: page),
  );
}

Future<void> _finishTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

String _addOrder(OrderController orders, String name, {int days = 3}) {
  orders.createOrderFromBooking(
    serviceName: name,
    serviceImagePath: 'assets/images/service_deep_cleaning.jpeg',
    price: 'Rp155.000',
    address: 'Alamat $name',
    note: 'Catatan $name',
    scheduledAt: DateTime.now().add(Duration(days: days)),
  );
  return orders.scheduledOrder.orderNumber;
}

void main() {
  testWidgets('each tracking button selects its own active order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final orders = OrderController()..completeScheduledOrder();
    addTearDown(orders.dispose);
    final firstId = _addOrder(orders, 'Layanan pertama', days: 0);
    final secondId = _addOrder(orders, 'Layanan kedua', days: 0);
    final tracked = <String>[];
    await tester.pumpWidget(
      _host(
        orders,
        OrdersPage(
          onTrackOrder: () => tracked.add(orders.scheduledOrder.orderNumber),
        ),
      ),
    );

    for (final id in [firstId, secondId]) {
      final card = find.byKey(ValueKey(id));
      await tester.scrollUntilVisible(
        card,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final trackButton = find.descendant(
        of: card,
        matching: find.text('Lacak Pesanan'),
      );
      await tester.ensureVisible(trackButton);
      await tester.pump();
      await tester.tap(trackButton);
      await tester.pump();
    }
    expect(tracked, [firstId, secondId]);
    expect(orders.scheduledOrders, hasLength(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('detail and cancellation affect only the tapped order card', (
    tester,
  ) async {
    final orders = OrderController()..completeScheduledOrder();
    addTearDown(orders.dispose);
    final firstId = _addOrder(orders, 'Layanan pertama');
    final secondId = _addOrder(orders, 'Layanan kedua');
    await tester.pumpWidget(_host(orders, const OrdersPage()));

    final card = find.byKey(ValueKey(firstId));
    await tester.scrollUntilVisible(
      card,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final detailButton = find.descendant(
      of: card,
      matching: find.text('Lihat Detail'),
    );
    await tester.ensureVisible(detailButton);
    await tester.pump();
    await tester.tap(detailButton);
    await _finishTransition(tester);
    expect(
      find.descendant(of: find.byType(AppSheet), matching: find.text(firstId)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppSheet),
        matching: find.text('Catatan Layanan pertama'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Batalkan Pesanan'));
    await _finishTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Batalkan Pesanan'));
    await _finishTransition(tester);

    expect(orders.scheduledOrders.single.orderNumber, secondId);
    expect(orders.historyOrders.first.orderId, firstId);
    expect(orders.historyOrders.first.status, 'DIBATALKAN');
    expect(find.text('Belum ada pesanan terjadwal'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('order cancellation requires explicit confirmation', (
    tester,
  ) async {
    final orders = OrderController();
    addTearDown(orders.dispose);
    await tester.pumpWidget(_host(orders, const OrdersPage()));

    Future<void> openCancellation() async {
      await tester.tap(find.text('Lihat Detail').first);
      await _finishTransition(tester);
      await tester.tap(find.text('Batalkan Pesanan'));
      await _finishTransition(tester);
    }

    await openCancellation();
    expect(find.byType(AppDialog), findsOneWidget);
    await tester.tap(find.text('Kembali'));
    await _finishTransition(tester);
    expect(orders.hasScheduledOrder, isTrue);

    await openCancellation();
    await tester.tap(find.widgetWithText(FilledButton, 'Batalkan Pesanan'));
    await _finishTransition(tester);
    expect(orders.hasScheduledOrder, isFalse);
    expect(find.text('Belum ada pesanan terjadwal'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('review success preserves rating, tags and optional comment', (
    tester,
  ) async {
    final orders = OrderController();
    addTearDown(orders.dispose);
    final order = orders.historyOrders.first;
    await tester.pumpWidget(
      _host(
        orders,
        ReviewRatingPage(
          orderId: order.orderId,
          serviceName: order.serviceName,
        ),
      ),
    );
    expect(find.text('Bersih Maksimal'), findsOneWidget);
    final reviewInput = find.byType(TextField);
    await tester.ensureVisible(reviewInput);
    await tester.pump();
    await tester.enterText(reviewInput, 'Layanan rapi dan tepat waktu.');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.ensureVisible(find.text('Kirim Review'));
    await tester.pump();
    await tester.tap(find.text('Kirim Review'));
    await _finishTransition(tester);

    expect(
      find.text('Ulasan berhasil dikirim. Terima kasih atas penilaian Anda.'),
      findsOneWidget,
    );
    expect(find.byType(AppDialog), findsNothing);
    final saved = orders.historyOrders
        .firstWhere((item) => item.orderId == order.orderId)
        .review!;
    expect(saved.rating, 5);
    expect(saved.comment, 'Layanan rapi dan tepat waktu.');
    expect(saved.satisfactionTags, contains('Bersih Maksimal ✨'));
    expect(saved.photoPaths, isEmpty);

    expect(find.byType(OrdersPage), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
