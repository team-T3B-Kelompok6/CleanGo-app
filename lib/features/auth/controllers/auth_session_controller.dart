import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/notifications/push_notifications.dart';
import '../../../core/storage/token_storage.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController(this._tokenStorage, {this.pushNotifications});

  final TokenStorage _tokenStorage;
  final PushNotifications? pushNotifications;

  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    pushNotifications?.startTokenSync();
    unawaited(pushNotifications?.registerCurrentDevice());
  }

  void stop() {
    _started = false;
    pushNotifications?.stopTokenSync();
  }

  Future<bool> hasSession() async {
    try {
      final token = await _tokenStorage.readAccessToken();
      final expiresAt = await _tokenStorage.readExpiresAt();
      final isValid =
          token != null &&
          token.isNotEmpty &&
          expiresAt != null &&
          expiresAt.isAfter(DateTime.now().toUtc());
      if (!isValid) {
        stop();
        await _tokenStorage.clearSession();
      } else {
        start();
      }
      return isValid;
    } catch (_) {
      // A broken/unreadable secure store must not block the app; treat it as a
      // missing session so the user can sign in again.
      try {
        await _tokenStorage.clearSession();
      } catch (_) {}
      return false;
    }
  }

  /// Persists the session so the customer stays signed in after the app is
  /// closed. Without a stored expiry [hasSession] would always be false.
  Future<void> createSession(String token, {int? expiresInSeconds}) async {
    await _tokenStorage.writeAccessToken(token);
    final seconds =
        expiresInSeconds ?? _secondsUntilExpiry(token) ?? _fallbackSeconds;
    await _tokenStorage.writeExpiresAt(
      DateTime.now().toUtc().add(Duration(seconds: seconds)),
    );
    await _linkFcmToken();
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
      return exp.toInt() -
          DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
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
    await _linkFcmToken();
  }

  /// Menautkan token FCM ke backend hanya saat JWT ada dan sesi valid. Error
  /// cloud/izin tidak menggagalkan sesi.
  Future<void> _linkFcmToken() async {
    try {
      stop();
      await hasSession();
    } catch (_) {
      // Gagal menyambungkan token FCM tidak membatalkan sesi.
    }
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

  Future<void> signOut() async {
    stop();
    try {
      // Keep JWT available until ownership-scoped unregister finishes.
      await pushNotifications?.unregisterCurrentDevice();
    } finally {
      await _tokenStorage.clearSession();
    }
  }
}
