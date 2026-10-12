import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/pages/orders_page.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'scheduled empty state appears after the active order is removed',
    (tester) async {
      final orderController = OrderController();
      orderController.completeScheduledOrder();
      expect(orderController.hasScheduledOrder, isFalse);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => BookingController()),
            ChangeNotifierProvider.value(value: orderController),
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider(create: (_) => ServiceController()),
          ],
          child: const MaterialApp(home: OrdersPage()),
        ),
      );

      expect(find.text('Belum ada pesanan terjadwal'), findsOneWidget);
    },
  );
}
