import 'package:flutter/foundation.dart';

import '../../../booking/controllers/booking_controller.dart';

@immutable
class AddressModel {
  const AddressModel({
    required this.id,
    required this.title,
    required this.fullAddress,
    this.note = '',
    required this.type,
    required this.contactName,
    required this.phoneNumber,
    this.isPrimary = false,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title; // Contoh: "Blk. N No.521, Mojolangu, Kec. Lowokwaru"
  final String fullAddress; // Contoh: "Blk. N No.521, Mojolangu, Kec. Lowokwaru, Kota Malang..."
  final String note; // Contoh: "Patokan pagar hitam sebelah minimarket"
  final String type; // "Rumah", "Kantor", "Apartemen", "Kost", "Lainnya"
  final String contactName; // "krisna"
  final String phoneNumber; // "(+62) 081223728077"
  final bool isPrimary;
  final double? latitude;
  final double? longitude;

  // Backward compatibility getters
  String get label => type;
  String get streetAddress => fullAddress;
  String get city => '';
  String get postalCode => '';
  String get landmark => note;
  String get recipientName => contactName;

  AddressModel copyWith({
    String? id,
    String? title,
    String? fullAddress,
    String? note,
    String? type,
    String? contactName,
    String? phoneNumber,
    bool? isPrimary,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      note: note ?? this.note,
      type: type ?? this.type,
      contactName: contactName ?? this.contactName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPrimary: isPrimary ?? this.isPrimary,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Konversi ke CleaningAddress untuk kompatibilitas penuh dengan BookingController
  CleaningAddress toCleaningAddress() {
    final fullLabel = isPrimary ? '$type (Utama)' : type;
    return CleaningAddress(
      label: fullLabel,
      street: title,
      city: fullAddress,
      landmark: note,
      customerName: contactName,
      phoneNumber: phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          fullAddress == other.fullAddress &&
          note == other.note &&
          type == other.type &&
          contactName == other.contactName &&
          phoneNumber == other.phoneNumber &&
          isPrimary == other.isPrimary &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      fullAddress.hashCode ^
      note.hashCode ^
      type.hashCode ^
      contactName.hashCode ^
      phoneNumber.hashCode ^
      isPrimary.hashCode ^
      latitude.hashCode ^
      longitude.hashCode;
}
