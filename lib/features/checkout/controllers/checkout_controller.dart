import '../data/customer_promo_api.dart';
import '../domain/models/promo_model.dart';

class CheckoutController {
  CheckoutController({CustomerPromoApi? promoApi}) : _promoApi = promoApi;

  /// Bundled fallback used before the promo list is loaded from the backend.
  static const List<PromoModel> availablePromos = [
    PromoModel(code: 'CLEANHEMAT', discountPercent: 35),
  ];

  final CustomerPromoApi? _promoApi;
  List<PromoModel> _promos = availablePromos;
  PromoModel? _appliedPromo;
  String? _promoError;

  /// Promos offered to the customer (backend list when loaded).
  List<PromoModel> get promos => List.unmodifiable(_promos);

  /// Loads the active promo list; keeps the bundled fallback on failure.
  Future<void> loadPromos() async {
    final api = _promoApi;
    if (api == null) return;
    try {
      final promos = await api.fetchPromos();
      if (promos.isNotEmpty) _promos = promos;
    } catch (_) {
      // offline / no session: keep the bundled list
    }
  }

  /// Validates the code on the backend and stores the returned discount.
  /// Falls back to the local list when no api is configured.
  Future<void> applyPromoRemote({
    required String code,
    required int servicePrice,
    String? serviceId,
  }) async {
    final normalized = code.trim().toUpperCase();
    clearPromo();
    if (normalized.isEmpty) return;

    // Codes from the (backend) promo list are already known locally, so apply
    // them instantly. Only unknown codes need a server round-trip.
    final known = _localMatch(normalized);
    if (known != null) {
      _appliedPromo = known;
      return;
    }

    final api = _promoApi;
    if (api == null) {
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
      // Offline or no session: keep working with the bundled promo list.
      final local = _localMatch(normalized);
      if (local != null) {
        _appliedPromo = local;
        return;
      }
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

    for (final promo in availablePromos) {
      if (promo.code == normalizedCode) {
        _appliedPromo = promo;
        return;
      }
    }

    _promoError = 'Kode promo tidak valid.';
  }
}
