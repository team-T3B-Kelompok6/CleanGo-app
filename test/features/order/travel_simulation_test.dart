import 'package:cleango_app/features/order/data/eta_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ignores obsolete animation payload while waiting for device GPS', () {
    final result = EtaEstimate.fromJson({
      'updatedAt': '2026-11-25T05:00:00Z',
      'routeStatus': 'waiting',
      'routeMessage': 'Menunggu lokasi GPS.',
      'cleaner': null,
      'path': [],
      'travelSimulation': {
        'enabled': true,
        'mode': 'simulation',
        'position': {'latitude': -7.94, 'longitude': 112.62},
      },
    });

    expect(result.hasRoute, isFalse);
    expect(result.cleanerLatitude, isNull);
    expect(result.cleanerLongitude, isNull);
    expect(result.path, isEmpty);
  });
}
