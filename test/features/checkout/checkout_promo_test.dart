import 'package:cleango_app/core/theme/app_theme.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:cleango_app/features/booking/controllers/booking_controller.dart';
import 'package:cleango_app/features/checkout/pages/checkout_page.dart';
import 'package:cleango_app/features/checkout/pages/payment_page.dart';
import 'package:cleango_app/features/checkout/pages/promo_page.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final promoSelector = find.byKey(const ValueKey('checkout-promo-selector'));
  final promoOption = find.byKey(const ValueKey('promo-CLEANHEMAT'));
  final confirmPromo = find.byKey(const ValueKey('confirm-promo'));

  Future<void> openCheckout(
    WidgetTester tester, {
    VoidCallback? onApplyPromo,
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BookingController()
          ..startBooking(ServiceData.services.first)
          ..selectDate(DateTime.now().add(const Duration(days: 1)))
          ..selectTime('12:00'),
        child: MaterialApp(
          theme: AppTheme.light,
          home: CheckoutPage(onApplyPromo: onApplyPromo),
        ),
      ),
    );
  }

  Future<void> openPromos(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      promoSelector,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(promoSelector);
    await tester.pumpAndSettle();
  }

  Future<void> applyPromo(WidgetTester tester) async {
    await openPromos(tester);
    await tester.tap(promoOption);
    await tester.pump();
    await tester.tap(confirmPromo);
    await tester.pumpAndSettle();
  }

  testWidgets('work address is shown once across checkout and payment', (
    tester,
  ) async {
    const address = AddressModel(
      id: 'address-checkout',
      title: 'Jl. Mawar No. 12',
      fullAddress: 'Jl. Mawar No. 12, Lowokwaru, Kota Malang, Jawa Timur',
      type: 'Rumah',
      contactName: 'Krisna',
      phoneNumber: '081234567890',
    );
    final booking = BookingController(
      initialService: ServiceData.services.first,
      initialAddress: address.toCleaningAddress(),
    )..selectDate(DateTime.now().add(const Duration(days: 1)));
    addTearDown(booking.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: booking,
        child: MaterialApp(theme: AppTheme.light, home: const CheckoutPage()),
      ),
    );

    expect(find.text(address.fullAddress), findsOneWidget);
    await tester.tap(find.text('Bayar Rp155.000'));
    await tester.pumpAndSettle();
    expect(find.text('Rumah\n${address.fullAddress}'), findsOneWidget);

    final continueToPayment = find.text('Lanjut Bayar');
    await tester.ensureVisible(continueToPayment);
    await tester.tap(continueToPayment);
    await tester.pumpAndSettle();
    expect(find.text('Rumah\n${address.fullAddress}'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'selects a promo without typing and passes the discount to payment',
    (tester) async {
      var appliedCount = 0;
      await openCheckout(tester, onApplyPromo: () => appliedCount++);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Bayar Rp155.000'), findsOneWidget);

      await openPromos(tester);
      expect(find.byType(PromoPage), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Diskon 35% biaya layanan'), findsOneWidget);
      expect(find.text('Hemat Rp52.500'), findsOneWidget);
      expect(find.text('Lanjutkan tanpa Promo'), findsOneWidget);

      await tester.tap(promoOption);
      await tester.pump();
      expect(find.text('Gunakan Promo'), findsOneWidget);
      expect(appliedCount, 0);
      await tester.tap(confirmPromo);
      await tester.pumpAndSettle();

      expect(find.text('Bayar Rp102.500'), findsOneWidget);
      expect(find.text('Kode promo berhasil diterapkan.'), findsOneWidget);
      expect(appliedCount, 1);
      await tester.tap(find.text('Bayar Rp102.500'));
      await tester.pumpAndSettle();
      final continueToPayment = find.text('Lanjut Bayar');
      await tester.ensureVisible(continueToPayment);
      await tester.tap(continueToPayment);
      await tester.pumpAndSettle();

      final payment = tester.widget<PaymentPage>(find.byType(PaymentPage));
      expect(payment.servicePrice, 150000);
      expect(payment.platformFee, 5000);
      expect(payment.discountAmount, 52500);
      expect(payment.totalPayment, 'Rp102.500');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'back cancels edits and continuing without promo removes discount',
    (tester) async {
      var appliedCount = 0;
      await openCheckout(tester, onApplyPromo: () => appliedCount++);
      await applyPromo(tester);

      await openPromos(tester);
      expect(find.text('Gunakan Promo'), findsOneWidget);
      await tester.tap(promoOption);
      await tester.pump();
      expect(find.text('Lanjutkan tanpa Promo'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('promo-back')));
      await tester.pumpAndSettle();
      expect(find.text('Bayar Rp102.500'), findsOneWidget);
      expect(appliedCount, 1);

      await openPromos(tester);
      await tester.tap(promoOption);
      await tester.pump();
      await tester.tap(confirmPromo);
      await tester.pumpAndSettle();

      expect(find.text('Bayar Rp155.000'), findsOneWidget);
      expect(find.text('Diskon Promo (35%)'), findsNothing);
      expect(find.text('Kode promo berhasil diterapkan.'), findsNothing);
      expect(find.text('Pilih promo yang tersedia'), findsOneWidget);
      expect(appliedCount, 2);
    },
  );

  testWidgets('promo is optional and back discards an unconfirmed selection', (
    tester,
  ) async {
    await openCheckout(tester);
    await openPromos(tester);
    await tester.tap(confirmPromo);
    await tester.pumpAndSettle();
    expect(find.text('Bayar Rp155.000'), findsOneWidget);

    await openPromos(tester);
    await tester.tap(promoOption);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Bayar Rp155.000'), findsOneWidget);
    expect(find.text('Kode promo berhasil diterapkan.'), findsNothing);
  });

  testWidgets('promo choices wrap on a narrow screen with larger text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const PromoPage(servicePrice: 150000),
      ),
    );
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank_rounded), findsNothing);
    await tester.tap(promoOption);
    await tester.pump();

    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
    expect(find.text('Gunakan Promo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
