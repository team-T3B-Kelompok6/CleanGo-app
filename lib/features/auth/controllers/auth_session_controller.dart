import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<bool> hasSession() async {
    final token = await _tokenStorage.readAccessToken();
    final expiresAt = await _tokenStorage.readExpiresAt();
    final isValid =
        token != null &&
        token.isNotEmpty &&
        expiresAt != null &&
        expiresAt.isAfter(DateTime.now().toUtc());
    if (!isValid) {
      await _tokenStorage.clearSession();
    }
    return isValid;
  }

  /// Persists the session so the customer stays signed in after the app is
  /// closed. Without a stored expiry [hasSession] would always be false.
  Future<void> createSession(String token, {int? expiresInSeconds}) async {
    await _tokenStorage.writeAccessToken(token);
    final seconds = expiresInSeconds ?? _secondsUntilExpiry(token) ?? _fallbackSeconds;
    await _tokenStorage.writeExpiresAt(
      DateTime.now().toUtc().add(Duration(seconds: seconds)),
    );
  }

  static const int _fallbackSeconds = 7 * 24 * 60 * 60;

  /// Reads the `exp` claim from the JWT when the API does not send `expiresIn`.
  static int? _secondsUntilExpiry(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is! Map) return null;
      final exp = payload['exp'];
      if (exp is! num) return null;
      // Keep a negative value so an already expired token is stored as expired.
      return exp.toInt() - DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await _tokenStorage.writeAccessToken(accessToken);
    await _tokenStorage.writeRefreshToken(refreshToken);
    await _tokenStorage.writeExpiresAt(expiresAt);
  }

  Future<void> createLocalSession() async {
    final random = Random.secure();
    final token = base64UrlEncode(
      List<int>.generate(32, (_) => random.nextInt(256)),
    ).replaceAll('=', '');
    await saveSession(
      accessToken: token,
      refreshToken: token,
      expiresAt: DateTime.now().toUtc().add(const Duration(days: 1)),
    );
  }

  Future<void> signOut() {
    return _tokenStorage.clearSession();
  }
}
