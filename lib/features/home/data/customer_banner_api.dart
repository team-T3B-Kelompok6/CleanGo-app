import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/storage/token_storage.dart';

/// Reads the home promo banners managed in the admin dashboard.
class CustomerBannerApi {
  CustomerBannerApi({ApiClient? client, TokenStorage? tokenStorage})
      : _client = client ?? ApiClient(),
        _tokens = tokenStorage;

  final ApiClient _client;
  final TokenStorage? _tokens;

  /// Returns absolute image sources. Local `/uploads/...` paths are resolved
  /// against the backend base URL so Flutter can load them with `Image.network`.
  Future<List<String>> fetchBanners() async {
    final token = await _tokens?.readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Sesi pelanggan belum tersedia.');
    }
    final res = await _client.get(ApiConfig.customerBanners, token: token);
    final list = res['data'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => resolveImageUrl(item['imageUrl']?.toString()))
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  /// Public so it can be unit tested. Bundled `assets/...` stay as-is.
  static String resolveImageUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('assets/')) return value;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (value.startsWith('/')) return '${ApiConfig.baseUrl}$value';
    return '';
  }
}
