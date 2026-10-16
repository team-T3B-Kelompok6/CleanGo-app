import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/auth/controllers/auth_session_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('menulis, membaca, dan menghapus sesi dengan aman', () async {
    final storage = SecureTokenStorage();
    final expiresAt = DateTime.utc(2030, 1, 1);

    await storage.writeAccessToken('token-rahasia');
    await storage.writeRefreshToken('refresh-rahasia');
    await storage.writeExpiresAt(expiresAt);
    expect(await storage.readAccessToken(), 'token-rahasia');
    expect(await storage.readRefreshToken(), 'refresh-rahasia');
    expect(await storage.readExpiresAt(), expiresAt);

    await storage.clearSession();
    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
    expect(await storage.readExpiresAt(), isNull);
  });

  test('sesi kedaluwarsa ditolak dan dibersihkan', () async {
    final storage = SecureTokenStorage();
    final controller = AuthSessionController(storage);
    await controller.saveSession(
      accessToken: 'expired-token',
      refreshToken: 'expired-refresh',
      expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
    );

    expect(await controller.hasSession(), isFalse);
    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
  });
}
