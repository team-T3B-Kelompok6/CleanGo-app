class CheckoutController {
  static const String validPromoCode = 'CLEANHEMAT';
  static const double promoDiscountRate = 0.35;

  bool _isPromoApplied = false;
  String? _promoError;
  String? _promoSuccessMessage;

  bool get isPromoApplied => _isPromoApplied;
  String? get promoError => _promoError;
  String? get promoSuccessMessage => _promoSuccessMessage;

  int discountAmount(int servicePrice) {
    if (!_isPromoApplied) {
      return 0;
    }

    return (servicePrice * promoDiscountRate).round();
  }

  int totalPayment({required int servicePrice, required int platformFee}) {
    return servicePrice - discountAmount(servicePrice) + platformFee;
  }

  bool updatePromoInput(String _) {
    final hasStateChanged =
        _isPromoApplied ||
        _promoError != null ||
        _promoSuccessMessage != null;

    _isPromoApplied = false;
    _promoError = null;
    _promoSuccessMessage = null;
    return hasStateChanged;
  }

  void applyPromo(String code) {
    final normalizedCode = code.trim().toUpperCase();

    if (normalizedCode.isEmpty) {
      _isPromoApplied = false;
      _promoError = null;
      _promoSuccessMessage = null;
      return;
    }

    if (normalizedCode != validPromoCode) {
      _isPromoApplied = false;
      _promoError = 'Kode promo tidak valid.';
      _promoSuccessMessage = null;
      return;
    }

    _isPromoApplied = true;
    _promoError = null;
    _promoSuccessMessage = 'Kode promo berhasil diterapkan.';
  }
}
