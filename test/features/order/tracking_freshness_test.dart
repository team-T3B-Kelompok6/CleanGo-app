import 'package:cleango_app/features/order/data/eta_repository.dart';
import 'package:cleango_app/features/order/data/order_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 11, 13, 10);
  final order = OrderData.scheduledOrder.copyWith(
    backendBookingId: '9',
    hasCleanerCoordinates: true,
    cleanerLatitude: -7.97,
    cleanerLongitude: 112.61,
    etaUpdatedAt: now,
  );

  test(
    'GPS freshness uses GPS timestamp, never route calculation timestamp',
    () {
      expect(order.hasFreshCleanerLocation(now), isFalse);
      expect(
        order.copyWith(locationUpdatedAt: now).hasFreshCleanerLocation(now),
        isTrue,
      );
      expect(
        order
            .copyWith(
              locationUpdatedAt: now.subtract(const Duration(minutes: 5)),
            )
            .hasFreshCleanerLocation(now),
        isFalse,
      );
      expect(
        order
            .copyWith(
              locationUpdatedAt: now.subtract(
                const Duration(minutes: 5) - const Duration(milliseconds: 1),
              ),
            )
            .hasFreshCleanerLocation(now),
        isTrue,
      );
      expect(
        order
            .copyWith(locationUpdatedAt: now.add(const Duration(seconds: 1)))
            .hasFreshCleanerLocation(now),
        isFalse,
      );
      expect(
        order
            .copyWith(locationUpdatedAt: now, cleanerLatitude: double.nan)
            .hasFreshCleanerLocation(now),
        isFalse,
      );
    },
  );

  Map<String, dynamic> payload() => {
    'distanceMeters': 1200,
    'baselineEtaSeconds': 121,
    'etaSeconds': 121,
    'etaMinutes': 3,
    'source': 'osrm',
    'modelVersion': null,
    'updatedAt': now.toIso8601String(),
    'locationUpdatedAt': now
        .subtract(const Duration(seconds: 40))
        .toIso8601String(),
    'cleaner': {'latitude': -7.97, 'longitude': 112.61},
    'path': [
      [-7.97, 112.61],
      [-7.94, 112.62],
    ],
  };

  test('route outage preserves GPS and clears route-only values', () {
    final estimate = EtaEstimate.fromJson(payload()
      ..['routeStatus'] = 'unavailable'
      ..['routeMessage'] = 'OSRM offline'
      ..['etaSeconds'] = null
      ..['etaMinutes'] = null
      ..['distanceMeters'] = null
      ..['baselineEtaSeconds'] = null
      ..['source'] = null
      ..['path'] = []);
    final applied = estimate.applyTo(order);
    expect(estimate.hasRoute, isFalse);
    expect(applied.hasCleanerCoordinates, isTrue);
    expect(applied.cleanerLatitude, -7.97);
    expect(applied.locationUpdatedAt, now.subtract(const Duration(seconds: 40)).toLocal());
    expect(applied.etaUpdatedAt, isNull);
    expect(applied.routePoints, isEmpty);
    expect(applied.estimatedMinutes, 'Belum tersedia');
  });

  test('tracking parses separate durable GPS timestamp', () {
    final estimate = EtaEstimate.fromJson(payload());
    expect(
      estimate.locationUpdatedAt,
      now.subtract(const Duration(seconds: 40)).toLocal(),
    );
    expect(estimate.updatedAt, now.toLocal());
    expect(estimate.cleanerLatitude, -7.97);
    expect(estimate.path.length, 2);
  });

  test('invalid or partial cleaner coordinates never become GPS fixes', () {
    for (final cleaner in [
      {'latitude': -7.97},
      {'latitude': double.nan, 'longitude': 112.61},
      {'latitude': -91, 'longitude': 112.61},
      {'latitude': -7.97, 'longitude': 181},
    ]) {
      expect(
        () => EtaEstimate.fromJson(payload()..['cleaner'] = cleaner),
        throwsFormatException,
      );
    }
  });
}
