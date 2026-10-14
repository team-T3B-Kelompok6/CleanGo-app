import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('StoredAddressRow')
class StoredAddresses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get fullAddress => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get type => text()();
  TextColumn get contactName => text()();
  TextColumn get phoneNumber => text()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  BoolColumn get isSelected => boolean().withDefault(const Constant(false))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get sortOrder => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [StoredAddresses])
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults() : super(driftDatabase(name: 'cleango_local'));

  @override
  int get schemaVersion => 1;

  Stream<List<StoredAddressRow>> watchAddresses() {
    return (select(
      storedAddresses,
    )..orderBy([(address) => OrderingTerm.asc(address.sortOrder)])).watch();
  }

  Future<List<StoredAddressRow>> readAddresses() {
    return (select(
      storedAddresses,
    )..orderBy([(address) => OrderingTerm.asc(address.sortOrder)])).get();
  }

  Future<void> seedAddressesIfEmpty(
    List<StoredAddressesCompanion> addresses,
  ) async {
    await transaction(() async {
      final count = await storedAddresses.count().getSingle();
      if (count > 0) return;
      await batch((batch) => batch.insertAll(storedAddresses, addresses));
    });
  }

  Future<void> replaceAddresses(
    List<StoredAddressesCompanion> addresses,
  ) async {
    await transaction(() async {
      await delete(storedAddresses).go();
      if (addresses.isNotEmpty) {
        await batch((batch) => batch.insertAll(storedAddresses, addresses));
      }
    });
  }
}
