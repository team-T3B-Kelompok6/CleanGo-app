class PromoModel {
  const PromoModel({required this.code, required this.discountPercent});

  final String code;
  final int discountPercent;

  String get title => 'Diskon $discountPercent% biaya layanan';

  int discountAmount(int servicePrice) {
    return (servicePrice * discountPercent / 100).round();
  }
}
