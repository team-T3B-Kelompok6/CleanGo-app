import 'package:cleango_app/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutController', () {
    late CheckoutController controller;

    setUp(() => controller = CheckoutController());

    test('keeps the original total when promo is not applied', () {
      expect(
        controller.totalPayment(servicePrice: 150000, platformFee: 5000),
        155000,
      );
      expect(controller.discountAmount(150000), 0);
    });

    test('applies CLEANHEMAT case-insensitively with 35 percent discount', () {
      controller.applyPromo(' cleanhemat ');

      expect(controller.isPromoApplied, isTrue);
      expect(controller.promoError, isNull);
      expect(controller.promoSuccessMessage, 'Kode promo berhasil diterapkan.');
      expect(controller.discountAmount(150000), 52500);
      expect(
        controller.totalPayment(servicePrice: 150000, platformFee: 5000),
        102500,
      );
    });

    test('reports invalid promo and clears feedback after input changes', () {
      controller.applyPromo('SALAH');
      expect(controller.isPromoApplied, isFalse);
      expect(controller.promoError, 'Kode promo tidak valid.');

      expect(controller.updatePromoInput('S'), isTrue);
      expect(controller.promoError, isNull);
      expect(controller.promoSuccessMessage, isNull);
    });

    test('allows an empty optional promo without an error', () {
      controller.applyPromo('   ');

      expect(controller.isPromoApplied, isFalse);
      expect(controller.promoError, isNull);
      expect(controller.promoSuccessMessage, isNull);
    });

    test('replaces an invalid promo error after a valid retry', () {
      controller.applyPromo('SALAH');
      controller.applyPromo('cleanhemat');

      expect(controller.isPromoApplied, isTrue);
      expect(controller.promoError, isNull);
      expect(controller.promoSuccessMessage, 'Kode promo berhasil diterapkan.');
    });
  });
}
