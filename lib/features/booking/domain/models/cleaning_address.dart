import 'package:flutter/foundation.dart';

@immutable
class CleaningAddress {
  const CleaningAddress({
    required this.label,
    required this.street,
    required this.city,
    required this.landmark,
    required this.customerName,
    required this.phoneNumber,
  });

  final String label;
  final String street;
  final String city;
  final String landmark;
  final String customerName;
  final String phoneNumber;

  String get fullAddress =>
      [street.trim(), city.trim()].where((part) => part.isNotEmpty).join(', ');
}
