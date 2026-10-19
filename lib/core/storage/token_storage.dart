import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const booChatHistoryStorageKey = 'cleango_boo_history_v1';

abstract interface class TokenStorage {
  Future<void> writeAccessToken(String token);

  Future<String?> readAccessToken();

  Future<void> writeRefreshToken(String token);

  Future<String?> readRefreshToken();

  Future<void> writeExpiresAt(DateTime expiresAt);

  Future<DateTime?> readExpiresAt();

  Future<void> clearSession();
}

final class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'cleango_access_token';
  static const _refreshTokenKey = 'cleango_refresh_token';
  static const _expiresAtKey = 'cleango_token_expires_at';

  final FlutterSecureStorage _storage;

  @override
  Future<void> writeAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> writeRefreshToken(String token) {
    return _storage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> writeExpiresAt(DateTime expiresAt) {
    return _storage.write(
      key: _expiresAtKey,
      value: expiresAt.toUtc().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<DateTime?> readExpiresAt() async {
    final raw = await _storage.read(key: _expiresAtKey);
    final milliseconds = int.tryParse(raw ?? '');
    return milliseconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresAtKey),
      _storage.delete(key: booChatHistoryStorageKey),
    ]);
  }
}
