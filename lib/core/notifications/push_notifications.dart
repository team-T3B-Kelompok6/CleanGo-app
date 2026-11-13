import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../network/api_client.dart';
import '../network/api_config.dart';
import '../storage/token_storage.dart';

abstract class PushTransport {
  Future<String?> getToken();
  StreamSubscription<String> listenTokenRefresh(
    void Function(String token) onNewToken,
  );
  Future<NotificationSettings> requestPermission();
  Future<NotificationSettings> getNotificationSettings();
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Future<RemoteMessage?> getInitialMessage();
  Future<void> deleteToken();
  void dispose();
}

// ponytail: HTTP v1 backend sends legacy registration tokens, not installation
// IDs. Migrate transport and server target together before using register().
class FcmTransport implements PushTransport {
  @override
  // ignore: deprecated_member_use
  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  @override
  StreamSubscription<String> listenTokenRefresh(
    void Function(String token) onNewToken,
  ) =>
      // ignore: deprecated_member_use
      FirebaseMessaging.instance.onTokenRefresh.listen(
        onNewToken,
        onError: (Object _) {},
      );

  @override
  Future<NotificationSettings> requestPermission() =>
      FirebaseMessaging.instance.requestPermission();

  @override
  Future<NotificationSettings> getNotificationSettings() =>
      FirebaseMessaging.instance.getNotificationSettings();

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() =>
      FirebaseMessaging.instance.getInitialMessage();

  @override
  // ignore: deprecated_member_use
  Future<void> deleteToken() => FirebaseMessaging.instance.deleteToken();

  @override
  void dispose() {}
}

// Notification payloads are displayed by Android. No Firebase services or UI
// used here; Firebase must not be initialized again.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotifications {
  PushNotifications({
    required this.transport,
    required this.client,
    required this.httpClient,
    required this.tokenStorage,
    this.onInboxRefresh,
    this.onForegroundMessage,
    ValueChanged<RemoteMessage>? onNotificationTap,
    // Public callback name retained for callers attaching after startup.
    // ignore: prefer_initializing_formals
  }) : _onNotificationTap = onNotificationTap;

  final PushTransport transport;
  final ApiClient client;
  final http.Client httpClient;
  final TokenStorage tokenStorage;
  VoidCallback? onInboxRefresh;
  ValueChanged<RemoteMessage>? onForegroundMessage;
  ValueChanged<RemoteMessage>? _onNotificationTap;
  RemoteMessage? _pendingNotificationTap;
  final Set<String> _seenMessages = {};
  static const _channel = MethodChannel('com.cleango.app/push');

  set onNotificationTap(ValueChanged<RemoteMessage>? callback) {
    _onNotificationTap = callback;
    final pending = _pendingNotificationTap;
    if (callback != null && pending != null) {
      _pendingNotificationTap = null;
      callback(pending);
    }
  }

  void _tap(RemoteMessage message) {
    final callback = _onNotificationTap;
    if (callback == null) {
      _pendingNotificationTap = message;
    } else {
      callback(message);
    }
  }

  bool _disposed = false;
  bool _initialized = false;
  int _revision = 0;
  String? _currentToken;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  Future<void> _last = Future<void>.value();

  Future<void> _serial(Future<void> Function() run) {
    final pending = _last.then((_) => run());
    // Optional push work must never surface an unhandled async error.
    _last = pending.catchError((Object _) {});
    return _last;
  }

  /// Caller initializes Firebase once, on supported native platforms only.
  Future<void> initialize() async {
    if (_disposed || _initialized || kIsWeb) return;
    _initialized = true;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'tap' && call.arguments is Map) {
          await _handleMessage(RemoteMessage(data: Map<String, dynamic>.from(call.arguments as Map)), opened: true);
        }
      });
      try {
        final data = await _channel.invokeMapMethod<String, dynamic>('initialTap');
        if (data != null) await _handleMessage(RemoteMessage(data: data), opened: true);
      } catch (_) {}
    }
    if (transport is FcmTransport) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
    _messageSubscription = transport.onMessage.listen((message) {
      unawaited(_handleMessage(message, opened: false));
    }, onError: (Object _) {});
    _openedSubscription = transport.onMessageOpenedApp.listen((message) {
      unawaited(_handleMessage(message, opened: true));
    }, onError: (Object _) {});
    try {
      final message = await transport.getInitialMessage().timeout(
        const Duration(seconds: 8),
      );
      if (message != null) await _handleMessage(message, opened: true);
    } catch (_) {}
  }

  Future<void> _handleMessage(
    RemoteMessage message, {
    required bool opened,
  }) async {
    try {
      final jwt = await tokenStorage.readAccessToken();
      if (_disposed || jwt == null || jwt.isEmpty) return;
      onInboxRefresh?.call();
      if (opened) {
        _tap(message);
      } else {
        final id = message.messageId ?? message.data['notificationId']?.toString();
        if (id != null && id.isNotEmpty && !_seenMessages.add(id)) return;
        if (_seenMessages.length > 200) _seenMessages.clear();
        onForegroundMessage?.call(message);
        if (!kIsWeb &&
            defaultTargetPlatform == TargetPlatform.android &&
            message.notification != null) {
          await _channel.invokeMethod<void>('show', {
            'title': message.notification!.title ?? 'CleanGo',
            'body': message.notification!.body ?? '',
            'data': message.data,
          });
        }
      }
    } catch (_) {}
  }

  Future<void> ensurePermission() async {
    if (_disposed || kIsWeb) return;
    try {
      final jwt = await tokenStorage.readAccessToken();
      if (jwt == null || jwt.isEmpty) return;
      await transport.requestPermission().timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  /// Permission precedes token retrieval; unavailable Firebase never blocks auth.
  Future<void> registerCurrentDevice() async {
    final revision = _revision;
    try {
      if (_disposed || kIsWeb) return;
      final jwt = await tokenStorage.readAccessToken();
      if (jwt == null || jwt.isEmpty) return;
      await ensurePermission();
      final settings = await transport.getNotificationSettings().timeout(
        const Duration(seconds: 8),
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        return;
      }
      final token = await transport.getToken().timeout(
        const Duration(seconds: 8),
      );
      if (token == null ||
          token.isEmpty ||
          revision != _revision ||
          await tokenStorage.readAccessToken() != jwt) {
        return;
      }
      await registerDevice(token);
    } catch (_) {}
  }

  Future<void> registerDevice(String token) async {
    final revision = _revision;
    try {
      if (_disposed || kIsWeb || token.isEmpty) return;
      final jwt = await tokenStorage.readAccessToken();
      if (jwt == null || jwt.isEmpty) return;
      await _serial(() async {
        if (_disposed ||
            revision != _revision ||
            await tokenStorage.readAccessToken() != jwt) {
          return;
        }
        final settings = await transport.getNotificationSettings().timeout(
          const Duration(seconds: 8),
        );
        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          return;
        }
        if (_disposed ||
            revision != _revision ||
            await tokenStorage.readAccessToken() != jwt) {
          return;
        }
        _currentToken = token;
        await client.post(
          '${ApiConfig.customerNotifications}/devices',
          body: {'token': token, 'platform': 'android'},
          token: jwt,
          timeout: const Duration(seconds: 8),
        );
      });
    } catch (_) {}
  }

  Future<void> unregisterDevice(String token) async {
    try {
      final jwt = await tokenStorage.readAccessToken();
      if (_disposed || kIsWeb || jwt == null || jwt.isEmpty) return;
      await _serial(() async {
        final uri = Uri.parse(
          '${ApiConfig.normalizeBaseUrl(ApiConfig.baseUrl)}${ApiConfig.customerNotifications}/devices',
        );
        final request = http.Request('DELETE', uri)
          ..headers.addAll({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $jwt',
          })
          ..body = jsonEncode({'token': token});
        final response = await httpClient
            .send(request)
            .timeout(const Duration(seconds: 8));
        await response.stream.drain<void>().timeout(const Duration(seconds: 8));
        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            _currentToken == token) {
          _currentToken = null;
        }
      });
    } catch (_) {}
  }

  Future<void> unregisterCurrentDevice() async {
    stopTokenSync();
    String? token = _currentToken;
    try {
      token ??= await transport.getToken().timeout(const Duration(seconds: 8));
    } catch (_) {}
    if (token != null && token.isNotEmpty) await unregisterDevice(token);
    try {
      // Also rotate locally when backend is offline, reducing stale delivery risk.
      await transport.deleteToken().timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  void startTokenSync() {
    if (_disposed || kIsWeb || _tokenSubscription != null) return;
    _tokenSubscription = transport.listenTokenRefresh((token) {
      unawaited(registerDevice(token));
    });
  }

  void stopTokenSync() {
    _revision++;
    unawaited(_tokenSubscription?.cancel());
    _tokenSubscription = null;
  }

  Future<void> dispose() async {
    _disposed = true;
    stopTokenSync();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
    transport.dispose();
    client.close();
    httpClient.close();
  }
}
