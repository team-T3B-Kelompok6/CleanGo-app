import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/checkout/domain/models/payment_method_model.dart';
import 'package:cleango_app/features/checkout/pages/payment_page.dart';
import 'package:cleango_app/features/order/controllers/order_controller.dart';
import 'package:cleango_app/features/order/pages/orders_page.dart';
import 'package:cleango_app/features/profile/controllers/profile_controller.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FailingDraftBooking extends BookingController {
  @override
  Future<void> clearDraft() async => throw Exception('Storage unavailable');
}

void main() {
  Future<OrderController> openPayment(
    WidgetTester tester, {
    BookingController? booking,
  }) async {
    final draft = booking ?? BookingController();
    draft
      ..startBooking(ServiceData.services.first)
      ..selectDate(DateTime.now().add(const Duration(days: 1)))
      ..selectTime('10:00');
    final orders = OrderController()..completeScheduledOrder();
    addTearDown(draft.dispose);
    addTearDown(orders.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: draft),
          ChangeNotifierProvider.value(value: orders),
          ChangeNotifierProvider(create: (_) => AddressController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => ServiceController()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PaymentPage(
            method: paymentMethodByType(PaymentMethodType.qris),
            totalPayment: 'Rp155.000',
            servicePrice: 150000,
            platformFee: 5000,
            discountAmount: 0,
          ),
        ),
      ),
    );
    return orders;
  }

  testWidgets(
    'payment shows a notice, navigates directly and ignores repeated submission',
    (tester) async {
      final orders = await openPayment(tester);
      var updates = 0;
      orders.addListener(() => updates++);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Saya Sudah Membayar'),
      );
      button.onPressed!();
      button.onPressed!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(updates, 1);
      expect(orders.hasScheduledOrder, isTrue);
      expect(find.byType(OrdersPage), findsOneWidget);
      expect(
        find.text('Pembayaran berhasil. Pesanan Anda sudah dikonfirmasi.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('storage failure shows error and does not create an order', (
    tester,
  ) async {
    final orders = await openPayment(tester, booking: _FailingDraftBooking());
    await tester.tap(find.text('Saya Sudah Membayar'));
    await tester.pumpAndSettle();
    expect(orders.hasScheduledOrder, isFalse);
    expect(find.byType(PaymentPage), findsOneWidget);
    expect(
      find.text('Pesanan belum berhasil diproses. Silakan coba lagi.'),
      findsOneWidget,
    );
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      AppColors.notification,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Saya Sudah Membayar'),
          )
          .onPressed,
      isNotNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
