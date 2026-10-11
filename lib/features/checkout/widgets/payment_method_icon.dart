import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/models/payment_method_model.dart';

final Future<Uint8List> _danaIconBytes = _loadDanaIconBytes();

Future<Uint8List> _loadDanaIconBytes() async {
  final svgSource = await rootBundle.loadString(
    'assets/icons/payment_dana.svg',
  );
  final match = RegExp(r'base64,([^"]+)').firstMatch(svgSource);

  if (match == null) {
    throw const FormatException('Data gambar DANA tidak ditemukan.');
  }

  return base64Decode(match.group(1)!);
}

class PaymentMethodIcon extends StatelessWidget {
  const PaymentMethodIcon({
    required this.method,
    this.size = 40,
    super.key,
  });

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
      child: method.type == PaymentMethodType.dana
          ? FutureBuilder<Uint8List>(
              future: _danaIconBytes,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                return Image.memory(
                  snapshot.data!,
                  width: method.iconWidth,
                  height: method.iconHeight,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                );
              },
            )
          : SvgPicture.asset(
              method.assetPath,
              width: method.iconWidth,
              height: method.iconHeight,
            ),
    );
  }
}
