import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
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
  });

  final int distanceMeters;
  final int baselineEtaSeconds;
  final int etaSeconds;
  final int etaMinutes;
  final String source;
  final String? modelVersion;
  final DateTime updatedAt;
  final List<RoutePoint> path;

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
    );
  }
}

class EtaRepository {
  EtaRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<EtaEstimate> calculate({
    required double cleanerLatitude,
    required double cleanerLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required double initialDistanceM,
    required double elapsedSeconds,
    required double stoppedDurationSeconds,
    required double rollingSpeedMps,
  }) async {
    final response = await _client.post(ApiConfig.trackingEtaPreview, body: {
      'cleanerLatitude': cleanerLatitude,
      'cleanerLongitude': cleanerLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'initialDistanceM': initialDistanceM,
      'elapsedSeconds': elapsedSeconds,
      'stoppedDurationSeconds': stoppedDurationSeconds,
      'rollingSpeedMps': rollingSpeedMps,
    });
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Data ETA tidak tersedia.');
    }
    return EtaEstimate.fromJson(data);
  }

  void dispose() => _client.close();
}
