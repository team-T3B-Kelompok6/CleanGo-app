import 'package:cleango_app/features/auth/data/dummy_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DummyAuthService', () {
    const auth = DummyAuthService();

    test('accepts the configured phone formats and password', () {
      expect(auth.login(phone: '81234567890', password: '321321'), isTrue);
      expect(auth.login(phone: '081234567890', password: '321321'), isTrue);
      expect(auth.login(phone: '+6281234567890', password: '321321'), isTrue);
    });

    test('returns independent credential errors', () {
      final wrongPhone = auth.validateLogin(
        phone: '81234567891',
        password: '321321',
      );
      expect(wrongPhone.phoneError, 'Nomor telepon tidak terdaftar.');
      expect(wrongPhone.passwordError, isNull);

      final wrongPassword = auth.validateLogin(
        phone: '81234567890',
        password: 'salah',
      );
      expect(wrongPassword.phoneError, isNull);
      expect(
        wrongPassword.passwordError,
        'Kata sandi tidak sesuai. Coba lagi atau klik "Lupa Kata Sandi" untuk mengatur ulang.',
      );
    });

    test(
      'returns required and format validation errors before credentials',
      () {
        final empty = auth.validateLogin(phone: '', password: '');
        expect(empty.phoneError, 'Nomor telepon wajib diisi.');
        expect(empty.passwordError, 'Kata sandi wajib diisi.');

        final invalidPhone = auth.validateLogin(
          phone: '123',
          password: '321321',
        );
        expect(invalidPhone.phoneError, 'Masukkan nomor telepon yang valid.');
        expect(invalidPhone.passwordError, isNull);
      },
    );

    test('treats whitespace-only passwords as empty', () {
      expect(AuthValidators.requiredPassword('   '), 'Kata sandi wajib diisi.');
      expect(
        AuthValidators.registerPassword('        '),
        'Kata sandi wajib diisi.',
      );
    });

    test('caps passwords at 32 characters', () {
      expect(
        AuthValidators.registerPassword('a'.padRight(33, 'a')),
        'Password maksimal 32 karakter.',
      );
      expect(AuthValidators.registerPassword('a'.padRight(32, 'a')), isNull);
    });

    test('rejects names that contain no valid name characters', () {
      expect(AuthValidators.name('12345'), 'Masukkan nama yang valid.');
      expect(AuthValidators.name('---'), 'Masukkan nama yang valid.');
      expect(AuthValidators.name('Krisna Pratama'), isNull);
    });
  });
}
