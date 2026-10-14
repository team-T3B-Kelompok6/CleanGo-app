import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/address_model.dart';

class AddressSnapshot {
  const AddressSnapshot({
    required this.addresses,
    required this.selectedAddressId,
  });

  final List<AddressModel> addresses;
  final String selectedAddressId;
}

class AddressRepository {
  AddressRepository(this._database);

  final AppDatabase _database;

  Stream<AddressSnapshot> watchAddresses() {
    return _database.watchAddresses().map(_snapshotFromRows);
  }

  Future<AddressSnapshot> readAddresses() async {
    return _snapshotFromRows(await _database.readAddresses());
  }

  Future<void> seedDefaultsIfEmpty(List<AddressModel> addresses) {
    return _database.seedAddressesIfEmpty(
      _companions(addresses, _primaryOrFirstId(addresses)),
    );
  }

  Future<void> saveSnapshot(AddressSnapshot snapshot) {
    return _database.replaceAddresses(
      _companions(snapshot.addresses, snapshot.selectedAddressId),
    );
  }

  AddressSnapshot _snapshotFromRows(List<StoredAddressRow> rows) {
    final addresses = rows.map(_addressFromRow).toList(growable: false);
    StoredAddressRow? selected;
    for (final row in rows) {
      if (row.isSelected) {
        selected = row;
        break;
      }
    }
    return AddressSnapshot(
      addresses: addresses,
      selectedAddressId: selected?.id ?? _primaryOrFirstId(addresses),
    );
  }

  AddressModel _addressFromRow(StoredAddressRow row) {
    return AddressModel(
      id: row.id,
      title: row.title,
      fullAddress: row.fullAddress,
      note: row.note,
      type: row.type,
      contactName: row.contactName,
      phoneNumber: row.phoneNumber,
      isPrimary: row.isPrimary,
      latitude: row.latitude,
      longitude: row.longitude,
    );
  }

  List<StoredAddressesCompanion> _companions(
    List<AddressModel> addresses,
    String selectedAddressId,
  ) {
    final savedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    return List<StoredAddressesCompanion>.generate(addresses.length, (index) {
      final address = addresses[index];
      return StoredAddressesCompanion.insert(
        id: address.id,
        title: address.title,
        fullAddress: address.fullAddress,
        note: Value(address.note),
        type: address.type,
        contactName: address.contactName,
        phoneNumber: address.phoneNumber,
        isPrimary: Value(address.isPrimary),
        isSelected: Value(address.id == selectedAddressId),
        latitude: Value(address.latitude),
        longitude: Value(address.longitude),
        sortOrder: index,
        updatedAt: savedAt,
      );
    }, growable: false);
  }

  String _primaryOrFirstId(List<AddressModel> addresses) {
    if (addresses.isEmpty) return '';
    return addresses
        .firstWhere(
          (address) => address.isPrimary,
          orElse: () => addresses.first,
        )
        .id;
  }
}
