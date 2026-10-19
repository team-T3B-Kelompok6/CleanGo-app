import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/storage/token_storage.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController(this.tokenStorage);

  final TokenStorage tokenStorage;

  Future<bool> hasSession() async {
    final token = await tokenStorage.readAccessToken();
    final expiresAt = await tokenStorage.readExpiresAt();
    final isValid =
        token != null &&
        token.isNotEmpty &&
        expiresAt != null &&
        expiresAt.isAfter(DateTime.now().toUtc());
    if (!isValid) {
      await tokenStorage.clearSession();
    }
    return isValid;
  }

  Future<void> createLocalSession() async {
    final random = Random.secure();
    String generateToken() =>
        base64UrlEncode(List<int>.generate(32, (_) => random.nextInt(256)))
            .replaceAll('=', '');

    await saveSession(
      accessToken: generateToken(),
      refreshToken: generateToken(),
      expiresAt: DateTime.now().toUtc().add(const Duration(days: 1)),
    );
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await tokenStorage.writeAccessToken(accessToken);
    await tokenStorage.writeRefreshToken(refreshToken);
    await tokenStorage.writeExpiresAt(expiresAt);
  }

  Future<void> createSession(String token) {
    return tokenStorage.writeAccessToken(token);
  }

  Future<void> signOut() {
    return tokenStorage.clearSession();
  }
}
