import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../domain/models/order_model.dart';

class OrderTrackingMap extends StatefulWidget {
  const OrderTrackingMap({
    required this.order,
    this.height = 250,
    this.borderRadius = 18,
    this.controlsBottomInset = 12,
    super.key,
  });

  final ScheduledOrderModel order;
  final double height;
  final double borderRadius;
  final double controlsBottomInset;
  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap> {
  late final MapController _mapController;
  bool _mapReady = false;
  bool _syncedDestination = false;
  bool _syncedCleaner = false;
  bool _userPanned = false;
  Timer? _locationExpiryTimer;

  bool get _hasDestination =>
      widget.order.hasDestinationCoordinates &&
      RoutePoint.isValid(
        widget.order.destinationLatitude,
        widget.order.destinationLongitude,
      );

  bool get _hasCleaner =>
      widget.order.hasCleanerCoordinates &&
      RoutePoint.isValid(
        widget.order.cleanerLatitude,
        widget.order.cleanerLongitude,
      );

  bool get _isLocationStale =>
      widget.order.backendBookingId != null &&
      _hasCleaner &&
      !widget.order.hasFreshCleanerLocation(DateTime.now());

  LatLng? get _centerPoint {
    if (_isTravelActive) {
      return LatLng(
        (_currentCleanerPosition.latitude + _destinationPoint.latitude) / 2,
        (_currentCleanerPosition.longitude + _destinationPoint.longitude) / 2,
      );
    }
    if (_isTravelStage && _hasCleaner) return _currentCleanerPosition;
    if (_hasDestination) return _destinationPoint;
    return null;
  }

  void _scheduleInitialSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapReady || _centerPoint == null) return;
      final hasCleaner = _isTravelStage && _hasCleaner;
      if ((_hasDestination && !_syncedDestination) ||
          (hasCleaner && !_syncedCleaner)) {
        if (!_userPanned) _recenterMap();
        _syncedDestination = _hasDestination;
        _syncedCleaner = hasCleaner;
      }
    });
  }

  void _scheduleLocationExpiry() {
    _locationExpiryTimer?.cancel();
    final timestamp = widget.order.locationUpdatedAt;
    if (widget.order.backendBookingId == null || timestamp == null) return;
    final remaining = timestamp
        .add(const Duration(minutes: 5))
        .difference(DateTime.now());
    if (remaining <= Duration.zero) return;
    _locationExpiryTimer = Timer(remaining, () {
      if (mounted) setState(() {});
    });
  }

  LatLng get _destinationPoint => LatLng(
    widget.order.destinationLatitude,
    widget.order.destinationLongitude,
  );

  bool get _isTravelStage =>
      widget.order.stage == OrderStatusStage.ditugaskan ||
      widget.order.stage == OrderStatusStage.dalamPerjalanan;

  bool get _isTravelActive => _isTravelStage && _hasDestination && _hasCleaner;

  List<LatLng> get _routePoints => widget.order.routePoints
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList(growable: false);

  LatLng get _currentCleanerPosition =>
      LatLng(widget.order.cleanerLatitude, widget.order.cleanerLongitude);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _syncedDestination = _hasDestination;
    _syncedCleaner = _isTravelStage && _hasCleaner;
    _scheduleLocationExpiry();
  }

  @override
  void didUpdateWidget(covariant OrderTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.orderNumber != widget.order.orderNumber) {
      _userPanned = false;
      _syncedDestination = false;
      _syncedCleaner = false;
    }
    _scheduleLocationExpiry();
    _scheduleInitialSync();
  }

  @override
  void dispose() {
    _locationExpiryTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _recenterMap() {
    final center = _centerPoint;
    if (!_mapReady || center == null) return;
    if (_isTravelActive) {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [_currentCleanerPosition, _destinationPoint],
          padding: const EdgeInsets.all(52),
          maxZoom: 14.3,
        ),
      );
    } else {
      _mapController.move(center, 14.3);
    }
  }

  String get _remainingDistanceLabel {
    if (!_hasDestination) {
      return 'Titik tujuan belum tersedia';
    }
    if (widget.order.stage == OrderStatusStage.dikonfirmasi) {
      return 'Menunggu cleaner berangkat';
    }
    if (_isTravelStage && !_hasCleaner) {
      return 'Menunggu lokasi cleaner';
    }
    if (_isTravelStage && _isLocationStale) {
      return 'Lokasi terakhir · menunggu GPS';
    }
    if (!_isTravelActive) return 'Cleaner sudah tiba';
    return widget.order.distanceKm;
  }

  String get _routeTitle {
    if (!_hasDestination) return 'Alamat belum memiliki titik';
    if (_isTravelActive) return '${widget.order.originLocation} ➔ Tujuan';
    return 'Status perjalanan';
  }

  @override
  Widget build(BuildContext context) {
    final centerPoint = _centerPoint;
    final cleanerPosition = _hasCleaner ? _currentCleanerPosition : null;
    final showRoute = _isTravelActive && _routePoints.length >= 2;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            // Peta Nyata OSM menggunakan flutter_map
            if (centerPoint == null)
              const Center(child: Text('Menunggu koordinat lokasi'))
            else
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onPositionChanged: (_, hasGesture) {
                    if (hasGesture) _userPanned = true;
                  },
                  initialCenter: centerPoint,
                  initialZoom: 14.2,
                  initialCameraFit: _isTravelActive
                      ? CameraFit.coordinates(
                          coordinates: [
                            _currentCleanerPosition,
                            _destinationPoint,
                          ],
                          padding: const EdgeInsets.all(52),
                          maxZoom: 14.3,
                        )
                      : null,
                  maxZoom: 17.5,
                  onMapReady: () {
                    _mapReady = true;
                    _scheduleInitialSync();
                  },
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.cleango_app',
                  ),
                  if (showRoute)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 7.0,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4.5,
                          color: _isLocationStale
                              ? const Color(0xFF64748B)
                              : const Color(0xFF00685F),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      // 1. Marker Tujuan (Rumah Anda)
                      if (_hasDestination)
                        Marker(
                          point: _destinationPoint,
                          width: 110,
                          height: 80,
                          child: _buildDestinationMarker(),
                        ),
                      if (cleanerPosition != null && _isTravelStage)
                        Marker(
                          point: cleanerPosition,
                          width: 120,
                          height: 72,
                          child: _buildCleanerMarker(),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),

            Positioned(
              left: 12,
              bottom: widget.controlsBottomInset,
              child: _buildMiniCircleButton(
                icon: Icons.my_location_rounded,
                onTap: _recenterMap,
              ),
            ),

            // Informasi rute di kanan bawah area peta.
            Positioned(
              right: 12,
              bottom: widget.controlsBottomInset,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 0.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 13,
                      color: Color(0xFF00685F),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _routeTitle,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _remainingDistanceLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: _isLocationStale
                                ? const Color(0xFF64748B)
                                : const Color(0xFF00685F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanerMarker() {
    final label = _isLocationStale
        ? 'Lokasi terakhir'
        : widget.order.cleanerName.split(' ').first.isNotEmpty
        ? '${widget.order.cleanerName.split(' ').first} (Cleaner)'
        : 'Cleaner';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin Motor Siti (Cleaner)
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _isLocationStale
                ? const Color(0xFF64748B)
                : const Color(0xFF008378),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.two_wheeler_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Label Pill Cleaner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isLocationStale
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF2DD4BF),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: _isLocationStale
                  ? const Color(0xFF64748B)
                  : const Color(0xFF0F766E),
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin Rumah Anda
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.home_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(height: 2),
        // Label Pill Rumah Anda
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: const Text(
            'Rumah Anda',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }
}
