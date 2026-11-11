import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/storage/token_storage.dart';

/// Transport abstraksi FCM agar dapat ditiru dalam tes tanpa menyentuh Firebase.
abstract class PushTransport {
  Future<String?> getToken();
  StreamSubscription<String> listenTokenRefresh(void Function(String token) onNewToken);
  Future<NotificationSettings> requestPermission();
  Future<NotificationSettings> getNotificationSettings();
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Future<RemoteMessage?> getInitialMessage();
  Future<void> deleteToken();
  void dispose();
}

/// Implementasi nyata Firebase Cloud Messaging.
class FcmTransport implements PushTransport {
  FcmTransport();

  @override
  Future<String?> getToken() async => FirebaseMessaging.instance.getToken();

  @override
  StreamSubscription<String> listenTokenRefresh(void Function(String token) onNewToken) =>
      FirebaseMessaging.instance.onTokenRefresh.listen(onNewToken);

  @override
  Future<NotificationSettings> requestPermission() async =>
      FirebaseMessaging.instance.requestPermission();

  @override
  Future<NotificationSettings> getNotificationSettings() async =>
      FirebaseMessaging.instance.getNotificationSettings();

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() async => FirebaseMessaging.instance.getInitialMessage();

  @override
  Future<void> deleteToken() async => FirebaseMessaging.instance.deleteToken();

  @override
  void dispose() {}
}

/// Handler latar belakang top-level: Firebase.initializeApp saja, tanpa UI
/// atau tandai baca; OS menampilkan notifikasi payload.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Diagnosa tanpa kunci atau token.
  }
}

class PushNotifications {
  PushNotifications({
    required this.transport,
    required this.client,
    required this.httpClient,
    required this.tokenStorage,
    this.onInboxRefresh,
  });

  final PushTransport transport;
  final ApiClient client;
  final http.Client httpClient;
  final TokenStorage tokenStorage;

  VoidCallback? onInboxRefresh;

  bool _disposed = false;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  Future<void> _last = Future<void>.value();
  int _revision = 0;
  String? _registeredJwt;

  Future<T> _serial<T>(Future<T> Function() run) async {
    final entry = Completer<T>();
    final previous = _last;
    _last = entry.future;
    previous.then(
      (_) => run().then(entry.complete, onError: entry.completeError),
      onError: (_) => run().then(entry.complete, onError: entry.completeError),
    );
    return entry.future;
  }

  /// Menyiapkan handler latar belakang dan listener pesan. Firebase harus
  /// sudah diinisialisasi oleh pemanggil (main.dart) sebelum ini dipanggil.
  Future<void> initialize() async {
    if (_disposed) return;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _messageSubscription = transport.onMessage.listen((_) {
      if (_disposed) return;
      onInboxRefresh?.call();
    });
    _openedSubscription = transport.onMessageOpenedApp.listen((_) {
      if (_disposed) return;
      onInboxRefresh?.call();
    });
    unawaited(transport.getInitialMessage().then((_) {
      if (_disposed) return;
      onInboxRefresh?.call();
    }));
  }

  /// Izin notifikasi Android 13 hanya ketika pengguna sudah punya sesi, bukan
  /// saat startup tanpa login.
  Future<void> ensurePermission() async {
    if (_disposed) return;
    final token = await tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) return;
    try {
      await transport.requestPermission();
    } catch (_) {
      // Izin ditolak/diabaikan tidak memblokir aplikasi.
    }
  }

  /// Sinkronkan token FCM ke backend setelah JWT tersedia.
  Future<void> registerDevice(String token) async {
    await _serial(() => _doRegister(token));
  }

  Future<void> _doRegister(String token) async {
    if (_disposed) return;
    final revision = ++_revision;
    final jwt = await tokenStorage.readAccessToken();
    if (jwt == null || jwt.isEmpty) return;
    try {
      await client.post(
        '${ApiConfig.customerNotifications}/devices',
        body: {'token': token, 'platform': 'android'},
        token: jwt,
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Cloud/izin gagal tidak menggagalkan sesi.
      return;
    }
    if (_disposed || revision != _revision) return;
    final now = await tokenStorage.readAccessToken();
    if (now == null || now != jwt) return;
    _registeredJwt = jwt;
  }

  /// Hapus perangkat dari backend. DELETE dengan body {token}; tidak melepaskan
  /// token yang baru pindah akun.
  Future<void> unregisterDevice(String token) async {
    await _serial(() => _doUnregister(token));
  }

  Future<void> _doUnregister(String token) async {
    if (_disposed) return;
    final revision = ++_revision;
    final jwt = await tokenStorage.readAccessToken();
    if (jwt == null || jwt.isEmpty) return;
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.customerNotifications}/devices');
    try {
      final request = http.Request('DELETE', uri)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $jwt',
        })
        ..body = jsonEncode({'token': token});
      await httpClient.send(request).timeout(const Duration(seconds: 8));
    } catch (_) {
      return;
    }
    if (_disposed || revision != _revision) return;
    final now = await tokenStorage.readAccessToken();
    if (now == null || now != jwt) return;
    if (_registeredJwt == jwt) _registeredJwt = null;
  }

  /// Mulai satu subscription sinkronisasi token saat refresh. Dapat dibatalkan
  /// lewat [stopTokenSync] atau [dispose].
  void startTokenSync() {
    if (_disposed) return;
    stopTokenSync();
    _tokenSubscription = transport.listenTokenRefresh((token) {
      if (_disposed) return;
      unawaited(registerDevice(token));
    });
  }

  void stopTokenSync() {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
  }

  Future<void> dispose() async {
    _disposed = true;
    stopTokenSync();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
    _messageSubscription = null;
    _openedSubscription = null;
    httpClient.close();
  }
}
