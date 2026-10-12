import 'package:cleango_app/features/address/controllers/address_form_controller.dart';
import 'package:cleango_app/features/address/domain/models/address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressFormController', () {
    test('builds a new address from normalized form values', () {
      final controller = AddressFormController.forNew(isPrimary: true);
      addTearDown(controller.dispose);

      controller
        ..addressTitle.text = '  Jl. Mawar No. 10  '
        ..fullAddress.text = '  Lowokwaru, Kota Malang, Jawa Timur  '
        ..note.text = '  Pagar hitam  '
        ..contactName.text = '  Krisna  '
        ..phone.text = '081234567890'
        ..selectType('Kost')
        ..applyMapSelection(
          selectedLatitude: -7.95,
          selectedLongitude: 112.61,
          shortLabel: 'Jl. Mawar No. 10',
          addressText: 'Lowokwaru, Kota Malang, Jawa Timur',
        );

      final address = controller.createAddress(id: 'addr-new');

      expect(address.id, 'addr-new');
      expect(address.title, 'Jl. Mawar No. 10');
      expect(address.fullAddress, 'Lowokwaru, Kota Malang, Jawa Timur');
      expect(address.type, 'Kost');
      expect(address.contactName, 'Krisna');
      expect(address.phoneNumber, '(+62) 81234567890');
      expect(address.isPrimary, isTrue);
      expect(address.latitude, -7.95);
      expect(address.longitude, 112.61);
    });

    test('loads and updates an existing address without changing its id', () {
      const original = AddressModel(
        id: 'addr-1',
        title: 'Alamat lama',
        fullAddress: 'Alamat lama lengkap',
        type: 'Rumah',
        contactName: 'Krisna',
        phoneNumber: '(+62) 81234567890',
        isPrimary: true,
      );
      final controller = AddressFormController.forEdit(original);
      addTearDown(controller.dispose);

      expect(controller.phone.text, '81234567890');
      controller
        ..addressTitle.text = 'Alamat baru'
        ..setPrimary(false);

      final updated = controller.updateAddress(original);

      expect(updated.id, original.id);
      expect(updated.title, 'Alamat baru');
      expect(updated.fullAddress, original.fullAddress);
      expect(updated.isPrimary, isFalse);
    });
  });
}
