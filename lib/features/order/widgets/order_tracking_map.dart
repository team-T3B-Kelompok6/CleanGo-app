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
    this.onCleanerPositionChanged,
    super.key,
  });

  final ScheduledOrderModel order;
  final double height;
  final double borderRadius;
  final double controlsBottomInset;
  final Future<void> Function(double latitude, double longitude)?
  onCleanerPositionChanged;

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;

  LatLng get _destinationPoint => LatLng(
    widget.order.destinationLatitude,
    widget.order.destinationLongitude,
  );

  bool get _isTravelStage =>
      widget.order.stage == OrderStatusStage.ditugaskan ||
      widget.order.stage == OrderStatusStage.dalamPerjalanan;

  bool get _isTravelActive =>
      _isTravelStage && widget.order.hasDestinationCoordinates;

  List<LatLng> get _remainingRoutePoints {
    final points = widget.order.routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    if (points.length >= 2) return points;
    return [_currentCleanerPosition, _destinationPoint];
  }

  List<LatLng> get _displayRoutePoints =>
      _isSimulating ? _simulationRoutePoints : _remainingRoutePoints;

  late LatLng _currentCleanerPosition;
  double _routeFraction = 0;
  List<LatLng> _simulationRoutePoints = const [];
  Timer? _simulationTimer;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCleanerPosition = LatLng(
      widget.order.cleanerLatitude,
      widget.order.cleanerLongitude,
    );
  }

  @override
  void didUpdateWidget(covariant OrderTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSimulating &&
        (oldWidget.order.cleanerLatitude != widget.order.cleanerLatitude ||
            oldWidget.order.cleanerLongitude !=
                widget.order.cleanerLongitude)) {
      _currentCleanerPosition = LatLng(
        widget.order.cleanerLatitude,
        widget.order.cleanerLongitude,
      );
    }
    if (!_isTravelActive && _isSimulating) {
      _simulationTimer?.cancel();
      _isSimulating = false;
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  LatLng _interpolatePointOnRoute(double fraction) {
    final routePoints = _simulationRoutePoints;
    if (routePoints.length < 2) return _destinationPoint;
    final clamped = fraction.clamp(0.0, 1.0);
    final totalSegments = routePoints.length - 1;
    final targetSegmentFloat = clamped * totalSegments;
    final segmentIndex = targetSegmentFloat.floor().clamp(0, totalSegments - 1);
    final segmentFraction = targetSegmentFloat - segmentIndex;

    final p1 = routePoints[segmentIndex];
    final p2 = routePoints[segmentIndex + 1];

    final lat = p1.latitude + (p2.latitude - p1.latitude) * segmentFraction;
    final lng = p1.longitude + (p2.longitude - p1.longitude) * segmentFraction;
    return LatLng(lat, lng);
  }

  void _toggleSimulation() {
    if (!_isTravelActive) return;
    if (_isSimulating) {
      _simulationTimer?.cancel();
      setState(() {
        _isSimulating = false;
      });
      return;
    }

    setState(() {
      _isSimulating = true;
      _routeFraction = 0;
      _simulationRoutePoints = List<LatLng>.from(_remainingRoutePoints);
    });

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _routeFraction += 0.1;
        if (_routeFraction >= 1.0) {
          _routeFraction = 1.0;
          _isSimulating = false;
          timer.cancel();
        }
        _currentCleanerPosition = _interpolatePointOnRoute(_routeFraction);
      });
      final callback = widget.onCleanerPositionChanged;
      if (callback != null) {
        unawaited(
          callback(
            _currentCleanerPosition.latitude,
            _currentCleanerPosition.longitude,
          ),
        );
      }
    });
  }

  void _recenterMap() {
    _mapController.move(
      _isTravelActive
          ? LatLng(
              (_currentCleanerPosition.latitude + _destinationPoint.latitude) /
                  2,
              (_currentCleanerPosition.longitude +
                      _destinationPoint.longitude) /
                  2,
            )
          : _isTravelStage || !widget.order.hasDestinationCoordinates
          ? _currentCleanerPosition
          : _destinationPoint,
      14.3,
    );
  }

  String get _remainingDistanceLabel {
    if (!widget.order.hasDestinationCoordinates) {
      return 'Titik tujuan belum tersedia';
    }
    if (widget.order.stage == OrderStatusStage.dikonfirmasi) {
      return 'Menunggu cleaner berangkat';
    }
    if (!_isTravelActive) return 'Cleaner sudah tiba';
    return widget.order.distanceKm;
  }

  @override
  Widget build(BuildContext context) {
    final centerPoint = _isTravelActive
        ? LatLng(
            (_currentCleanerPosition.latitude + _destinationPoint.latitude) / 2,
            (_currentCleanerPosition.longitude + _destinationPoint.longitude) /
                2,
          )
        : _isTravelStage || !widget.order.hasDestinationCoordinates
        ? _currentCleanerPosition
        : _destinationPoint;

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
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: centerPoint,
                initialZoom: 14.2,
                minZoom: 11.5,
                maxZoom: 17.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.cleango_app',
                ),
                if (_isTravelActive)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _displayRoutePoints,
                        strokeWidth: 7.0,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      Polyline(
                        points: _displayRoutePoints,
                        strokeWidth: 4.5,
                        color: const Color(0xFF00685F),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // 1. Marker Tujuan (Rumah Anda)
                    if (widget.order.hasDestinationCoordinates)
                      Marker(
                        point: _destinationPoint,
                        width: 110,
                        height: 70,
                        child: _buildDestinationMarker(),
                      ),
                    if (_isTravelStage)
                      Marker(
                        point: _currentCleanerPosition,
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

            // Kontrol simulasi di kiri bawah area peta.
            Positioned(
              left: 12,
              bottom: widget.controlsBottomInset,
              child: Row(
                children: [
                  if (_isTravelActive) ...[
                    _buildMapActionPill(
                      icon: _isSimulating
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: _isSimulating ? 'Pause' : 'Simulasi',
                      onTap: _toggleSimulation,
                      isHighlighted: _isSimulating,
                    ),
                    const SizedBox(width: 7),
                  ],
                  _buildMiniCircleButton(
                    icon: Icons.my_location_rounded,
                    onTap: _recenterMap,
                  ),
                ],
              ),
            ),

            // Informasi rute di kanan bawah area peta.
            Positioned(
              right: 12,
              bottom: widget.controlsBottomInset,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4.5,
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
                          !widget.order.hasDestinationCoordinates
                              ? 'Alamat belum memiliki titik'
                              : _isTravelActive
                              ? '${widget.order.originLocation} ➔ Tujuan'
                              : 'Status perjalanan',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _remainingDistanceLabel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00685F),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin Motor Siti (Cleaner)
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF008378),
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
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2DD4BF), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            widget.order.cleanerName.split(' ').first.isNotEmpty
                ? '${widget.order.cleanerName.split(' ').first} (Cleaner)'
                : 'Siti (Cleaner)',
            style: const TextStyle(
              color: Color(0xFF0F766E),
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

  Widget _buildMapActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFF00685F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF00685F)
                : const Color(0xFFCBD5E1),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isHighlighted ? Colors.white : const Color(0xFF00685F),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isHighlighted ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
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
