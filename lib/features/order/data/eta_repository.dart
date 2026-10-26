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

  factory EtaEstimate.fromJson(Map<String, dynamic> json) {
    return EtaEstimate(
      distanceMeters: (json['distanceMeters'] as num).round(),
      baselineEtaSeconds: (json['baselineEtaSeconds'] as num).round(),
      etaSeconds: (json['etaSeconds'] as num).round(),
      etaMinutes: (json['etaMinutes'] as num).round(),
      source: json['source'] as String,
      modelVersion: json['modelVersion'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      path: (json['path'] as List<dynamic>? ?? const [])
          .whereType<List<dynamic>>()
          .where((point) => point.length >= 2)
          .map(
            (point) => RoutePoint(
              latitude: (point[0] as num).toDouble(),
              longitude: (point[1] as num).toDouble(),
            ),
          )
          .toList(growable: false),
      cleanerLatitude: (json['cleaner']?['latitude'] as num?)?.toDouble(),
      cleanerLongitude: (json['cleaner']?['longitude'] as num?)?.toDouble(),
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
