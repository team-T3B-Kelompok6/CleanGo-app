import 'package:cleango_app/features/checkout/controllers/checkout_controller.dart';
import 'package:cleango_app/features/checkout/data/customer_promo_api.dart';
import 'package:cleango_app/features/checkout/domain/models/promo_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePromoApi extends CustomerPromoApi {
  _FakePromoApi({
    this.promos = const [],
    this.validated,
    this.failValidate = false,
  });

  final List<PromoModel> promos;
  final PromoModel? validated;
  final bool failValidate;
  int listCalls = 0;
  int validateCalls = 0;
  String? lastCode;
  int? lastAmount;
  String? lastServiceId;

  @override
  Future<List<PromoModel>> fetchPromos() async {
    listCalls++;
    return promos;
  }

  @override
  Future<PromoModel> validate({
    required String code,
    required int amount,
    String? serviceId,
  }) async {
    validateCalls++;
    lastCode = code;
    lastAmount = amount;
    lastServiceId = serviceId;
    if (failValidate) throw StateError('offline');
    return validated ?? PromoModel(code: code, discountPercent: 10);
  }
}

void main() {
  group('PromoModel.fromApiJson', () {
    test('maps a percentage promo with a cap', () {
      final promo = PromoModel.fromApiJson({
        'code': 'AWAL20',
        'name': 'Diskon Awal Bulan',
        'discountType': 'percentage',
        'discountValue': 20,
        'maxDiscount': 50000,
        'minPurchase': 150000,
        'scope': 'all',
        'serviceIds': [],
        'discountAmount': 30000,
      });

      expect(promo.code, 'AWAL20');
      expect(promo.title, 'Diskon Awal Bulan');
      expect(promo.discountPercent, 20);
      expect(promo.discountAmount(150000), 30000);
    });

    test('maps a fixed promo', () {
      final promo = PromoModel.fromApiJson({
        'code': 'POTONG25',
        'discountType': 'fixed',
        'discountValue': 25000,
      });

      expect(promo.discountType, 'fixed');
      expect(promo.discountAmount(100000), 25000);
    });

    test('keeps the service scope list', () {
      final promo = PromoModel.fromApiJson({
        'code': 'SOFA',
        'discountType': 'percentage',
        'discountValue': 10,
        'scope': 'services',
        'serviceIds': ['7', '8'],
      });

      expect(promo.scope, 'services');
      expect(promo.serviceIds, ['7', '8']);
    });
  });

  group('PromoModel.discountAmount', () {
    test('caps a percentage discount by maxDiscount', () {
      const promo = PromoModel(
        code: 'X',
        discountType: 'percentage',
        discountValue: 50,
        maxDiscount: 20000,
      );

      expect(promo.discountAmount(100000), 20000);
    });

    test('never exceeds the price', () {
      const promo = PromoModel(
        code: 'X',
        discountType: 'fixed',
        discountValue: 900000,
      );

      expect(promo.discountAmount(100000), 100000);
    });

    test('uses the backend amount when provided', () {
      const promo = PromoModel(
        code: 'X',
        discountType: 'percentage',
        discountValue: 50,
        serverDiscountAmount: 12345,
      );

      expect(promo.discountAmount(100000), 12345);
    });
  });

  group('CheckoutController promo integration', () {
    test('selects a loaded backend promo from the promo page', () async {
      final promo = PromoModel(code: 'AWAL20', discountPercent: 20);
      final controller = CheckoutController(
        promoApi: _FakePromoApi(promos: [promo]),
      );
      await controller.loadPromos();

      controller.applyPromo(' awal20 ');

      expect(controller.appliedPromo, same(promo));
      expect(controller.discountAmount(150000), 30000);
      expect(controller.promoError, isNull);
    });

    test('loads the promo list from the backend', () async {
      final api = _FakePromoApi(
        promos: [PromoModel(code: 'AWAL20', discountPercent: 20)],
      );
      final controller = CheckoutController(promoApi: api);

      await controller.loadPromos();

      expect(api.listCalls, 1);
      expect(controller.promos.single.code, 'AWAL20');
    });

    test('keeps the bundled list when loading fails', () async {
      final controller = CheckoutController(promoApi: _FakePromoApi());

      await controller.loadPromos();

      expect(controller.promos, CheckoutController.availablePromos);
    });

    test('applies a server-only code through validation', () async {
      final api = _FakePromoApi(
        validated: const PromoModel(
          code: 'AWAL20',
          discountType: 'percentage',
          discountValue: 20,
          maxDiscount: 50000,
          serverDiscountAmount: 30000,
        ),
      );
      final controller = CheckoutController(promoApi: api);

      await controller.applyPromoRemote(
        code: 'awal20',
        servicePrice: 150000,
        serviceId: '7',
      );

      expect(api.validateCalls, 1);
      expect(api.lastCode, 'AWAL20');
      expect(api.lastAmount, 150000);
      expect(api.lastServiceId, '7');
      expect(controller.discountAmount(150000), 30000);
      expect(controller.promoError, isNull);
    });

    test('falls back to the bundled list when validation fails', () async {
      final controller = CheckoutController(
        promoApi: _FakePromoApi(failValidate: true),
      );

      await controller.applyPromoRemote(
        code: 'CLEANHEMAT',
        servicePrice: 150000,
      );

      expect(controller.appliedPromo?.code, 'CLEANHEMAT');
      expect(controller.discountAmount(150000), 52500);
    });

    test('reports an error for an unknown code when offline', () async {
      final controller = CheckoutController(
        promoApi: _FakePromoApi(failValidate: true),
      );

      await controller.applyPromoRemote(code: 'TIDAKADA', servicePrice: 150000);

      expect(controller.appliedPromo, isNull);
      expect(controller.promoError, isNotNull);
    });

    test('works without an api (local-only mode)', () async {
      final controller = CheckoutController();

      await controller.applyPromoRemote(
        code: 'cleanhemat',
        servicePrice: 150000,
      );

      expect(controller.appliedPromo?.code, 'CLEANHEMAT');
    });
  });
}
