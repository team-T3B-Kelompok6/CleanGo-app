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

    test(
      'rejects a code outside the available promos and clears selection',
      () {
        controller.applyPromo('CLEANHEMAT');
        controller.applyPromo('SALAH');
        expect(controller.isPromoApplied, isFalse);
        expect(controller.promoError, 'Kode promo tidak valid.');

        controller.clearPromo();
        expect(controller.appliedPromo, isNull);
        expect(controller.promoError, isNull);
        expect(controller.promoSuccessMessage, isNull);
      },
    );

    test('allows an empty optional promo without an error', () {
      controller.applyPromo('CLEANHEMAT');
      controller.applyPromo('   ');

      expect(controller.isPromoApplied, isFalse);
      expect(controller.promoError, isNull);
      expect(controller.promoSuccessMessage, isNull);
      expect(
        controller.totalPayment(servicePrice: 150000, platformFee: 5000),
        155000,
      );
    });

    test('available promo calculates savings from the service price only', () {
      final promo = CheckoutController.availablePromos.single;
      controller.applyPromo(promo.code);

      expect(controller.appliedPromo, same(promo));
      expect(promo.discountAmount(150001), 52500);
      expect(
        controller.totalPayment(servicePrice: 150001, platformFee: 5000),
        102501,
      );
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
