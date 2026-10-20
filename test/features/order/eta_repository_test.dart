import 'dart:convert';

import 'package:cleango_app/core/network/api_client.dart';
import 'package:cleango_app/features/order/data/eta_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('maps the ETA response from Express', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/tracking/eta-preview');
      return http.Response(
        jsonEncode({
          'data': {
            'distanceMeters': 4200,
            'baselineEtaSeconds': 900,
            'etaSeconds': 720,
            'etaMinutes': 12,
            'source': 'ml',
            'modelVersion': 'eta-v1',
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
      client: ApiClient(client: client, baseUrl: 'http://localhost:3001/api'),
    );

    final result = await repository.calculate(
      cleanerLatitude: -7.97,
      cleanerLongitude: 112.61,
      destinationLatitude: -7.94,
      destinationLongitude: 112.62,
      initialDistanceM: 6500,
      elapsedSeconds: 420,
      stoppedDurationSeconds: 30,
      rollingSpeedMps: 5.8,
    );

    expect(result.etaMinutes, 12);
    expect(result.source, 'ml');
    expect(result.path, hasLength(2));
    expect(result.path.last.latitude, -7.94);
    expect(result.path.last.longitude, 112.62);
    repository.dispose();
  });
}
