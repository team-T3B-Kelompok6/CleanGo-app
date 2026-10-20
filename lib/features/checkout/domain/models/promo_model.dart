class PromoModel {
  const PromoModel({
    required this.code,
    this.discountPercent = 0,
    this.name = '',
    this.discountType = 'percentage',
    this.discountValue,
    this.maxDiscount,
    this.minPurchase = 0,
    this.scope = 'all',
    this.serviceIds = const [],
    this.serverDiscountAmount,
  });

  final String code;
  final int discountPercent;
  final String name;
  final String discountType;
  final num? discountValue;
  final int? maxDiscount;
  final int minPurchase;
  final String scope;
  final List<String> serviceIds;

  /// Discount computed by the backend for the current cart, when available.
  final int? serverDiscountAmount;

  String get title =>
      name.isNotEmpty ? name : 'Diskon $discountPercent% biaya layanan';

  /// Mirrors the backend rule (`calculateDiscount`): percentage → round with a
  /// maxDiscount cap, fixed → nominal, never above the price.
  int discountAmount(int servicePrice) {
    if (servicePrice <= 0) return 0;
    final server = serverDiscountAmount;
    if (server != null) {
      return server < 0 ? 0 : (server > servicePrice ? servicePrice : server);
    }
    final value = discountValue ?? discountPercent;
    final raw = discountType == 'fixed'
        ? value.round()
        : (servicePrice * (value > 100 ? 100 : value) / 100).round();
    final cap = discountType == 'percentage' ? maxDiscount : null;
    final capped = cap != null && raw > cap ? cap : raw;
    return capped < 0 ? 0 : (capped > servicePrice ? servicePrice : capped);
  }

  factory PromoModel.fromApiJson(Map<String, dynamic> json) {
    final type = json['discountType'] as String? ?? 'percentage';
    final value = json['discountValue'] as num?;
    return PromoModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      discountType: type,
      discountValue: value,
      discountPercent: type == 'percentage' ? (value?.toInt() ?? 0) : 0,
      maxDiscount: (json['maxDiscount'] as num?)?.toInt(),
      minPurchase: (json['minPurchase'] as num?)?.toInt() ?? 0,
      scope: json['scope'] as String? ?? 'all',
      serviceIds: (json['serviceIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      serverDiscountAmount: (json['discountAmount'] as num?)?.toInt(),
    );
  }
}
