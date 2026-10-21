import 'dart:convert';

import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/auth/controllers/auth_session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryTokenStorage implements TokenStorage {
  String? _access;
  String? _refresh;
  DateTime? _expiresAt;

  @override
  Future<void> writeAccessToken(String token) async => _access = token;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<void> writeRefreshToken(String token) async => _refresh = token;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> writeExpiresAt(DateTime expiresAt) async => _expiresAt = expiresAt;

  @override
  Future<DateTime?> readExpiresAt() async => _expiresAt;

  @override
  Future<void> clearSession() async {
    _access = null;
    _refresh = null;
    _expiresAt = null;
  }
}

/// Builds a JWT shaped token with the given `exp` (seconds since epoch).
String _tokenWithExpiry(int secondsFromNow) {
  final exp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 + secondsFromNow;
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}')).replaceAll('=', '');
  final payload = base64Url.encode(utf8.encode('{"id":1,"exp":$exp}')).replaceAll('=', '');
  return '$header.$payload.signature';
}


class _BrokenTokenStorage implements TokenStorage {
  @override
  Future<void> writeAccessToken(String token) async {}

  @override
  Future<String?> readAccessToken() async => throw StateError('storage rusak');

  @override
  Future<void> writeRefreshToken(String token) async {}

  @override
  Future<String?> readRefreshToken() async => throw StateError('storage rusak');

  @override
  Future<void> writeExpiresAt(DateTime expiresAt) async {}

  @override
  Future<DateTime?> readExpiresAt() async => throw StateError('storage rusak');

  @override
  Future<void> clearSession() async {}
}

void main() {
  group('AuthSessionController persistence', () {
    test('keeps the session after createSession (app restart)', () async {
      final storage = _MemoryTokenStorage();
      final controller = AuthSessionController(storage);

      await controller.createSession('token', expiresInSeconds: 3600);

      // A fresh controller simulates the next app launch reading storage.
      final afterRestart = AuthSessionController(storage);
      expect(await afterRestart.hasSession(), isTrue);
      expect(await storage.readAccessToken(), 'token');
      expect(await storage.readExpiresAt(), isNotNull);
    });

    test('reads the expiry from the JWT when expiresIn is missing', () async {
      final storage = _MemoryTokenStorage();
      final controller = AuthSessionController(storage);

      await controller.createSession(_tokenWithExpiry(3600));

      expect(await AuthSessionController(storage).hasSession(), isTrue);
    });

    test('drops a session whose token is already expired', () async {
      final storage = _MemoryTokenStorage();
      final controller = AuthSessionController(storage);

      await controller.createSession(_tokenWithExpiry(-60));

      expect(await controller.hasSession(), isFalse);
      expect(await storage.readAccessToken(), isNull);
    });

    test('falls back to seven days for an opaque token', () async {
      final storage = _MemoryTokenStorage();
      final controller = AuthSessionController(storage);

      await controller.createSession('opaque-session-token');

      final expiresAt = await storage.readExpiresAt();
      expect(expiresAt, isNotNull);
      final days = expiresAt!.difference(DateTime.now().toUtc()).inDays;
      expect(days, inInclusiveRange(6, 7));
    });

    test('never throws when the secure store is unreadable', () async {
      // A broken secure store must not crash the splash screen.
      final controller = AuthSessionController(_BrokenTokenStorage());

      expect(await controller.hasSession(), isFalse);
    });

    test('clears everything on sign out', () async {
      final storage = _MemoryTokenStorage();
      final controller = AuthSessionController(storage);
      await controller.createSession('token', expiresInSeconds: 3600);

      await controller.signOut();

      expect(await controller.hasSession(), isFalse);
      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readExpiresAt(), isNull);
    });
  });
}
