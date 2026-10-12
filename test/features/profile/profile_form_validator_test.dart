import 'package:cleango_app/features/profile/controllers/profile_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileFormValidator', () {
    test('rejects empty required fields including whitespace', () {
      expect(ProfileFormValidator.fullName('   '), 'Nama lengkap wajib diisi.');
      expect(ProfileFormValidator.phone('   '), 'Nomor telepon wajib diisi.');
      expect(ProfileFormValidator.email('   '), 'Alamat email wajib diisi.');
    });

    test('rejects invalid name and phone characters', () {
      expect(
        ProfileFormValidator.fullName('12345'),
        'Masukkan nama lengkap yang valid.',
      );
      expect(
        ProfileFormValidator.fullName('---'),
        'Masukkan nama lengkap yang valid.',
      );
      expect(
        ProfileFormValidator.phone('abc81234567890'),
        'Masukkan nomor telepon yang valid.',
      );
    });

    test('accepts valid profile values', () {
      expect(ProfileFormValidator.fullName('Krisna Pratama'), isNull);
      expect(ProfileFormValidator.phone('81234567890'), isNull);
      expect(ProfileFormValidator.email('krisna@example.com'), isNull);
    });
  });
}
