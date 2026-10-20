import 'package:cleango_app/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('migrasi versi 1 ke 2 mempertahankan alamat lama', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute('''
          CREATE TABLE stored_addresses (
            id TEXT NOT NULL PRIMARY KEY,
            title TEXT NOT NULL,
            full_address TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            type TEXT NOT NULL,
            contact_name TEXT NOT NULL,
            phone_number TEXT NOT NULL,
            is_primary INTEGER NOT NULL DEFAULT 0,
            is_selected INTEGER NOT NULL DEFAULT 0,
            latitude REAL,
            longitude REAL,
            sort_order INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          INSERT INTO stored_addresses VALUES (
            'addr-old', 'Rumah', 'Kota Malang', '', 'Rumah', 'Krisna',
            '81234567890', 1, 1, NULL, NULL, 0, 1
          )
        ''');
        database.execute('PRAGMA user_version = 1');
      },
    );
    final database = AppDatabase(executor);

    expect((await database.readAddresses()).single.id, 'addr-old');
    expect(await database.readBookingDraft('active-booking'), isNull);
    expect(await database.readServiceCache(), isEmpty);

    await database.close();
  });

  test('transaksi gagal melakukan rollback seluruh penulisan', () async {
    final database = AppDatabase(NativeDatabase.memory());

    await expectLater(
      database.transaction(() async {
        await database.saveBookingDraft(
          BookingDraftsCompanion.insert(
            id: 'active-booking',
            serviceId: 'deep-cleaning',
            selectedDate: 1,
            selectedTime: '12:00',
            updatedAt: 1,
          ),
        );
        throw StateError('simulasi kegagalan');
      }),
      throwsStateError,
    );

    expect(await database.readBookingDraft('active-booking'), isNull);
    await database.close();
  });
}
