import 'package:flutter_test/flutter_test.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:cleango_app/features/address/controllers/address_controller.dart';

void main() {
  group('AddressModel Tests', () {
    test(
      'toCleaningAddress converts correctly with (Utama) label if primary',
      () {
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
        expect(cleaningAddress.street, model.fullAddress);
        expect(cleaningAddress.city, isEmpty);
        expect(cleaningAddress.fullAddress, model.fullAddress);
        expect(cleaningAddress.landmark, 'Pagar Hijau');
        expect(cleaningAddress.customerName, 'Krisna');
        expect(cleaningAddress.phoneNumber, '08123456789');
      },
    );

    test(
      'toCleaningAddress converts correctly without (Utama) if not primary',
      () {
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
        expect(cleaningAddress.street, model.fullAddress);
        expect(cleaningAddress.city, isEmpty);
        expect(cleaningAddress.fullAddress, model.fullAddress);
      },
    );
  });

  group('AddressController Tests', () {
    late AddressController controller;

    setUp(() {
      controller = AddressController(
        initialAddresses: const [
          AddressModel(
            id: 'uji-1',
            title: 'Rumah Uji',
            fullAddress: 'Jl. Uji No. 1, Kota Uji',
            type: 'Rumah',
            contactName: 'Pemilik Uji',
            phoneNumber: '081200000001',
            isPrimary: true,
          ),
          AddressModel(
            id: 'uji-2',
            title: 'Kantor Uji',
            fullAddress: 'Jl. Uji No. 2, Kota Uji',
            type: 'Kantor',
            contactName: 'Pemilik Uji',
            phoneNumber: '081200000001',
          ),
        ],
      );
    });

    test('Initial addresses keep the given list with primary selected', () {
      expect(controller.addresses.length, 2);
      expect(controller.primaryAddress, isNotNull);
      expect(controller.primaryAddress!.type, 'Rumah');
      expect(controller.selectedAddressId, controller.primaryAddress!.id);
    });

    test('empty initial snapshot stays empty and has no fake address', () {
      final emptyController = AddressController(initialAddresses: const []);

      expect(emptyController.addresses, isEmpty);
      expect(emptyController.selectedAddress, isNull);
      expect(emptyController.primaryAddress, isNull);
      emptyController.dispose();
    });

    test('no initial list starts empty without a seeded address', () {
      final blankController = AddressController();

      expect(blankController.addresses, isEmpty);
      expect(blankController.selectedAddress, isNull);
      blankController.dispose();
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

    test('setPrimaryAddress ignores an unknown id', () {
      final primaryBefore = controller.primaryAddress;
      final selectedBefore = controller.selectedAddressId;

      controller.setPrimaryAddress('missing-address');

      expect(controller.primaryAddress?.id, primaryBefore?.id);
      expect(
        controller.addresses.where((address) => address.isPrimary),
        hasLength(1),
      );
      expect(controller.selectedAddressId, selectedBefore);
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

    test('addAddress rejects addresses after the fifth saved address', () {
      for (var index = controller.addresses.length; index < 5; index++) {
        expect(
          controller.addAddress(
            AddressModel(
              id: 'addr-$index',
              title: 'Alamat $index',
              fullAddress: 'Jl. Mawar No. $index, Kota Malang',
              type: 'Rumah',
              contactName: 'Krisna',
              phoneNumber: '08122334455',
              isPrimary: false,
            ),
          ),
          isTrue,
        );
      }

      expect(controller.addresses, hasLength(5));
      expect(
        controller.addAddress(
          const AddressModel(
            id: 'addr-over-limit',
            title: 'Alamat keenam',
            fullAddress: 'Jl. Melati No. 6, Kota Malang',
            type: 'Rumah',
            contactName: 'Krisna',
            phoneNumber: '08122334455',
            isPrimary: false,
          ),
        ),
        isFalse,
      );
      expect(controller.addresses, hasLength(5));
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

    test('deleteAddress ignores an unknown id without changing data', () {
      final before = controller.addresses;
      final selectedBefore = controller.selectedAddressId;

      controller.deleteAddress('missing-address');

      expect(controller.addresses, orderedEquals(before));
      expect(controller.selectedAddressId, selectedBefore);
    });

    test('deleteAddress safely ignores an unknown id when list is empty', () {
      for (final address in List.of(controller.addresses)) {
        controller.deleteAddress(address.id);
      }

      expect(
        () => controller.deleteAddress('missing-address'),
        returnsNormally,
      );
      expect(controller.addresses, isEmpty);
    });
  });
}
