import 'package:cleango_app/features/checkout/controllers/checkout_controller.dart';
import 'package:cleango_app/features/checkout/data/customer_promo_api.dart';
import 'package:cleango_app/features/checkout/domain/models/promo_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePromoApi extends CustomerPromoApi {
  final List<PromoModel> promos;
  final bool shouldFail;

  _FakePromoApi({this.promos = const [], this.shouldFail = false});

  @override
  Future<List<PromoModel>> fetchPromos({String? serviceId}) async {
    if (shouldFail) throw Exception('network error');
    return promos;
  }

  @override
  Future<PromoModel> validate({
    required String code,
    required int amount,
    String? serviceId,
  }) async {
    if (shouldFail) throw Exception('network error');
    final promo = promos.firstWhere(
      (p) => p.code.toUpperCase() == code.toUpperCase(),
      orElse: () => throw Exception('Kode promo tidak valid.'),
    );
    return promo;
  }
}

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

    test('applies CLEANHEMAT case-insensitively with 35 percent discount', () async {
      final api = _FakePromoApi(
        promos: [
          PromoModel(code: 'CLEANHEMAT', discountPercent: 35),
        ],
      );
      final controller = CheckoutController(promoApi: api);
      await controller.loadPromos();
      await controller.applyPromoRemote(
        code: ' cleanhemat ',
        servicePrice: 150000,
      );

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
      () async {
        final api = _FakePromoApi(promos: []);
        final controller = CheckoutController(promoApi: api);
        await controller.loadPromos();

        await controller.applyPromoRemote(code: 'SALAH', servicePrice: 150000);
        expect(controller.isPromoApplied, isFalse);
        expect(controller.promoError, 'Kode promo tidak dapat digunakan.');

        controller.clearPromo();
        expect(controller.appliedPromo, isNull);
        expect(controller.promoError, isNull);
        expect(controller.promoSuccessMessage, isNull);
      },
    );

    test('allows an empty optional promo without an error', () async {
      final api = _FakePromoApi(
        promos: [PromoModel(code: 'CLEANHEMAT', discountPercent: 35)],
      );
      final controller = CheckoutController(promoApi: api);
      await controller.loadPromos();

      controller.applyPromo('   ');

      expect(controller.isPromoApplied, isFalse);
      expect(controller.promoError, isNull);
      expect(controller.promoSuccessMessage, isNull);
      expect(
        controller.totalPayment(servicePrice: 150000, platformFee: 5000),
        155000,
      );
    });

    test('available promo calculates savings from the service price only', () async {
      final api = _FakePromoApi(
        promos: [PromoModel(code: 'CLEANHEMAT', discountPercent: 35)],
      );
      final controller = CheckoutController(promoApi: api);
      await controller.loadPromos();
      final promo = controller.promos.single;
      await controller.applyPromoRemote(code: promo.code, servicePrice: 150001);

      expect(controller.appliedPromo, same(promo));
      expect(promo.discountAmount(150001), 52500);
      expect(
        controller.totalPayment(servicePrice: 150001, platformFee: 5000),
        102501,
      );
    });

    test('replaces an invalid promo error after a valid retry', () async {
      final api = _FakePromoApi(
        promos: [PromoModel(code: 'CLEANHEMAT', discountPercent: 35)],
      );
      final controller = CheckoutController(promoApi: api);
      await controller.loadPromos();

      await controller.applyPromoRemote(code: 'SALAH', servicePrice: 150000);
      await controller.applyPromoRemote(code: 'cleanhemat', servicePrice: 150000);

      expect(controller.isPromoApplied, isTrue);
      expect(controller.promoError, isNull);
      expect(controller.promoSuccessMessage, 'Kode promo berhasil diterapkan.');
    });
  });
}
