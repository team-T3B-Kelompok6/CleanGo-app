import 'package:cleango_app/features/address/controllers/address_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressFormValidator', () {
    test('rejects empty required fields including whitespace', () {
      expect(AddressFormValidator.address('   '), 'Alamat wajib diisi.');
      expect(
        AddressFormValidator.fullAddress('   '),
        'Alamat lengkap wajib diisi.',
      );
      expect(
        AddressFormValidator.contactName('   '),
        'Nama kontak wajib diisi.',
      );
      expect(AddressFormValidator.phone('   '), 'Nomor telepon wajib diisi.');
    });

    test('rejects invalid characters instead of silently removing them', () {
      expect(
        AddressFormValidator.phone('abc81234567890'),
        'Masukkan nomor telepon yang valid setelah +62.',
      );
      expect(
        AddressFormValidator.contactName('Krisna123'),
        'Masukkan nama kontak yang valid.',
      );
      expect(
        AddressFormValidator.contactName('...'),
        'Masukkan nama kontak yang valid.',
      );
    });

    test('accepts valid address form values', () {
      expect(AddressFormValidator.address('Rumah Utama'), isNull);
      expect(
        AddressFormValidator.fullAddress('Jl. Mawar No. 10, Kota Malang'),
        isNull,
      );
      expect(AddressFormValidator.contactName('Krisna Pratama'), isNull);
      expect(AddressFormValidator.phone('81234567890'), isNull);
    });
  });
}
