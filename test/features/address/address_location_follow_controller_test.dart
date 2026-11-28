import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:cleango_app/features/address/controllers/address_location_follow_controller.dart';

class FakeLocationClient implements LocationClient {
  FakeLocationClient({this.result, this.delay, this.error});

  final Future<LatLng?>? result;
  final Duration? delay;
  final Object? error;

  int callCount = 0;
  Future<LatLng?> run() async {
    callCount++;
    if (error != null) throw error!;
    if (delay != null) await Future<void>.delayed(delay!);
    return result == null ? null : await result!;
  }

  @override
  Future<LatLng?> getCurrentLocation() => run();
}

void main() {
  group('AddressLocationFollowController', () {
    test('start updates status dan posisi setelah hasil valid', () async {
      final client = FakeLocationClient(
        result: Future.value(const LatLng(-7.2575, 112.7521)),
      );
      final controller = AddressLocationFollowController(locationClient: client);

      await controller.start();

      expect(controller.status, AddressFollowStatus.following);
      expect(controller.position, const LatLng(-7.2575, 112.7521));
      expect(controller.message, isNull);
      expect(client.callCount, 1);
    });

    test('loop polling 5 detik tanpa tumpang tindih', () async {
      final client = FakeLocationClient(
        result: Future.value(const LatLng(-7.2575, 112.7521)),
        delay: const Duration(milliseconds: 10),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
        interval: const Duration(milliseconds: 100),
      );

      await controller.start();
      expect(client.callCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 260));
      expect(client.callCount, 3);

      controller.stop();
    });

    test('stop menghentikan loop dan reset status', () async {
      final client = FakeLocationClient(
        result: Future.value(const LatLng(-7.2575, 112.7521)),
        delay: const Duration(milliseconds: 10),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
        interval: const Duration(milliseconds: 100),
      );

      await controller.start();
      expect(controller.isFollowing, isTrue);

      controller.stop();
      expect(controller.status, AddressFollowStatus.idle);
      expect(controller.isFollowing, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 260));
      // Setelah stop, jumlah panggilan tidak bertambah.
      expect(client.callCount, 1);
    });

    test('dispose menghentikan semua timer', () async {
      final client = FakeLocationClient(
        result: Future.value(const LatLng(-7.2575, 112.7521)),
        delay: const Duration(milliseconds: 10),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
        interval: const Duration(milliseconds: 100),
      );

      await controller.start();
      controller.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 260));
      expect(client.callCount, 1);
    });

    test('manual memilih titik menghentikan following', () {
      final client = FakeLocationClient(
        result: Future.value(const LatLng(-7.2575, 112.7521)),
      );
      final controller = AddressLocationFollowController(locationClient: client);

      // Simulasi halaman: start lalu pilih manual.
      controller.start();
      controller.stop(); // halaman memanggil stop() saat _selectPoint

      expect(controller.status, AddressFollowStatus.idle);
    });

    test('denied permission menghentikan loop dengan pesan', () async {
      final client = FakeLocationClient(
        error: PlatformException(code: 'permission_denied', message: 'denied'),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
        fixTimeout: const Duration(milliseconds: 50),
      );

      await controller.start();

      expect(controller.status, AddressFollowStatus.idle);
      expect(controller.message,
          'Izin lokasi ditolak. Aktifkan di pengaturan aplikasi.');
    });

    test('GPS off menghentikan loop dengan pesan', () async {
      final client = FakeLocationClient(
        error: PlatformException(
            code: 'location_unavailable', message: 'gps off'),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
        fixTimeout: const Duration(milliseconds: 50),
      );

      await controller.start();

      expect(controller.status, AddressFollowStatus.idle);
      expect(controller.message,
          'Lokasi tidak aktif atau tidak dapat ditemukan.');
    });

    test('timeout menghentikan loop dengan pesan', () async {
      final client = FakeLocationClient(
        result: Future<LatLng?>.delayed(
          const Duration(seconds: 5),
          () => const LatLng(-7.2575, 112.7521),
        ),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
        interval: const Duration(milliseconds: 50),
        fixTimeout: const Duration(milliseconds: 50),
      );

      await controller.start();

      expect(controller.status, AddressFollowStatus.idle);
      expect(controller.message,
          'Waktu pencarian lokasi habis. Coba lagi atau pilih titik secara manual.');
    });

    test('koordinat tidak valid diabaikan', () async {
      final client = FakeLocationClient(
        result: Future.value(const LatLng(double.nan, 112.7521)),
      );
      final controller = AddressLocationFollowController(
        locationClient: client,
        fixTimeout: const Duration(milliseconds: 50),
      );

      await controller.start();

      expect(controller.status, AddressFollowStatus.idle);
      expect(
        controller.message,
        'Titik lokasi tidak valid. Coba lagi atau pilih titik secara manual.',
      );
    });
  });
}
