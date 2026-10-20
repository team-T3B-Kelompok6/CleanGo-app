import '../domain/models/promo_model.dart';

class CheckoutController {
  static const List<PromoModel> availablePromos = [
    PromoModel(code: 'CLEANHEMAT', discountPercent: 35),
  ];

  PromoModel? _appliedPromo;
  String? _promoError;

  PromoModel? get appliedPromo => _appliedPromo;
  bool get isPromoApplied => _appliedPromo != null;
  String? get promoError => _promoError;
  String? get promoSuccessMessage =>
      isPromoApplied ? 'Kode promo berhasil diterapkan.' : null;

  int discountAmount(int servicePrice) {
    return _appliedPromo?.discountAmount(servicePrice) ?? 0;
  }

  int totalPayment({required int servicePrice, required int platformFee}) {
    return servicePrice - discountAmount(servicePrice) + platformFee;
  }

  void clearPromo() {
    _appliedPromo = null;
    _promoError = null;
  }

  void applyPromo(String code) {
    final normalizedCode = code.trim().toUpperCase();
    clearPromo();

    if (normalizedCode.isEmpty) {
      return;
    }

    for (final promo in availablePromos) {
      if (promo.code == normalizedCode) {
        _appliedPromo = promo;
        return;
      }
    }

    _promoError = 'Kode promo tidak valid.';
  }
}
