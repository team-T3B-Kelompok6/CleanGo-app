import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:cleango_app/features/address/controllers/address_location_follow_controller.dart';
import 'package:cleango_app/features/address/pages/address_map_picker_page.dart';

class FakeFollowLocationClient implements LocationClient {
  FakeFollowLocationClient({this.result, this.delay, this.error});

  final Future<LatLng?>? result;
  final Duration? delay;
  final Object? error;
  int callCount = 0;

  @override
  Future<LatLng?> getCurrentLocation() async {
    callCount++;
    if (error != null) throw error!;
    if (delay != null) await Future<void>.delayed(delay!);
    return result == null ? null : await result!;
  }
}

void main() {
  group('AddressMapPickerPage GPS follow', () {
    testWidgets('tombol Gunakan lokasi saya memulai follow', (tester) async {
      final client = FakeFollowLocationClient(
        result: Future.value(const LatLng(-7.2575, 112.7521)),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
      );

      await tester.pumpWidget(
        MaterialApp(home: AddressMapPickerPage(followController: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gunakan lokasi saya'), findsOneWidget);
      await tester.tap(find.text('Gunakan lokasi saya'));
      await tester.pump();

      expect(controller.isFollowing, isTrue);
    });

    testWidgets('dialog izin tidak membatalkan posisi yang sedang diminta', (
      tester,
    ) async {
      final fix = Completer<LatLng?>();
      final controller = AddressLocationFollowController(
        locationClient: FakeFollowLocationClient(result: fix.future),
      );
      await tester.pumpWidget(
        MaterialApp(home: AddressMapPickerPage(followController: controller)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gunakan lokasi saya'));
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      fix.complete(const LatLng(-7.2575, 112.7521));
      await tester.pump();

      expect(controller.isFollowing, isTrue);
    });

    testWidgets('tap peta menghentikan follow', (tester) async {
      final client = FakeFollowLocationClient(
        result: Future.value(const LatLng(-7.2575, 112.7521)),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
      );

      await tester.pumpWidget(
        MaterialApp(home: AddressMapPickerPage(followController: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gunakan lokasi saya'));
      await tester.pump();
      expect(controller.isFollowing, isTrue);

      // FlutterMap.onTap memanggil _selectPoint yang men-stop follow.
      await tester.tap(find.byType(FlutterMap));
      await tester.pump(const Duration(milliseconds: 400));

      expect(controller.status, AddressFollowStatus.idle);
    });

    testWidgets('denied permission menampilkan pesan error', (tester) async {
      final client = FakeFollowLocationClient(
        error: PlatformException(code: 'permission_denied', message: 'denied'),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
        fixTimeout: const Duration(milliseconds: 50),
      );

      await tester.pumpWidget(
        MaterialApp(home: AddressMapPickerPage(followController: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gunakan lokasi saya'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      expect(
        find.text('Izin lokasi ditolak. Aktifkan di pengaturan aplikasi.'),
        findsOneWidget,
      );
    });
  });
}
