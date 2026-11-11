import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
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
  Future<void> writeExpiresAt(DateTime expiresAt) async => this.expiresAt = expiresAt;

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
  FakeTransport({this.token, this.permissionStatus = AuthorizationStatus.authorized});
  String? token;
  final AuthorizationStatus permissionStatus;
  bool permissionRequested = false;
  final _refreshController = StreamController<String>();
  StreamSubscription<String>? _refreshSubscription;
  final List<String> deleted = <String>[];

  @override
  Future<String?> getToken() async => token;

  @override
  StreamSubscription<String> listenTokenRefresh(void Function(String token) onNewToken) {
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
  Stream<RemoteMessage> get onMessage => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  Future<void> deleteToken() async {
    deleted.add(token ?? '');
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    _refreshController.close();
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
  group('PushNotifications', () {
    test('tidak meminta izin saat belum ada sesi (bukan startup tanpa login)', () async {
      final storage = FakeTokenStorage();
      final transport = FakeTransport();
      final push = _buildPush(storage: storage, transport: transport);

      await push.ensurePermission();

      expect(transport.permissionRequested, isFalse);
      expect(storage.reads, [null]);
    });

    test('izin ditolak tidak memicu error saat ada sesi', () async {
      final storage = FakeTokenStorage(accessToken: 'jwt');
      final transport = FakeTransport(permissionStatus: AuthorizationStatus.denied);
      final push = _buildPush(storage: storage, transport: transport);

      await push.ensurePermission();

      expect(transport.permissionRequested, isTrue);
    });

    test('refresh token sinkronkan ke backend', () async {
      final storage = FakeTokenStorage(accessToken: 'jwt');
      final transport = FakeTransport(token: 'fcm-token');
      final api = FakeApiClient();
      final push = _buildPush(
        storage: storage,
        transport: transport,
        api: api,
      );
      push.startTokenSync();

      transport.simulateRefresh('fcm-token');

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(api.posts.length, 1);
      expect(api.posts.first.path, '${ApiConfig.customerNotifications}/devices');
      expect(api.posts.first.body, <String, dynamic>{'token': 'fcm-token', 'platform': 'android'});
      expect(api.posts.first.token, 'jwt');
    });

    test('registrasi batal saat JWT berganti di tengah operasi (stale)', () async {
      final storage = FakeTokenStorage(
        accessToken: 'jwt-old',
        accessTokenSequence: const <String?>['jwt-old', 'jwt-new'],
      );
      final transport = FakeTransport(token: 'fcm-token');
      final api = FakeApiClient();
      final push = _buildPush(storage: storage, transport: transport, api: api);

      // Kirim dengan JWT lama, verifikasi dengan JWT baru -> stale, tidak dihitung terdaftar.
      await push.registerDevice('fcm-token');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(api.posts.length, 1);
      expect(api.posts.first.token, 'jwt-old');

      // Sesi valid dengan JWT baru tetap dapat mendaftarkan ulang secara eksplisit.
      storage.accessToken = 'jwt-new';
      await push.registerDevice('fcm-token');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(api.posts.length, 2);
      expect(api.posts.last.token, 'jwt-new');
    });

    test('logout unregister sebelum clear JWT dan deleteToken', () async {
      final storage = FakeTokenStorage(accessToken: 'jwt');
      final transport = FakeTransport(token: 'fcm-token');
      final httpClient = FakeHttpClient();
      final push = _buildPush(storage: storage, transport: transport, httpClient: httpClient);
      final controller = AuthSessionController(storage, pushNotifications: push);

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
