import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

/// Ambil posisi GPS nyata lewat MethodChannel native yang sudah ada.
abstract class LocationClient {
  Future<LatLng?> getCurrentLocation();
}

class MethodChannelLocationClient implements LocationClient {
  MethodChannelLocationClient({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.cleango.app/location');

  final MethodChannel _channel;

  @override
  Future<LatLng?> getCurrentLocation() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'getCurrentLocation',
    );
    if (result == null) return null;
    final latitude = result['latitude'];
    final longitude = result['longitude'];
    if (latitude is! num || longitude is! num) return null;
    return LatLng(latitude.toDouble(), longitude.toDouble());
  }
}

enum AddressFollowStatus { idle, searching, following }

/// Follow GPS terbatas: polling 5 detik, tanpa tumpang tindih, berhenti
/// saat pengguna memilih titik/pan, lifecycle tidak aktif, atau dispose.
class AddressLocationFollowController extends ChangeNotifier {
  AddressLocationFollowController({
    required LocationClient locationClient,
    this.interval = const Duration(seconds: 5),
    this.fixTimeout = const Duration(seconds: 60),
  }) : _locationClient = locationClient;

  final LocationClient _locationClient;
  final Duration interval;
  final Duration fixTimeout;

  AddressFollowStatus _status = AddressFollowStatus.idle;
  LatLng? _position;
  String? _message;
  Timer? _timer;
  int _generation = 0;
  int _activeRequests = 0;
  bool _disposed = false;

  AddressFollowStatus get status => _status;
  LatLng? get position => _position;
  String? get message => _message;
  bool get isFollowing => _status == AddressFollowStatus.following;
  bool get isSearching => _status == AddressFollowStatus.searching;

  Future<void> start() async {
    if (_disposed) return;
    await _request(initial: true);
  }

  void stop() {
    if (_disposed) return;
    _generation++;
    _timer?.cancel();
    _timer = null;
    _status = AddressFollowStatus.idle;
    _message = null;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  Future<void> _request({required bool initial}) async {
    final generation = ++_generation;
    _activeRequests++;
    if (initial) {
      _status = AddressFollowStatus.searching;
      _message = null;
      _notify();
    }
    try {
      final fix = await _locationClient.getCurrentLocation().timeout(
        fixTimeout,
      );
      if (!_isCurrent(generation)) return;
      final validated = _validate(fix);
      if (validated == null) {
        _fail(
          'Titik lokasi tidak valid. Coba lagi atau pilih titik secara manual.',
        );
        return;
      }
      _position = validated;
      _status = AddressFollowStatus.following;
      _message = null;
      _notify();
      _scheduleNext();
    } catch (error) {
      if (!_isCurrent(generation)) return;
      _fail(_messageFor(error));
    } finally {
      _activeRequests--;
    }
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(interval, _onTick);
  }

  void _onTick() {
    if (_disposed || _status != AddressFollowStatus.following) return;
    if (_activeRequests > 0) return;
    _request(initial: false);
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  LatLng? _validate(LatLng? fix) {
    if (fix == null) return null;
    final latitude = fix.latitude;
    final longitude = fix.longitude;
    if (!latitude.isFinite || !longitude.isFinite) return null;
    if (latitude < -90 || latitude > 90) return null;
    if (longitude < -180 || longitude > 180) return null;
    return fix;
  }

  void _fail(String message) {
    _timer?.cancel();
    _timer = null;
    _status = AddressFollowStatus.idle;
    _message = message;
    _notify();
  }

  String _messageFor(Object error) => switch (error) {
    MissingPluginException() =>
      'Fitur lokasi tidak tersedia. Silakan pilih titik secara manual.',
    TimeoutException() =>
      'Waktu pencarian lokasi habis. Coba lagi atau pilih titik secara manual.',
    PlatformException(:final code) => switch (code) {
      'permission_denied' =>
        'Izin lokasi ditolak. Aktifkan di pengaturan aplikasi.',
      'location_timeout' => 'Waktu pencarian lokasi habis. Coba lagi atau pilih titik secara manual.',
      'location_unavailable' =>
        'Lokasi tidak aktif atau tidak dapat ditemukan.',
      _ => 'Gagal mendapatkan lokasi. Silakan pilih titik secara manual.',
    },
    _ => 'Gagal mendapatkan lokasi. Silakan pilih titik secara manual.',
  };

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}
