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

  Future<void> createSession(String token) {
    return _tokenStorage.writeAccessToken(token);
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
