import '../data/customer_promo_api.dart';
import '../domain/models/promo_model.dart';

class CheckoutController {
  CheckoutController({CustomerPromoApi? promoApi})
      : _promoApi = promoApi,
        _promos = const [];

  static const List<PromoModel> availablePromos = [
  ];

  final CustomerPromoApi? _promoApi;
  List<PromoModel> _promos;
  PromoModel? _appliedPromo;
  String? _promoError;
  /// Promos offered to the customer (backend list when loaded).
  List<PromoModel> get promos => List.unmodifiable(_promos);

  /// Loads the active promo list; keeps the bundled fallback on failure.
  Future<void> loadPromos({String? serviceId}) async {
    final api = _promoApi;
    if (api == null) return;
    try {
      final promos = await api.fetchPromos(serviceId: serviceId);
      _promos = promos;
      _promoError = null;
    } catch (e) {
      // Real API failed: never show the bundled demo list as if it were live.
      _promos = const [];
      _promoError = e.toString();
    }
  }

  /// Validates the code on the backend and stores the returned discount.
  /// The backend is always authoritative; known entries cannot bypass
  /// validation, and a server rejection is never masked by a local match.
  /// Without a configured backend (pure local mode) the bundled list applies.
  Future<void> applyPromoRemote({
    required String code,
    required int servicePrice,
    String? serviceId,
  }) async {
    final normalized = code.trim().toUpperCase();
    clearPromo();
    if (normalized.isEmpty) return;

    final api = _promoApi;
    if (api == null) {
      // Local-only mode: no backend is configured, so use the bundled list.
      final local = _localMatch(normalized);
      if (local != null) {
        _appliedPromo = local;
        return;
      }
      _promoError = 'Kode promo tidak valid.';
      return;
    }
    try {
      _appliedPromo = await api.validate(
        code: normalized,
        amount: servicePrice,
        serviceId: serviceId,
      );
    } catch (error) {
      _promoError = _messageFor(error);
    }
  }

  PromoModel? _localMatch(String code) {
    for (final promo in _promos) {
      if (promo.code == code) return promo;
    }
    return null;
  }

  String _messageFor(Object error) {
    final message = error.toString();
    // ApiException exposes a friendly message already.
    final match = RegExp(r'ApiException\(\d+\): (.+)').firstMatch(message);
    if (match != null) return match.group(1)!.trim();
    return 'Kode promo tidak dapat digunakan.';
  }

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

    final candidates = _promoApi == null
        ? <PromoModel>[..._promos, ...availablePromos]
        : _promos;
    for (final promo in candidates) {
      if (promo.code == normalizedCode) {
        _appliedPromo = promo;
        return;
      }
    }

    _promoError = 'Kode promo tidak valid.';
  }
}