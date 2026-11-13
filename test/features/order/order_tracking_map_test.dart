import 'package:cleango_app/features/order/data/order_data.dart';
import 'package:cleango_app/features/order/domain/models/order_model.dart';
import 'package:cleango_app/features/order/widgets/order_tracking_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  ScheduledOrderModel order({bool cleaner = false}) =>
      OrderData.scheduledOrder.copyWith(
        backendBookingId: '9',
        stage: OrderStatusStage.dalamPerjalanan,
        destinationLatitude: -7.94,
        destinationLongitude: 112.62,
        hasDestinationCoordinates: true,
        hasCleanerCoordinates: cleaner,
        cleanerLatitude: -7.98,
        cleanerLongitude: 112.60,
        locationUpdatedAt: DateTime.now(),
      );

  Future<void> showMap(WidgetTester tester, ScheduledOrderModel value) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: OrderTrackingMap(order: value)),
      ),
    );
    await tester.pump();
  }

  MapController controller(WidgetTester tester) =>
      tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;

  testWidgets(
    'first GPS recenters once, polls preserve pan, order switch syncs',
    (tester) async {
      await showMap(tester, order());
      expect(
        controller(tester).camera.center.latitude,
        closeTo(-7.94, 0.00001),
      );
      controller(tester).move(const LatLng(-7.90, 112.65), 15);

      final tracked = order(cleaner: true);
      await showMap(tester, tracked);
      expect(
        controller(tester).camera.center.latitude,
        closeTo(-7.96, 0.00001),
      );
      expect(
        controller(tester).camera.center.longitude,
        closeTo(112.61, 0.00001),
      );

      const panned = LatLng(-7.91, 112.66);
      controller(tester).move(panned, 15);
      await showMap(tester, tracked.copyWith(cleanerLatitude: -7.97));
      expect(controller(tester).camera.center, panned);

      await showMap(
        tester,
        tracked.copyWith(orderNumber: '#other', destinationLatitude: -7.92),
      );
      expect(
        controller(tester).camera.center.latitude,
        closeTo(-7.95, 0.00001),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('first GPS preserves deliberate user pan, outage keeps marker', (
    tester,
  ) async {
    await showMap(tester, order());
    const panned = LatLng(-7.91, 112.66);
    controller(tester).move(panned, 15);
    tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .options
        .onPositionChanged!(controller(tester).camera, true);
    await showMap(
      tester,
      order(cleaner: true).copyWith(routePoints: [], clearEtaUpdatedAt: true),
    );
    expect(controller(tester).camera.center, panned);
    final markers = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
    expect(markers.markers.length, 2);
    expect(find.byType(PolylineLayer), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'initial and recentered camera contains distant GPS and destination',
    (tester) async {
      final tracked = order(cleaner: true)
          .copyWith(cleanerLatitude: -6.2, cleanerLongitude: 106.8);
      await showMap(tester, tracked);
      void expectBothVisible() {
        final bounds = controller(tester).camera.visibleBounds;
        expect(bounds.contains(const LatLng(-6.2, 106.8)), isTrue);
        expect(bounds.contains(const LatLng(-7.94, 112.62)), isTrue);
      }

      expectBothVisible();
      controller(tester).move(const LatLng(-7.91, 112.66), 15);
      await tester.tap(find.byIcon(Icons.my_location_rounded));
      await tester.pump();
      expectBothVisible();
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('missing coordinates show no map or invented markers', (
    tester,
  ) async {
    await showMap(tester, order().copyWith(hasDestinationCoordinates: false));
    expect(find.byType(FlutterMap), findsNothing);
    expect(find.text('Menunggu koordinat lokasi'), findsOneWidget);
    await showMap(tester, order(cleaner: true));
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(controller(tester).camera.center.latitude, closeTo(-7.96, 0.00001));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('stale GPS stays last-known, expiry timer cancels on dispose', (
    tester,
  ) async {
    final stale = order(cleaner: true).copyWith(
      locationUpdatedAt: DateTime.now().subtract(const Duration(minutes: 6)),
      etaUpdatedAt: DateTime.now(),
    );
    await showMap(tester, stale);
    await showMap(tester, stale);
    expect(find.text('Lokasi terakhir · menunggu GPS'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(tester.takeException(), isNull);
    await showMap(tester, order(cleaner: true));
    expect(find.text('Lokasi terakhir · menunggu GPS'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 6));
    expect(tester.takeException(), isNull);
  });
}
