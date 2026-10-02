enum PaymentMethodType { dana, gopay, qris, cash }

class PaymentMethodModel {
  const PaymentMethodModel({
    required this.type,
    required this.name,
    required this.assetPath,
    required this.description,
    required this.iconWidth,
    required this.iconHeight,
  });

  final PaymentMethodType type;
  final String name;
  final String assetPath;
  final String description;
  final double iconWidth;
  final double iconHeight;
}

const paymentMethods = <PaymentMethodModel>[
  PaymentMethodModel(
    type: PaymentMethodType.dana,
    name: 'DANA',
    assetPath: 'assets/icons/payment_dana.svg',
    description: 'Bayar instan melalui DANA',
    iconWidth: 30,
    iconHeight: 32,
  ),
  PaymentMethodModel(
    type: PaymentMethodType.gopay,
    name: 'GoPay',
    assetPath: 'assets/icons/payment_gopay.svg',
    description: 'Bayar instan melalui GoPay',
    iconWidth: 30,
    iconHeight: 32,
  ),
  PaymentMethodModel(
    type: PaymentMethodType.qris,
    name: 'QRIS',
    assetPath: 'assets/icons/payment_qris.svg',
    description: 'Bayar instan via e-wallet / m-banking',
    iconWidth: 28,
    iconHeight: 28,
  ),
  PaymentMethodModel(
    type: PaymentMethodType.cash,
    name: 'Tunai',
    assetPath: 'assets/icons/payment_tunai.svg',
    description: 'Bayar langsung setelah layanan selesai',
    iconWidth: 28,
    iconHeight: 30,
  ),
];

PaymentMethodModel paymentMethodByType(PaymentMethodType type) {
  return paymentMethods.firstWhere((method) => method.type == type);
}
