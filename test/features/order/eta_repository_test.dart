import 'dart:convert';

import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/core/storage/token_storage.dart';
import 'package:cleango_app/features/order/data/eta_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class TrackingTokens implements TokenStorage {
  TrackingTokens(this.token);
  final String? token;
  @override
  Future<String?> readAccessToken() async => token;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('real booking tracking uses authenticated ownership endpoint and server GPS', () async {
    final repository = EtaRepository(
      tokenStorage: TrackingTokens('customer-token'),
      client: ApiClient(
        baseUrl: 'http://localhost:3001',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/customer/bookings/9/tracking');
          expect(request.headers['Authorization'], 'Bearer customer-token');
          expect(request.url.query, isEmpty);
          return http.Response(
            jsonEncode({
              'data': {
                'orderId': '9',
                'distanceMeters': 1200,
                'baselineEtaSeconds': 121,
                'etaSeconds': 121,
                'etaMinutes': 3,
                'source': 'osrm',
                'modelVersion': null,
                'updatedAt': '2026-10-25T02:00:00Z',
                'estimatedArrivalAt': '2026-10-25T02:02:01Z',
                'cleaner': {'latitude': -7.97, 'longitude': 112.61},
                'path': [
                  [-7.97, 112.61],
                  [-7.94, 112.62],
                ],
              },
            }),
            200,
          );
        }),
      ),
    );
    addTearDown(repository.dispose);
    final result = await repository.calculateForBooking('9');
    expect(result.cleanerLatitude, -7.97);
    expect(result.cleanerLongitude, 112.61);
    expect(
      result.estimatedArrivalAt,
      DateTime.parse('2026-10-25T02:02:01Z').toLocal(),
    );
  });

  test(
    'does not fall back to public demo tracking when a session is missing',
    () async {
      var calls = 0;
      final repository = EtaRepository(
        tokenStorage: TrackingTokens(null),
        client: ApiClient(
          client: MockClient((_) async {
            calls++;
            return http.Response('{}', 200);
          }),
        ),
      );
      addTearDown(repository.dispose);
      await expectLater(repository.calculateForBooking('9'), throwsStateError);
      expect(calls, 0);
    },
  );

  test('rejects an estimate for a different booking', () async {
    final repository = EtaRepository(
      tokenStorage: TrackingTokens('token'),
      client: ApiClient(
        client: MockClient(
          (_) async => http.Response('{"data":{"orderId":"8"}}', 200),
        ),
      ),
    );
    addTearDown(repository.dispose);
    await expectLater(
      repository.calculateForBooking('9'),
      throwsFormatException,
    );
  });
  test('maps the ETA response from Express', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/tracking/eta-preview');
      expect(jsonDecode(request.body), {
        'cleanerLatitude': -7.97,
        'cleanerLongitude': 112.61,
        'destinationLatitude': -7.94,
        'destinationLongitude': 112.62,
      });
      return http.Response(
        jsonEncode({
          'data': {
            'distanceMeters': 4200,
            'baselineEtaSeconds': 720,
            'etaSeconds': 720,
            'etaMinutes': 12,
            'source': 'osrm',
            'modelVersion': null,
            'updatedAt': '2026-10-16T02:00:00.000Z',
            'path': [
              [-7.97, 112.61],
              [-7.94, 112.62],
            ],
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = EtaRepository(
      client: ApiClient(client: client, baseUrl: 'http://localhost:3001'),
    );

    final result = await repository.calculate(
      cleanerLatitude: -7.97,
      cleanerLongitude: 112.61,
      destinationLatitude: -7.94,
      destinationLongitude: 112.62,
    );

    expect(result.etaMinutes, 12);
    expect(result.source, 'osrm');
    expect(result.path, hasLength(2));
    expect(result.path.last.latitude, -7.94);
    expect(result.path.last.longitude, 112.62);
    repository.dispose();
  });
}
