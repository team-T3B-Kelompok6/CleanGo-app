import '../../service/data/service_icon_catalog.dart';
import '../../service/domain/models/service_model.dart';
import '../domain/models/popular_category_model.dart';
import '../domain/models/popular_service_model.dart';
import '../domain/models/service_category_model.dart';

/// Builds the home screen sections from the service catalogue loaded from the
/// backend, so a category or service added in the admin dashboard shows up here.
abstract final class HomeCatalog {
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
          iconPath:
              service.iconPath ?? ServiceIconCatalog.forCategory(category),
          label: category,
          serviceId: service.id,
        ),
      );
    }
    return result;
  }

  /// Home grid built from the backend's popularity ranking. The icon is taken
  /// from a service in the same category so the grid keeps its look.
  static List<ServiceCategoryModel> fromPopularCategories(
    List<PopularCategoryModel> popular,
    List<ServiceModel> services, {
    int limit = 8,
  }) {
    return popular
        .take(limit)
        .map((category) {
          final match = services.where(
            (service) =>
                _categoryKey(service.category) == _categoryKey(category.name),
          );
          return ServiceCategoryModel(
            iconPath: match.isEmpty
                ? ServiceIconCatalog.forCategory(category.name)
                : (match.first.iconPath ??
                      ServiceIconCatalog.forCategory(category.name)),
            label: category.name,
            serviceId: category.serviceId,
          );
        })
        .toList(growable: false);
  }

  /// Older cached services used the short label "Sofa"; compare on a key that
  /// treats both spellings as the same category when matching icons.
  static String _categoryKey(String value) {
    final key = value.trim().toLowerCase();
    return key == 'sofa dan kasur' ? 'sofa' : key;
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
            imagePath:
                service.imagePath ??
                service.iconPath ??
                ServiceIconCatalog.fallback,
            iconPath:
                service.iconPath ??
                ServiceIconCatalog.forCategory(service.category),
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
