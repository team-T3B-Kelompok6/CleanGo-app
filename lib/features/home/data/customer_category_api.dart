import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../domain/models/popular_category_model.dart';

/// Service categories ranked by bookings, for the home screen grid.
class CustomerCategoryApi {
  CustomerCategoryApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<PopularCategoryModel>> fetchPopularCategories({int limit = 8}) async {
    final res = await _client.get(
      '${ApiConfig.customerPopularCategories}?limit=$limit',
    );
    final list = res['data'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(PopularCategoryModel.fromJson)
        .toList(growable: false);
  }
}
