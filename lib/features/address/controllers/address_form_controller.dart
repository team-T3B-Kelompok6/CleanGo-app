import 'package:flutter/widgets.dart';

import '../domain/models/address_model.dart';
import 'address_form_validator.dart';

class AddressFormController {
  AddressFormController.forNew({this.isPrimary = false})
    : addressTitle = TextEditingController(),
      fullAddress = TextEditingController(),
      note = TextEditingController(),
      contactName = TextEditingController(),
      phone = TextEditingController(),
      selectedType = typeOptions.first;

  AddressFormController.forEdit(AddressModel address)
    : addressTitle = TextEditingController(text: address.title),
      fullAddress = TextEditingController(text: address.fullAddress),
      note = TextEditingController(text: address.note),
      contactName = TextEditingController(text: address.contactName),
      phone = TextEditingController(
        text: address.phoneNumber.replaceAll(RegExp(r'^\(\+62\)\s*'), ''),
      ),
      selectedType = typeOptions.contains(address.type)
          ? address.type
          : typeOptions.first,
      isPrimary = address.isPrimary,
      latitude = address.latitude,
      longitude = address.longitude;

  static const List<String> typeOptions = [
    'Rumah',
    'Kantor',
    'Apartemen',
    'Kost',
    'Lainnya',
  ];

  final TextEditingController addressTitle;
  final TextEditingController fullAddress;
  final TextEditingController note;
  final TextEditingController contactName;
  final TextEditingController phone;

  String selectedType;
  bool isPrimary;
  bool isSaving = false;
  double? latitude;
  double? longitude;

  void selectType(String type) {
    if (typeOptions.contains(type)) selectedType = type;
  }

  void setPrimary(bool value) => isPrimary = value;
  void setSaving(bool value) => isSaving = value;

  void applyMapSelection({
    required double selectedLatitude,
    required double selectedLongitude,
    required String shortLabel,
    required String addressText,
  }) {
    latitude = selectedLatitude;
    longitude = selectedLongitude;
    addressTitle.text = shortLabel;
    fullAddress.text = addressText;
  }

  AddressModel createAddress({required String id}) {
    return AddressModel(
      id: id,
      title: addressTitle.text.trim(),
      fullAddress: fullAddress.text.trim(),
      note: note.text.trim(),
      type: selectedType,
      contactName: contactName.text.trim(),
      phoneNumber: AddressFormValidator.formatPhone(phone.text),
      isPrimary: isPrimary,
      latitude: latitude,
      longitude: longitude,
    );
  }

  AddressModel updateAddress(AddressModel original) {
    return original.copyWith(
      title: addressTitle.text.trim(),
      fullAddress: fullAddress.text.trim(),
      note: note.text.trim(),
      type: selectedType,
      contactName: contactName.text.trim(),
      phoneNumber: AddressFormValidator.formatPhone(phone.text),
      isPrimary: isPrimary,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void dispose() {
    addressTitle.dispose();
    fullAddress.dispose();
    note.dispose();
    contactName.dispose();
    phone.dispose();
  }
}
