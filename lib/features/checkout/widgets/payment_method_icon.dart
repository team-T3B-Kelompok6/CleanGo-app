import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/models/payment_method_model.dart';

class PaymentMethodIcon extends StatelessWidget {
  const PaymentMethodIcon({required this.method, this.size = 40, super.key});

  final PaymentMethodModel method;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: SvgPicture.asset(
        method.assetPath,
        width: method.iconWidth,
        height: method.iconHeight,
      ),
    );
  }
}
