import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/network/api_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('accepts both legacy API URLs and new host-only URLs', () {
    for (final url in [
      'http://192.168.10.230:3001/api',
      'http://192.168.10.230:3001/api/',
      'http://192.168.10.230:3001/',
      ' http://192.168.10.230:3001/api/ ',
    ]) {
      expect(ApiConfig.normalizeBaseUrl(url), 'http://192.168.10.230:3001');
    }
    expect(
      ApiConfig.normalizeBaseUrl('https://example.test/proxy/api/'),
      'https://example.test/proxy',
    );
  });
  test('keeps the configured phone host and removes only the API suffix', () {
    const configured = String.fromEnvironment('API_URL');
    if (configured.trim().isNotEmpty) {
      final expected = configured
          .trim()
          .replaceFirst(RegExp(r'/+$'), '')
          .replaceFirst(RegExp(r'/api$'), '');
      expect(ApiConfig.baseUrl, expected);
      expect(
        Uri.parse(ApiConfig.baseUrl).host,
        Uri.parse(configured.trim()).host,
      );
      expect(
        Uri.parse(ApiConfig.baseUrl).port,
        Uri.parse(configured.trim()).port,
      );
    }
    expect(ApiConfig.baseUrl.endsWith('/api'), isFalse);
    expect(ApiConfig.baseUrl.endsWith('/'), isFalse);
  });
  test(
    'customer requests keep one API prefix and the same base used by Boo',
    () async {
      final client = ApiClient(
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            '${ApiConfig.baseUrl}/api/customer/services',
          );
          expect(request.url.path.contains('/api/api/'), isFalse);
          return http.Response('{"data":[]}', 200);
        }),
      );
      addTearDown(client.close);
      await client.get(ApiConfig.customerServices);
      expect(ApiConfig.customerChat, '/api/customer/chat');
    },
  );
}
