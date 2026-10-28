import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/network/api_config.dart';
import 'package:cleango_app/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient', () {
    test('returns a decoded JSON object for a successful response', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response('{"data":{"status":"ok"}}', 200),
        ),
        baseUrl: 'http://localhost:3001',
      );
      addTearDown(client.close);

      final response = await client.post('/health', body: const {});

      expect(response['data'], {'status': 'ok'});
    });

    test('posts raw image bytes with the requested content type', () async {
      late http.Request captured;
      final client = ApiClient(
        client: MockClient((request) async {
          captured = request;
          return http.Response('{"data":{"id":"1"}}', 201);
        }),
        baseUrl: 'http://localhost:3001',
      );
      addTearDown(client.close);

      final response = await client.postBytes(
        '/api/customer/profile/photo',
        bytes: const [1, 2, 3],
        contentType: 'image/png',
        token: 'token',
      );

      expect(response['data'], {'id': '1'});
      expect(captured.headers['Content-Type'], 'image/png');
      expect(captured.headers['Authorization'], 'Bearer token');
      expect(captured.bodyBytes, [1, 2, 3]);
    });

    test('converts a non-JSON server response into ApiException', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response('<html>Bad gateway</html>', 502),
        ),
        baseUrl: 'http://localhost:3001',
      );
      addTearDown(client.close);

      await expectLater(
        client.post('/tracking/eta-preview', body: const {}),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Respons server tidak valid.',
          ),
        ),
      );
    });
  });
  group('ApiConfig paths', () {
    test('every API path already carries the /api prefix', () {
      // ApiClient.baseUrl has no /api, so a path missing the prefix would hit a
      // 404 ("Endpoint tidak ditemukan"). This guards that regression.
      final paths = <String>[
        ApiConfig.customerAuth,
        ApiConfig.customerProfile,
        ApiConfig.customerAddresses,
        ApiConfig.customerFaqs,
        ApiConfig.customerServices,
        ApiConfig.customerServiceReviews('7'),
        ApiConfig.customerBookings,
        ApiConfig.customerChat,
        ApiConfig.trackingEtaPreview,
      ];
      for (final path in paths) {
        expect(path.startsWith('/api/'), isTrue, reason: path);
      }
      expect(ApiConfig.baseUrl.endsWith('/api'), isFalse);
    });
  });
}
