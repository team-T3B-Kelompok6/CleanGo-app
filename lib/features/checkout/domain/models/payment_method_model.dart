enum PaymentMethodType { qris, cash }

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
