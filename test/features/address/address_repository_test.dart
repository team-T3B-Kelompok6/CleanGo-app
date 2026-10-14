import 'package:cleango_app/core/database/app_database.dart';
import 'package:cleango_app/features/address/data/address_repository.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late AddressRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = AddressRepository(database);
  });

  tearDown(() => database.close());

  test('menyimpan alamat terstruktur dan mengalirkannya lewat watch', () async {
    const address = AddressModel(
      id: 'addr-test',
      title: 'Jl. Mawar No. 10',
      fullAddress: 'Jl. Mawar No. 10, Lowokwaru, Kota Malang, Jawa Timur',
      type: 'Rumah',
      contactName: 'Krisna',
      phoneNumber: '81234567890',
      isPrimary: true,
      latitude: -7.9526,
      longitude: 112.6136,
    );

    final firstEmission = repository.watchAddresses().firstWhere(
      (snapshot) => snapshot.addresses.isNotEmpty,
    );
    await repository.saveSnapshot(
      const AddressSnapshot(
        addresses: [address],
        selectedAddressId: 'addr-test',
      ),
    );
    final snapshot = await firstEmission;

    expect(snapshot.addresses, [address]);
    expect(snapshot.selectedAddressId, 'addr-test');
  });

  test(
    'mengganti beberapa alamat secara atomik dalam satu transaksi',
    () async {
      const addresses = [
        AddressModel(
          id: 'addr-1',
          title: 'Rumah',
          fullAddress: 'Kota Malang',
          type: 'Rumah',
          contactName: 'Krisna',
          phoneNumber: '81234567890',
          isPrimary: true,
        ),
        AddressModel(
          id: 'addr-2',
          title: 'Kantor',
          fullAddress: 'Kota Malang',
          type: 'Kantor',
          contactName: 'Krisna',
          phoneNumber: '81234567890',
        ),
      ];

      await repository.saveSnapshot(
        const AddressSnapshot(
          addresses: addresses,
          selectedAddressId: 'addr-2',
        ),
      );
      final snapshot = await repository.readAddresses();

      expect(snapshot.addresses, hasLength(2));
      expect(snapshot.addresses.map((address) => address.id), [
        'addr-1',
        'addr-2',
      ]);
      expect(snapshot.selectedAddressId, 'addr-2');
    },
  );
}
