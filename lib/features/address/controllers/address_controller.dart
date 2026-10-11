import 'package:flutter/foundation.dart';
import '../domain/models/address_model.dart';

class AddressController extends ChangeNotifier {
  AddressController() {
    _addresses = List<AddressModel>.from(_initialAddresses);
    _selectedAddressId = _addresses.firstWhere((a) => a.isPrimary, orElse: () => _addresses.first).id;
  }

  static const List<AddressModel> _initialAddresses = [
    AddressModel(
      id: 'addr-1',
      title: 'Blk. N No.521, Mojolangu, Kec. Lowokwaru',
      fullAddress:
          'Blk. N No.521, Mojolangu, Kec. Lowokwaru, Kota Malang, Jawa Timur 65141, Indonesia',
      note: 'Patokan pagar hitam sebelah minimarket',
      type: 'Rumah',
      contactName: 'krisna',
      phoneNumber: '(+62) 081223728077',
      isPrimary: true,
    ),
    AddressModel(
      id: 'addr-2',
      title: 'Jl. Sudirman No. 123, Lantai 4',
      fullAddress:
          'Jl. Sudirman No. 123, Lantai 4, Gedung Equity Tower, Jakarta Selatan, DKI Jakarta 12190, Indonesia',
      note: '',
      type: 'Kantor',
      contactName: 'krisna',
      phoneNumber: '(+62) 081223728077',
      isPrimary: false,
    ),
  ];

  late List<AddressModel> _addresses;
  late String _selectedAddressId;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  String get selectedAddressId => _selectedAddressId;

  AddressModel? get selectedAddress {
    try {
      return _addresses.firstWhere((a) => a.id == _selectedAddressId);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  AddressModel? get primaryAddress {
    try {
      return _addresses.firstWhere((a) => a.isPrimary);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  void selectAddress(String id) {
    if (_selectedAddressId == id) return;
    final exists = _addresses.any((a) => a.id == id);
    if (exists) {
      _selectedAddressId = id;
      notifyListeners();
    }
  }

  void setPrimaryAddress(String id) {
    _addresses = _addresses.map((address) {
      if (address.id == id) {
        return address.copyWith(isPrimary: true);
      }
      return address.copyWith(isPrimary: false);
    }).toList();

    _selectedAddressId = id;
    notifyListeners();
  }

  void addAddress(AddressModel address) {
    if (address.isPrimary || _addresses.isEmpty) {
      _addresses = _addresses.map((a) => a.copyWith(isPrimary: false)).toList();
    }

    _addresses = [..._addresses, address];
    if (address.isPrimary || _addresses.length == 1) {
      _selectedAddressId = address.id;
    }
    notifyListeners();
  }

  void updateAddress(AddressModel updatedAddress) {
    final index = _addresses.indexWhere((a) => a.id == updatedAddress.id);
    if (index == -1) return;

    if (updatedAddress.isPrimary) {
      _addresses = _addresses.map((a) {
        if (a.id == updatedAddress.id) {
          return updatedAddress;
        }
        return a.copyWith(isPrimary: false);
      }).toList();
    } else {
      _addresses = [
        ..._addresses.sublist(0, index),
        updatedAddress,
        ..._addresses.sublist(index + 1),
      ];
      // Jika tidak ada alamat utama yang tersisa, jadikan yang pertama sebagai utama
      if (!_addresses.any((a) => a.isPrimary) && _addresses.isNotEmpty) {
        _addresses = [
          _addresses.first.copyWith(isPrimary: true),
          ..._addresses.sublist(1),
        ];
      }
    }

    notifyListeners();
  }

  void deleteAddress(String id) {
    final toDelete = _addresses.firstWhere((a) => a.id == id, orElse: () => _addresses.first);
    final wasPrimary = toDelete.isPrimary;
    final wasSelected = _selectedAddressId == id;

    _addresses = _addresses.where((a) => a.id != id).toList();

    if (_addresses.isNotEmpty) {
      if (wasPrimary && !_addresses.any((a) => a.isPrimary)) {
        _addresses = [
          _addresses.first.copyWith(isPrimary: true),
          ..._addresses.sublist(1),
        ];
      }
      if (wasSelected) {
        _selectedAddressId = _addresses.firstWhere((a) => a.isPrimary, orElse: () => _addresses.first).id;
      }
    } else {
      _selectedAddressId = '';
    }

    notifyListeners();
  }
}
