import 'package:cleango_app/core/network/api_client.dart';
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
        baseUrl: 'http://localhost:3001/api',
      );
      addTearDown(client.close);

      final response = await client.post('/health', body: const {});

      expect(response['data'], {'status': 'ok'});
    });

    test('converts a non-JSON server response into ApiException', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response('<html>Bad gateway</html>', 502),
        ),
        baseUrl: 'http://localhost:3001/api',
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
}
