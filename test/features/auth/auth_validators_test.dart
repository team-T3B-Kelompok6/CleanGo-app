import 'package:cleango_app/features/auth/data/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators', () {
    test('accepts Indonesian mobile phone formats', () {
      for (final phone in [
        '81234567890',
        '081234567890',
        '6281234567890',
        '+6281234567890',
      ]) {
        expect(AuthValidators.phone(phone), isNull);
      }
    });

    test('rejects missing and malformed phone numbers', () {
      for (final phone in [null, '', '   ']) {
        expect(AuthValidators.phone(phone), 'Nomor telepon wajib diisi.');
      }
      for (final phone in [
        '123',
        '0812abc7890',
        '080123456789',
        '08123456789012345',
      ]) {
        expect(
          AuthValidators.phone(phone),
          'Masukkan nomor telepon yang valid.',
        );
      }
    });

    test(
      'requires a password without imposing registration rules on login',
      () {
        for (final password in [null, '', '   ']) {
          expect(
            AuthValidators.requiredPassword(password),
            'Kata sandi wajib diisi.',
          );
          expect(
            AuthValidators.registerPassword(password),
            'Kata sandi wajib diisi.',
          );
        }
        expect(AuthValidators.requiredPassword('short'), isNull);
      },
    );

    test('enforces registration password length boundaries', () {
      expect(
        AuthValidators.registerPassword('a' * 7),
        'Password minimal 8 karakter.',
      );
      expect(AuthValidators.registerPassword('a' * 8), isNull);
      expect(AuthValidators.registerPassword('a' * 32), isNull);
      expect(
        AuthValidators.registerPassword('a' * 33),
        'Password maksimal 32 karakter.',
      );
    });

    test('requires a name containing letters and valid characters', () {
      for (final name in [null, '', '   ']) {
        expect(AuthValidators.name(name), 'Nama wajib diisi.');
      }
      for (final name in ['12345', '---', 'Budi123', '<script>']) {
        expect(AuthValidators.name(name), 'Masukkan nama yang valid.');
      }
      expect(AuthValidators.name('Krisna Pratama'), isNull);
      expect(AuthValidators.name("Élodie O'Neil"), isNull);
    });

    test('requires exact password confirmation', () {
      for (final confirmation in [null, '', '   ']) {
        expect(
          AuthValidators.confirmPassword(confirmation, 'Password123'),
          'Konfirmasi password wajib diisi.',
        );
      }
      expect(
        AuthValidators.confirmPassword(' Password123 ', 'Password123'),
        'Konfirmasi password belum sama.',
      );
      expect(
        AuthValidators.confirmPassword('password123', 'Password123'),
        'Konfirmasi password belum sama.',
      );
      expect(
        AuthValidators.confirmPassword('Password123', 'Password123'),
        isNull,
      );
    });
  });
}
