import 'package:flutter_test/flutter_test.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:cleango_app/features/address/controllers/address_controller.dart';

void main() {
  group('AddressModel Tests', () {
    test('toCleaningAddress converts correctly with (Utama) label if primary', () {
      const model = AddressModel(
        id: 'test-1',
        title: 'Jl. Melati No. 1',
        fullAddress: 'Jl. Melati No. 1, Malang',
        type: 'Rumah',
        contactName: 'Krisna',
        phoneNumber: '08123456789',
        note: 'Pagar Hijau',
        isPrimary: true,
      );

      final cleaningAddress = model.toCleaningAddress();

      expect(cleaningAddress.label, 'Rumah (Utama)');
      expect(cleaningAddress.street, 'Jl. Melati No. 1');
      expect(cleaningAddress.city, 'Jl. Melati No. 1, Malang');
      expect(cleaningAddress.landmark, 'Pagar Hijau');
      expect(cleaningAddress.customerName, 'Krisna');
      expect(cleaningAddress.phoneNumber, '08123456789');
    });

    test('toCleaningAddress converts correctly without (Utama) if not primary', () {
      const model = AddressModel(
        id: 'test-2',
        title: 'Jl. Mawar No. 2',
        fullAddress: 'Jl. Mawar No. 2, Surabaya',
        type: 'Kantor',
        contactName: 'Budi',
        phoneNumber: '08987654321',
        isPrimary: false,
      );

      final cleaningAddress = model.toCleaningAddress();

      expect(cleaningAddress.label, 'Kantor');
      expect(cleaningAddress.city, 'Jl. Mawar No. 2, Surabaya');
    });
  });

  group('AddressController Tests', () {
    late AddressController controller;

    setUp(() {
      controller = AddressController();
    });

    test('Initial addresses has 2 items with primary selected', () {
      expect(controller.addresses.length, 2);
      expect(controller.primaryAddress, isNotNull);
      expect(controller.primaryAddress!.type, 'Rumah');
      expect(controller.selectedAddressId, controller.primaryAddress!.id);
    });

    test('selectAddress updates selectedAddressId', () {
      final secondId = controller.addresses[1].id;
      controller.selectAddress(secondId);

      expect(controller.selectedAddressId, secondId);
      expect(controller.selectedAddress?.id, secondId);
    });

    test('setPrimaryAddress updates primary and demotes previous primary', () {
      final secondId = controller.addresses[1].id;
      controller.setPrimaryAddress(secondId);

      expect(controller.primaryAddress?.id, secondId);
      expect(controller.addresses[0].isPrimary, false);
      expect(controller.addresses[1].isPrimary, true);
    });

    test('addAddress appends to list and updates primary if specified', () {
      const newAddr = AddressModel(
        id: 'addr-new',
        title: 'Apartemen Soekarno Hatta',
        fullAddress: 'Apartemen Soekarno Hatta Lt. 12, Kota Malang',
        type: 'Apartemen',
        contactName: 'Krisna',
        phoneNumber: '08122334455',
        isPrimary: true,
      );

      controller.addAddress(newAddr);

      expect(controller.addresses.length, 3);
      expect(controller.primaryAddress?.id, 'addr-new');
      expect(controller.selectedAddressId, 'addr-new');
      expect(controller.addresses.where((a) => a.isPrimary).length, 1);
    });

    test('updateAddress updates matching address', () {
      final target = controller.addresses.first;
      final updated = target.copyWith(fullAddress: 'Alamat Baru No. 99');

      controller.updateAddress(updated);

      expect(controller.addresses.first.fullAddress, 'Alamat Baru No. 99');
    });

    test('deleteAddress removes item and handles fallback primary if primary was deleted', () {
      final primaryId = controller.primaryAddress!.id;
      controller.deleteAddress(primaryId);

      expect(controller.addresses.length, 1);
      expect(controller.addresses.first.isPrimary, true);
      expect(controller.selectedAddressId, controller.addresses.first.id);
    });
  });
}
