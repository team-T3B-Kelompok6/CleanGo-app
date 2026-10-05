import '../domain/models/service_model.dart';

enum ServiceSort { az, za, popular, newest }

extension ServiceSortLabel on ServiceSort {
  String get label => switch (this) {
    ServiceSort.az => 'A-Z',
    ServiceSort.za => 'Z-A',
    ServiceSort.popular => 'Populer',
    ServiceSort.newest => 'Terbaru',
  };
}

List<ServiceModel> sortServices(
  Iterable<ServiceModel> source,
  ServiceSort? sort,
) {
  final services = List<ServiceModel>.of(source);

  switch (sort) {
    case ServiceSort.az:
      services.sort(_compareTitleAscending);
    case ServiceSort.za:
      services.sort((a, b) => _compareTitleAscending(b, a));
    case ServiceSort.popular:
      services.sort((a, b) => b.popularity.compareTo(a.popularity));
    case ServiceSort.newest:
      services.sort((a, b) => b.releaseOrder.compareTo(a.releaseOrder));
    case null:
      break;
  }

  return services;
}

int _compareTitleAscending(ServiceModel a, ServiceModel b) {
  return a.title.toLowerCase().compareTo(b.title.toLowerCase());
}
