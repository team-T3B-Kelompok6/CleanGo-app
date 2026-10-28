import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../domain/models/service_model.dart';
import 'customer_service_remote_data_source.dart';

class ServiceReviewsPage {
  const ServiceReviewsPage({
    required this.rating,
    required this.reviewCount,
    required this.satisfactionPercentage,
    required this.reviews,
    required this.page,
    required this.hasMore,
  });

  final double? rating;
  final int reviewCount;
  final int satisfactionPercentage;
  final List<ServiceReviewModel> reviews;
  final int page;
  final bool hasMore;
}

class CustomerServiceReviewsApi {
  CustomerServiceReviewsApi({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<ServiceReviewsPage> fetchReviews(
    String serviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _client.get(
      '${ApiConfig.customerServiceReviews(serviceId)}?page=$page&limit=$limit',
    );
    final data = res['data'] as Map<String, dynamic>? ?? const {};
    return ServiceReviewsPage(
      rating: (data['rating'] as num?)?.toDouble(),
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      satisfactionPercentage:
          (data['satisfactionPercentage'] as num?)?.toInt() ?? 0,
      reviews: CustomerServiceDetailApi.reviewsFrom(data),
      page: (data['page'] as num?)?.toInt() ?? page,
      hasMore: data['hasMore'] == true,
    );
  }
}
