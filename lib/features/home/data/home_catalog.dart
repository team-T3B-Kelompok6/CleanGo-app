import '../../service/domain/models/service_model.dart';
import '../domain/models/popular_service_model.dart';
import '../domain/models/service_category_model.dart';

/// Builds the home screen sections from the service catalogue loaded from the
/// backend, so a category or service added in the admin dashboard shows up here.
abstract final class HomeCatalog {
  static const String _fallbackIcon = 'assets/icons/services.svg';

  /// One chip per category present in the catalogue, linked to its first
  /// service so tapping it opens that service.
  static List<ServiceCategoryModel> categories(List<ServiceModel> services) {
    final seen = <String>{};
    final result = <ServiceCategoryModel>[];
    for (final service in services) {
      final category = service.category.trim();
      if (category.isEmpty || !seen.add(category)) continue;
      result.add(
        ServiceCategoryModel(
          iconPath: service.iconPath ?? _fallbackIcon,
          label: category,
          serviceId: service.id,
        ),
      );
    }
    return result;
  }

  /// The first [limit] catalogue entries, presented as the "popular" carousel.
  static List<PopularServiceModel> popularServices(
    List<ServiceModel> services, {
    int limit = 5,
  }) {
    return services
        .take(limit)
        .map(
          (service) => PopularServiceModel(
            serviceId: service.id,
            imagePath: service.imagePath ?? service.iconPath ?? _fallbackIcon,
            badge: 'Populer',
            badgeStyle: PopularServiceBadgeStyle.primary,
            rating: service.rating ?? '-',
            reviewCount: '0',
            title: service.title,
            description: service.description,
            duration: service.duration,
            price: service.price,
          ),
        )
        .toList(growable: false);
  }
}
