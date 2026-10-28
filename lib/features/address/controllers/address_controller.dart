import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';
import '../data/address_repository.dart';
import '../data/customer_address_service.dart';
import '../domain/models/address_model.dart';

class AddressController extends ChangeNotifier {
  static const int maxAddresses = 5;

  AddressController({
    this.repository,
    List<AddressModel>? initialAddresses,
    TokenStorage? tokenStorage,
    CustomerAddressService? remote,
  })  : tokenStorage = tokenStorage,
        _remote = remote ?? CustomerAddressService() {
    _addresses = List<AddressModel>.of(initialAddresses ?? const []);
    _selectedAddressId = _addresses.isEmpty
        ? ''
        : _addresses
            .firstWhere((a) => a.isPrimary, orElse: () => _addresses.first)
            .id;
    _subscription = repository?.watchAddresses().listen(_applySnapshot);
  }

  late List<AddressModel> _addresses;
  late String _selectedAddressId;
  final AddressRepository? repository;
  final TokenStorage? tokenStorage;
  final CustomerAddressService _remote;
  StreamSubscription<AddressSnapshot>? _subscription;
  bool _updatingFromRemote = false;
  String? _error;
  String? get error => _error;
  Future<bool> _usingRemote() async { final t = await tokenStorage?.readAccessToken(); return t != null && t.isNotEmpty; }

  Future<void> loadFromApi() async {
    final token = await tokenStorage?.readAccessToken();
    if (token == null || token.isEmpty) return;
    _updatingFromRemote = true;
    try {
      final remote = await _remote.fetchAddresses(token);
      _addresses = List<AddressModel>.of(remote);
      _selectedAddressId = _addresses.isEmpty
          ? ''
          : _addresses.firstWhere((a) => a.isPrimary, orElse: () => _addresses.first).id;
      _error = null;
      notifyListeners();
      await _persist();
    } catch (e) {
      _error = e.toString();
    } finally {
      _updatingFromRemote = false;
    }
  }

  Future<AddressModel?> createRemote(AddressModel address) async {
    if (!await _usingRemote()) return addAddress(address) ? address : null;
    try {
      final created = await _remote.createAddress(
        (await tokenStorage!.readAccessToken())!,
        address.toApiPayload(),
      );
      if (!_addresses.any((a) => a.id == created.id)) addAddress(created);
      _error = null;
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateRemote(AddressModel address) async {
    if (!await _usingRemote()) { updateAddress(address); return true; }
    try { final updated = await _remote.updateAddress((await tokenStorage!.readAccessToken())!, address.id, address.toApiPayload()); updateAddress(updated); _error = null; return true; } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> deleteRemote(String id) async {
    if (!await _usingRemote()) { deleteAddress(id); return true; }
    try { await _remote.deleteAddress((await tokenStorage!.readAccessToken())!, id); deleteAddress(id); _error = null; return true; } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get canAddAddress => _addresses.length < maxAddresses;
  String get selectedAddressId => _selectedAddressId;

  AddressModel? findById(String? id) {
    if (id == null) return null;
    try {
      return _addresses.firstWhere((address) => address.id == id);
    } catch (_) {
      return null;
    }
  }

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
      _persist();
    }
  }

  void setPrimaryAddress(String id) {
    if (!_addresses.any((address) => address.id == id)) return;

    _addresses = _addresses.map((address) {
      if (address.id == id) {
        return address.copyWith(isPrimary: true);
      }
      return address.copyWith(isPrimary: false);
    }).toList();

    _selectedAddressId = id;
    notifyListeners();
    _persist();
  }

  bool addAddress(AddressModel address) {
    if (!canAddAddress) return false;

    if (address.isPrimary || _addresses.isEmpty) {
      _addresses = _addresses.map((a) => a.copyWith(isPrimary: false)).toList();
    }

    _addresses = [..._addresses, address];
    if (address.isPrimary || _addresses.length == 1) {
      _selectedAddressId = address.id;
    }
    notifyListeners();
    _persist();
    return true;
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
    _persist();
  }

  void deleteAddress(String id) {
    final index = _addresses.indexWhere((address) => address.id == id);
    if (index == -1) return;

    final toDelete = _addresses[index];
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
        _selectedAddressId = _addresses
            .firstWhere((a) => a.isPrimary, orElse: () => _addresses.first)
            .id;
      }
    } else {
      _selectedAddressId = '';
    }

    notifyListeners();
    _persist();
  }

  void _applySnapshot(AddressSnapshot snapshot) {
    if (_updatingFromRemote) return;
    _addresses = List<AddressModel>.of(snapshot.addresses);
    _selectedAddressId = snapshot.selectedAddressId;
    notifyListeners();
  }

  Future<void> clearLocal() async {
    _updatingFromRemote = true;
    try {
      _addresses = const [];
      _selectedAddressId = '';
      notifyListeners();
      await repository?.saveSnapshot(
        const AddressSnapshot(addresses: [], selectedAddressId: ''),
      );
    } finally {
      _updatingFromRemote = false;
    }
  }

  Future<void> _persist() async {
    final storage = repository;
    if (storage == null) return;
    try {
      await storage.saveSnapshot(
        AddressSnapshot(
          addresses: _addresses,
          selectedAddressId: _selectedAddressId,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Gagal menyimpan alamat lokal: $error\n$stackTrace');
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
