import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:cleango_app/core/notifications/push_notifications.dart';
import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/network/api_config.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/auth/controllers/auth_session_controller.dart';

class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage({this.accessToken, this.accessTokenSequence = const []});
  String? accessToken;
  final List<String?> accessTokenSequence;
  int _seqIndex = 0;
  String? refreshToken;
  DateTime? expiresAt;
  bool cleared = false;
  final List<String?> reads = <String?>[];

  @override
  Future<void> writeAccessToken(String token) async => accessToken = token;

  @override
  Future<String?> readAccessToken() async {
    reads.add(accessToken);
    if (_seqIndex < accessTokenSequence.length) {
      return accessTokenSequence[_seqIndex++];
    }
    return accessToken;
  }

  @override
  Future<void> writeRefreshToken(String token) async => refreshToken = token;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> writeExpiresAt(DateTime expiresAt) async =>
      this.expiresAt = expiresAt;

  @override
  Future<DateTime?> readExpiresAt() async => expiresAt;

  @override
  Future<void> clearSession() async {
    cleared = true;
    accessToken = null;
    refreshToken = null;
    expiresAt = null;
  }
}

class FakeTransport implements PushTransport {
  FakeTransport({
    this.token,
    this.permissionStatus = AuthorizationStatus.authorized,
  });
  String? token;
  final AuthorizationStatus permissionStatus;
  bool permissionRequested = false;
  final _refreshController = StreamController<String>();
  StreamSubscription<String>? _refreshSubscription;
  final List<String> deleted = <String>[];
  final messages = StreamController<RemoteMessage>();
  final opened = StreamController<RemoteMessage>();
  RemoteMessage? initial;
  bool failGetToken = false;

  @override
  Future<String?> getToken() async {
    if (failGetToken) throw StateError('FCM unavailable');
    return token;
  }

  @override
  StreamSubscription<String> listenTokenRefresh(
    void Function(String token) onNewToken,
  ) {
    _refreshSubscription = _refreshController.stream.listen(onNewToken);
    return _refreshSubscription!;
  }

  void simulateRefresh(String token) => _refreshController.add(token);

  @override
  Future<NotificationSettings> requestPermission() async {
    permissionRequested = true;
    return FakeNotificationSettings(authorizationStatus: permissionStatus);
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async =>
      FakeNotificationSettings(authorizationStatus: permissionStatus);

  @override
  Stream<RemoteMessage> get onMessage => messages.stream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => opened.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => initial;

  @override
  Future<void> deleteToken() async {
    deleted.add(token ?? '');
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    _refreshController.close();
    messages.close();
    opened.close();
  }
}

class FakeNotificationSettings extends Fake implements NotificationSettings {
  FakeNotificationSettings({required this.authorizationStatus});

  @override
  final AuthorizationStatus authorizationStatus;
}

class FakeApiClient extends ApiClient {
  FakeApiClient() : super(client: http.Client());
  final List<({String path, Map<String, dynamic>? body, String? token})> posts =
      <({String path, Map<String, dynamic>? body, String? token})>[];

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    posts.add((path: path, body: body, token: token));
    return <String, dynamic>{'ok': true};
  }
}

class FakeHttpClient extends http.BaseClient {
  FakeHttpClient() : sent = <http.Request>[];
  final List<http.Request> sent;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sent.add(request as http.Request);
    return http.StreamedResponse(http.ByteStream(Stream.empty()), 200);
  }
}

PushNotifications _buildPush({
  FakeTokenStorage? storage,
  FakeTransport? transport,
  FakeApiClient? api,
  FakeHttpClient? httpClient,
}) {
  storage ??= FakeTokenStorage();
  transport ??= FakeTransport();
  api ??= FakeApiClient();
  return PushNotifications(
    transport: transport,
    client: api,
    httpClient: httpClient ?? FakeHttpClient(),
    tokenStorage: storage,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pushChannel = MethodChannel('com.cleango.app/push');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pushChannel, (call) async => null);
  group('PushNotifications', () {
    test(
      'restored session registers current token once and logout stops refresh',
      () async {
        final storage = FakeTokenStorage(accessToken: 'jwt')
          ..expiresAt = DateTime.now().toUtc().add(const Duration(hours: 1));
        final transport = FakeTransport(token: 'fcm-token');
        final api = FakeApiClient();
        final push = _buildPush(
          storage: storage,
          transport: transport,
          api: api,
        );
        final auth = AuthSessionController(storage, pushNotifications: push);
        expect(await auth.hasSession(), isTrue);
        expect(await auth.hasSession(), isTrue);
        await Future<void>.delayed(Duration.zero);
        expect(transport.permissionRequested, isTrue);
        expect(api.posts.length, 1);
        await auth.signOut();
        transport.simulateRefresh('new-token');
        await Future<void>.delayed(Duration.zero);
        expect(api.posts.length, 1);
        await push.dispose();
      },
    );
    test(
      'foreground updates inbox, in-app feedback and native OS alert',
      () async {
        final calls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(pushChannel, (call) async {
              calls.add(call);
              return null;
            });
        final transport = FakeTransport();
        final push = _buildPush(
          storage: FakeTokenStorage(accessToken: 'jwt'),
          transport: transport,
        );
        var refreshed = 0;
        var shown = 0;
        push.onInboxRefresh = () => refreshed++;
        push.onForegroundMessage = (_) => shown++;
        await push.initialize();
        await push.initialize();
        transport.messages.add(
          const RemoteMessage(
            notification: RemoteNotification(
              title: 'CleanGo',
              body: 'Pesanan baru',
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(refreshed, 1);
        expect(shown, 1);
        final shownCall = calls.singleWhere((call) => call.method == 'show');
        expect(shownCall.arguments, {
          'title': 'CleanGo',
          'body': 'Pesanan baru',
          'data': <String, dynamic>{},
        });
        await push.dispose();
      },
    );

    test('cold tap survives initialize before app attaches callback', () async {
      final transport = FakeTransport()
        ..initial = const RemoteMessage(data: {'type': 'payment', 'bookingId': '19', 'notificationId': '25'});
      final push = _buildPush(storage: FakeTokenStorage(accessToken: 'jwt'), transport: transport);
      await push.initialize();
      RemoteMessage? tapped;
      push.onNotificationTap = (message) => tapped = message;
      expect(tapped?.data['bookingId'], '19');
      expect(tapped?.data['notificationId'], '25');
      await push.dispose();
    });

    test('duplicate foreground FCM message produces one alert', () async {
      final transport = FakeTransport();
      final push = _buildPush(storage: FakeTokenStorage(accessToken: 'jwt'), transport: transport);
      var shown = 0;
      push.onForegroundMessage = (_) => shown++;
      await push.initialize();
      const message = RemoteMessage(messageId: 'fcm-19', data: {'type': 'payment', 'bookingId': '19'});
      transport.messages.add(message);
      transport.messages.add(message);
      await Future<void>.delayed(Duration.zero);
      expect(shown, 1);
      await push.dispose();
    });

    test('tap refreshes inbox without duplicating foreground alert', () async {
      final transport = FakeTransport();
      final push = _buildPush(
        storage: FakeTokenStorage(accessToken: 'jwt'),
        transport: transport,
      );
      var tapped = 0;
      var shown = 0;
      push.onNotificationTap = (_) => tapped++;
      push.onForegroundMessage = (_) => shown++;
      await push.initialize();
      transport.opened.add(const RemoteMessage());
      await Future<void>.delayed(Duration.zero);
      expect(tapped, 1);
      expect(shown, 0);
      await push.dispose();
    });

    test('signed out messages produce no UI or native alert', () async {
      final transport = FakeTransport();
      final push = _buildPush(transport: transport);
      var shown = 0;
      push.onForegroundMessage = (_) => shown++;
      push.onNotificationTap = (_) => shown++;
      await push.initialize();
      transport.messages.add(const RemoteMessage());
      transport.opened.add(const RemoteMessage());
      await Future<void>.delayed(Duration.zero);
      expect(shown, 0);
      await push.dispose();
    });

    test('permission denied skips token registration', () async {
      final api = FakeApiClient();
      final push = _buildPush(
        storage: FakeTokenStorage(accessToken: 'jwt'),
        api: api,
        transport: FakeTransport(
          token: 'fcm-token',
          permissionStatus: AuthorizationStatus.denied,
        ),
      );
      await push.registerCurrentDevice();
      expect(api.posts, isEmpty);
      await push.dispose();
    });

    test('Firebase unavailable never breaks auth or logout', () async {
      final transport = FakeTransport()..failGetToken = true;
      final storage = FakeTokenStorage();
      final push = _buildPush(storage: storage, transport: transport);
      final auth = AuthSessionController(storage, pushNotifications: push);
      await auth.createSession('jwt');
      await Future<void>.delayed(Duration.zero);
      expect(storage.accessToken, 'jwt');
      await auth.signOut();
      expect(storage.cleared, isTrue);
      await push.dispose();
    });
    test(
      'tidak meminta izin saat belum ada sesi (bukan startup tanpa login)',
      () async {
        final storage = FakeTokenStorage();
        final transport = FakeTransport();
        final push = _buildPush(storage: storage, transport: transport);

        await push.ensurePermission();

        expect(transport.permissionRequested, isFalse);
        expect(storage.reads, [null]);
      },
    );

    test('izin ditolak tidak memicu error saat ada sesi', () async {
      final storage = FakeTokenStorage(accessToken: 'jwt');
      final transport = FakeTransport(
        permissionStatus: AuthorizationStatus.denied,
      );
      final push = _buildPush(storage: storage, transport: transport);

      await push.ensurePermission();

      expect(transport.permissionRequested, isTrue);
    });

    test('refresh token sinkronkan ke backend', () async {
      final storage = FakeTokenStorage(accessToken: 'jwt');
      final transport = FakeTransport(token: 'fcm-token');
      final api = FakeApiClient();
      final push = _buildPush(storage: storage, transport: transport, api: api);
      push.startTokenSync();

      transport.simulateRefresh('fcm-token');

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(api.posts.length, 1);
      expect(
        api.posts.first.path,
        '${ApiConfig.customerNotifications}/devices',
      );
      expect(api.posts.first.body, <String, dynamic>{
        'token': 'fcm-token',
        'platform': 'android',
      });
      expect(api.posts.first.token, 'jwt');
    });

    test(
      'registrasi batal saat JWT berganti di tengah operasi (stale)',
      () async {
        final storage = FakeTokenStorage(
          accessToken: 'jwt-old',
          accessTokenSequence: const <String?>['jwt-old', 'jwt-new'],
        );
        final transport = FakeTransport(token: 'fcm-token');
        final api = FakeApiClient();
        final push = _buildPush(
          storage: storage,
          transport: transport,
          api: api,
        );

        // JWT replacement before request must prevent old-owner registration.
        await push.registerDevice('fcm-token');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(api.posts, isEmpty);

        storage.accessToken = 'jwt-new';
        await push.registerDevice('fcm-token');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(api.posts.length, 1);
        expect(api.posts.single.token, 'jwt-new');
      },
    );

    test('logout unregister sebelum clear JWT dan deleteToken', () async {
      final storage = FakeTokenStorage(accessToken: 'jwt');
      final transport = FakeTransport(token: 'fcm-token');
      final httpClient = FakeHttpClient();
      final push = _buildPush(
        storage: storage,
        transport: transport,
        httpClient: httpClient,
      );
      final controller = AuthSessionController(
        storage,
        pushNotifications: push,
      );

      await controller.signOut();

      expect(transport.deleted, contains('fcm-token'));
      expect(storage.cleared, isTrue);
      expect(storage.accessToken, isNull);
      // Unregister menggunakan JWT sebelum clear: permintaan hapus dikirim dengan bearer JWT.
      expect(
        httpClient.sent.any((r) => r.headers['authorization'] == 'Bearer jwt'),
        isTrue,
      );
    });
  });
}
