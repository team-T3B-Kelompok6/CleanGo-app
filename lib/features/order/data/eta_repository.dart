import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/order_model.dart';

class EtaEstimate {
  const EtaEstimate({
    required this.distanceMeters,
    required this.baselineEtaSeconds,
    required this.etaSeconds,
    required this.etaMinutes,
    required this.source,
    required this.modelVersion,
    required this.updatedAt,
    required this.path,
    this.cleanerLatitude,
    this.cleanerLongitude,
    this.estimatedArrivalAt,
    this.locationUpdatedAt,
    this.routeStatus = 'available',
    this.routeMessage,
  });

  final int distanceMeters;
  final int baselineEtaSeconds;
  final int etaSeconds;
  final int etaMinutes;
  final String source;
  final String? modelVersion;
  final DateTime updatedAt;
  final List<RoutePoint> path;
  final double? cleanerLatitude;
  final double? cleanerLongitude;
  final DateTime? estimatedArrivalAt;
  final DateTime? locationUpdatedAt;
  final String routeStatus;
  final String? routeMessage;
  bool get hasRoute => routeStatus == 'available';

  ScheduledOrderModel applyTo(ScheduledOrderModel order) {
    final arrival = estimatedArrivalAt ?? updatedAt.add(Duration(seconds: etaSeconds));
    final clock = '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')} WIB';
    return order.copyWith(
      cleanerLatitude: cleanerLatitude,
      cleanerLongitude: cleanerLongitude,
      hasCleanerCoordinates: (cleanerLatitude != null && cleanerLongitude != null) ||
          (order.backendBookingId == null && order.hasCleanerCoordinates),
      locationUpdatedAt: locationUpdatedAt,
      clearLocationUpdatedAt: locationUpdatedAt == null,
      etaUpdatedAt: hasRoute ? updatedAt : null,
      clearEtaUpdatedAt: !hasRoute,
      routePoints: hasRoute ? path : const [],
      distanceKm: hasRoute ? '${(distanceMeters / 1000).toStringAsFixed(1)} km lagi' : 'Rute belum tersedia',
      estimatedMinutes: hasRoute ? '±$etaMinutes menit' : 'Belum tersedia',
      estimatedArrivalTime: hasRoute ? clock : 'Belum tersedia',
      etaSource: hasRoute ? 'Perhitungan rute OSRM' : routeMessage ?? 'Rute belum tersedia',
      arrivalEstimate: hasRoute ? 'Tiba ~$clock' : 'ETA belum tersedia',
      travelDescription: hasRoute ? '${(distanceMeters / 1000).toStringAsFixed(1)} km lagi • ±$etaMinutes menit' : routeMessage ?? 'Rute belum tersedia',
    );
  }

  factory EtaEstimate.fromJson(Map<String, dynamic> json) {
    final cleaner = json['cleaner'];
    double? latitude;
    double? longitude;
    if (cleaner != null) {
      if (cleaner is! Map<String, dynamic> ||
          cleaner['latitude'] is! num ||
          cleaner['longitude'] is! num) {
        throw const FormatException('Koordinat cleaner tidak valid.');
      }
      latitude = (cleaner['latitude'] as num).toDouble();
      longitude = (cleaner['longitude'] as num).toDouble();
      if (!RoutePoint.isValid(latitude, longitude)) {
        throw const FormatException('Koordinat cleaner tidak valid.');
      }
    }
    final routeStatus = json['routeStatus'] as String? ?? 'available';
    final hasRoute = routeStatus == 'available';
    return EtaEstimate(
      routeStatus: routeStatus,
      routeMessage: json['routeMessage'] as String?,
      distanceMeters: hasRoute ? (json['distanceMeters'] as num).round() : 0,
      baselineEtaSeconds: hasRoute ? (json['baselineEtaSeconds'] as num).round() : 0,
      etaSeconds: hasRoute ? (json['etaSeconds'] as num).round() : 0,
      etaMinutes: hasRoute ? (json['etaMinutes'] as num).round() : 0,
      source: json['source'] as String? ?? '',
      modelVersion: json['modelVersion'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      path: (json['path'] as List<dynamic>? ?? const [])
          .whereType<List<dynamic>>()
          .where(
            (point) =>
                point.length >= 2 &&
                point[0] is num &&
                point[1] is num &&
                RoutePoint.isValid(
                  (point[0] as num).toDouble(),
                  (point[1] as num).toDouble(),
                ),
          )
          .map(
            (point) => RoutePoint(
              latitude: (point[0] as num).toDouble(),
              longitude: (point[1] as num).toDouble(),
            ),
          )
          .toList(growable: false),
      cleanerLatitude: latitude,
      cleanerLongitude: longitude,
      locationUpdatedAt: DateTime.tryParse(
        json['locationUpdatedAt'] as String? ?? '',
      )?.toLocal(),
      estimatedArrivalAt: DateTime.tryParse(
        json['estimatedArrivalAt'] as String? ?? '',
      )?.toLocal(),
    );
  }
}

class EtaRepository {
  EtaRepository({ApiClient? client, TokenStorage? tokenStorage})
    : _client = client ?? ApiClient(),
      _tokens = tokenStorage ?? SecureTokenStorage();

  final ApiClient _client;
  final TokenStorage _tokens;

  Future<EtaEstimate> calculateForBooking(String bookingId) async {
    final token = await _tokens.readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Silakan masuk kembali.');
    }
    final response = await _client.get(
      '${ApiConfig.customerBookings}/${Uri.encodeComponent(bookingId)}/tracking',
      token: token,
      timeout: const Duration(seconds: 14),
    );
    final data = response['data'];
    if (data is! Map<String, dynamic> || data['orderId'] != bookingId) {
      throw const FormatException('Data ETA pesanan tidak sesuai.');
    }
    return EtaEstimate.fromJson(data);
  }

  Future<EtaEstimate> calculate({
    required double cleanerLatitude,
    required double cleanerLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final response = await _client.post(
      ApiConfig.trackingEtaPreview,
      body: {
        'cleanerLatitude': cleanerLatitude,
        'cleanerLongitude': cleanerLongitude,
        'destinationLatitude': destinationLatitude,
        'destinationLongitude': destinationLongitude,
      },
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Data ETA tidak tersedia.');
    }
    return EtaEstimate.fromJson(data);
  }

  void dispose() => _client.close();
}
