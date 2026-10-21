import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/service_model.dart';
import 'service_repository.dart';

/// Reads the customer service catalogue from the CleanGo backend and maps it to
/// the existing [ServiceModel] so the Flutter UI keeps its current structure.
class CustomerServiceRemoteDataSource implements ServiceRemoteDataSource {
  CustomerServiceRemoteDataSource({ApiClient? client, TokenStorage? tokenStorage})
      : _client = client ?? ApiClient(),
        _tokens = tokenStorage;

  final ApiClient _client;
  final TokenStorage? _tokens;

  static const Map<String, String> _categoryIcons = {
    'Rumah': 'assets/icons/home.svg',
    'Kantor': 'assets/icons/office.svg',
    'Sofa dan Kasur': 'assets/icons/deep_cleaning.svg',
    'Sofa': 'assets/icons/deep_cleaning.svg',
    'AC': 'assets/icons/ac_wash.svg',
  };

  @override
  Future<List<ServiceModel>> fetchServices() async {
    final token = await _tokens?.readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesi pelanggan belum tersedia.');
    }
    final res = await _client.get(ApiConfig.customerServices, token: token);
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(toServiceModel)
        .toList(growable: false);
  }

  /// Public so it can be unit tested without a network round-trip.
  static ServiceModel toServiceModel(Map<String, dynamic> json) {
    final categoryName = json['categoryName'] as String? ?? '';
    final category = categoryName == 'Sofa dan Kasur' ? 'Sofa' : categoryName;
    final minutes = (json['durationMinutes'] as num?)?.toInt() ?? 0;
    final imageUrl = json['imageUrl'] as String?;
    return ServiceModel(
      id: '${json['id']}',
      title: json['name'] as String? ?? 'Layanan',
      description: json['description'] as String? ?? '',
      duration: _formatDuration(minutes),
      price: _formatRupiah((json['price'] as num?)?.toInt() ?? 0),
      category: category,
      imagePath: resolveImageUrl(imageUrl),
      iconPath: _categoryIcons[categoryName] ?? 'assets/icons/services.svg',
      popularity: 0,
      releaseOrder: (json['id'] as num?)?.toInt() ?? 0,
    );
  }

  /// Bundled assets stay as-is; backend `/uploads/...` paths become absolute so
  /// Flutter can load them with `Image.network`.
  static String? resolveImageUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('assets/')) return value;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (value.startsWith('/')) return '${ApiConfig.baseUrl}$value';
    return null;
  }

  static String _formatDuration(int minutes) {
    if (minutes <= 0) return '-';
    if (minutes % 60 == 0) return '${minutes ~/ 60} jam';
    if (minutes > 60) {
      final hours = minutes ~/ 60;
      final rest = minutes % 60;
      return '$hours jam $rest menit';
    }
    return '$minutes menit';
  }

  static String _formatRupiah(int amount) {
    final digits = amount.toString();
    final groups = <String>[];
    for (var end = digits.length; end > 0; end -= 3) {
      final start = end - 3 < 0 ? 0 : end - 3;
      groups.insert(0, digits.substring(start, end));
    }
    return 'Rp${groups.join('.')}';
  }
}

/// Reads one service (with its `inclusions`) so the detail page can show the
/// facility list the backend already provides.
class CustomerServiceDetailApi {
  CustomerServiceDetailApi({ApiClient? client, TokenStorage? tokenStorage})
      : _client = client ?? ApiClient(),
        _tokens = tokenStorage;

  final ApiClient _client;
  final TokenStorage? _tokens;

  /// The backend returns `{ id, description, sortOrder }` objects; older
  /// payloads used plain strings, so both shapes are accepted.
  static String _inclusionText(dynamic item) {
    if (item is Map) {
      return (item['description'] ?? '').toString().trim();
    }
    return item.toString().trim();
  }

  /// Public for unit tests.
  static List<String> inclusionsFrom(Map<String, dynamic> data) =>
      (data['inclusions'] as List<dynamic>? ?? const [])
          .map(_inclusionText)
          .where((item) => item.isNotEmpty)
          .toList(growable: false);

  Future<ServiceModel?> fetchDetail(String serviceId) async {
    final token = await _tokens?.readAccessToken();
    if (token == null || token.isEmpty) return null;
    final res = await _client.get(
      '${ApiConfig.customerServices}/$serviceId',
      token: token,
    );
    final data = res['data'];
    if (data is! Map<String, dynamic>) return null;
    final base = CustomerServiceRemoteDataSource.toServiceModel(data);
    final inclusions = inclusionsFrom(data);
    return ServiceModel(
      id: base.id,
      title: base.title,
      description: base.description,
      duration: base.duration,
      price: base.price,
      category: base.category,
      imagePath: base.imagePath,
      iconPath: base.iconPath,
      badge: base.badge,
      rating: base.rating,
      popularity: base.popularity,
      releaseOrder: base.releaseOrder,
      detail: ServiceDetailModel(
        heroImagePath: base.imagePath ?? base.iconPath!,
        description: base.description,
        rating: base.rating ?? '-',
        reviewCount: '0',
        satisfactionPercentage: 0,
        benefits: inclusions,
        reviews: const [],
      ),
    );
  }
}
