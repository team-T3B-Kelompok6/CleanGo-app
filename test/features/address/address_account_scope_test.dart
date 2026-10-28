import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/address/controllers/address_controller.dart';
import 'package:cleango_app/features/address/data/address_repository.dart';
import 'package:cleango_app/features/address/data/customer_address_service.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:cleango_app/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeTokens implements TokenStorage {
  _FakeTokens(this.token);
  String? token;
  @override
  Future<String?> readAccessToken() async => token;
  @override
  Future<void> writeAccessToken(String token) async => this.token = token;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<DateTime?> readExpiresAt() async => null;
  @override
  Future<void> writeExpiresAt(DateTime expiresAt) async {}
  @override
  Future<void> clearSession() async => token = null;
}

final class _FakeRemote implements CustomerAddressService {
  _FakeRemote(this.addresses);
  List<AddressModel> addresses;
  @override
  Future<List<AddressModel>> fetchAddresses(String token) async => addresses;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _lama = AddressModel(
  id: 'akun-a',
  title: 'Rumah Akun A',
  fullAddress: 'Jl. A No. 1',
  type: 'Rumah',
  contactName: 'Akun A',
  phoneNumber: '081200000001',
  isPrimary: true,
);

void main() {
  test('daftar server kosong menggantikan cache alamat akun sebelumnya', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = AddressRepository(database);
    await repository.saveSnapshot(
      const AddressSnapshot(addresses: [_lama], selectedAddressId: 'akun-a'),
    );
    final controller = AddressController(
      repository: repository,
      initialAddresses: const [_lama],
      tokenStorage: _FakeTokens('token-b'),
      remote: _FakeRemote(const []),
    );

    await controller.loadFromApi();

    expect(controller.addresses, isEmpty);
    expect((await repository.readAddresses()).addresses, isEmpty);
    controller.dispose();
    await database.close();
  });

  test('clearLocal menghapus alamat di memori dan di cache', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = AddressRepository(database);
    await repository.saveSnapshot(
      const AddressSnapshot(addresses: [_lama], selectedAddressId: 'akun-a'),
    );
    final controller = AddressController(
      repository: repository,
      initialAddresses: const [_lama],
    );

    await controller.clearLocal();

    expect(controller.addresses, isEmpty);
    expect(controller.selectedAddress, isNull);
    expect((await repository.readAddresses()).addresses, isEmpty);
    controller.dispose();
    await database.close();
  });
}
