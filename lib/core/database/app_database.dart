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

@DataClassName('BookingDraftRow')
class BookingDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get serviceId => text()();
  IntColumn get selectedDate => integer()();
  TextColumn get selectedTime => text()();
  TextColumn get addressId => text().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ServiceCacheRow')
class ServiceCaches extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get synced => boolean().withDefault(const Constant(true))();
  IntColumn get lastFetched => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [StoredAddresses, BookingDrafts, ServiceCaches])
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults() : super(driftDatabase(name: 'cleango_local'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(bookingDrafts);
        await migrator.createTable(serviceCaches);
      }
    },
  );

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

  Stream<BookingDraftRow?> watchBookingDraft(String id) {
    return (select(
      bookingDrafts,
    )..where((draft) => draft.id.equals(id))).watchSingleOrNull();
  }

  Future<BookingDraftRow?> readBookingDraft(String id) {
    return (select(
      bookingDrafts,
    )..where((draft) => draft.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveBookingDraft(BookingDraftsCompanion draft) {
    return into(bookingDrafts).insertOnConflictUpdate(draft);
  }

  Future<void> deleteBookingDraft(String id) {
    return (delete(bookingDrafts)..where((draft) => draft.id.equals(id))).go();
  }

  Stream<List<ServiceCacheRow>> watchServiceCache() {
    return (select(
      serviceCaches,
    )..orderBy([(service) => OrderingTerm.asc(service.sortOrder)])).watch();
  }

  Future<List<ServiceCacheRow>> readServiceCache() {
    return (select(
      serviceCaches,
    )..orderBy([(service) => OrderingTerm.asc(service.sortOrder)])).get();
  }

  Future<void> seedServiceCacheIfEmpty(
    List<ServiceCachesCompanion> services,
  ) async {
    await transaction(() async {
      final count = await serviceCaches.count().getSingle();
      if (count > 0) return;
      await batch((batch) => batch.insertAll(serviceCaches, services));
    });
  }

  Future<void> replaceServiceCache(
    List<ServiceCachesCompanion> services,
  ) async {
    await transaction(() async {
      await delete(serviceCaches).go();
      if (services.isNotEmpty) {
        await batch((batch) => batch.insertAll(serviceCaches, services));
      }
    });
  }
}
