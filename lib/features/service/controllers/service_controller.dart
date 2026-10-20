import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/storage/app_preferences.dart';
import '../data/customer_service_remote_data_source.dart';
import '../data/service_data.dart';
import '../data/service_repository.dart';
import '../domain/models/service_model.dart';

class ServiceController extends ChangeNotifier {
  ServiceController({
    ServiceRepository? repository,
    this.preferences,
    List<ServiceModel>? initialServices,
    String? initialFilter,
    CustomerServiceDetailApi? detailApi,
  }) : _detailApi = detailApi,
       _allServices = List<ServiceModel>.from(
         initialServices ?? ServiceData.services,
       ),
       _selectedFilter = filters.contains(initialFilter)
           ? initialFilter!
           : filters.first {
    _subscription = repository?.watchServices().listen(_applyServices);
    if (repository != null) {
      unawaited(repository.refresh().catchError((_) => false));
    }
  }

  /// Default chips used before the catalogue is loaded.
  static const List<String> filters = ServiceData.filters;

  /// Filter chips built from the services currently loaded from the API, so a
  /// category added in the admin dashboard shows up here automatically.
  List<String> get filterOptions {
    final categories = _allServices
        .map((service) => service.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    if (categories.isEmpty) return filters;
    return [filters.first, ...categories];
  }

  final AppPreferences? preferences;
  final CustomerServiceDetailApi? _detailApi;
  final Set<String> _loadedDetails = <String>{};
  late List<ServiceModel> _allServices;
  late String _selectedFilter;
  String _searchQuery = '';
  ServiceModel? _selectedService;
  StreamSubscription<List<ServiceModel>>? _subscription;

  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  ServiceModel? get selectedService => _selectedService;

  ServiceModel? findServiceById(String? serviceId) {
    if (serviceId == null) {
      return null;
    }

    for (final service in _allServices) {
      if (service.id == serviceId) {
        return service;
      }
    }

    return null;
  }

  ServiceModel findServiceForHistory(String historyServiceName) {
    final normalizedName = historyServiceName.toLowerCase();

    final targetId = switch (normalizedName) {
      final name when name.contains('ac') || name.contains('cuci ac') =>
        'ac-care',
      final name when name.contains('kantor') || name.contains('usaha') =>
        'office-cleaning',
      final name when name.contains('harian') || name.contains('reguler') =>
        'daily-cleaning',
      final name when name.contains('sofa') || name.contains('kasur') =>
        'sofa-mattress',
      final name when name.contains('deep') || name.contains('cleaning') =>
        'deep-cleaning',
      _ => null,
    };

    if (targetId != null) {
      return findServiceById(targetId) ?? _allServices.first;
    }

    return _allServices.firstWhere(
      (service) => service.title.toLowerCase().contains(normalizedName),
      orElse: () => _allServices.first,
    );
  }

  List<ServiceModel> get visibleServices {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    return _allServices
        .where((service) {
          final matchesFilter =
              _selectedFilter == filterOptions.first ||
              service.category == _selectedFilter;
          final matchesSearch =
              normalizedQuery.isEmpty ||
              service.title.toLowerCase().contains(normalizedQuery) ||
              service.description.toLowerCase().contains(normalizedQuery) ||
              service.category.toLowerCase().contains(normalizedQuery);

          return matchesFilter && matchesSearch;
        })
        .toList(growable: false);
  }

  void selectFilter(String filter) {
    if (!filterOptions.contains(filter) || filter == _selectedFilter) {
      return;
    }

    _selectedFilter = filter;
    notifyListeners();
    unawaited(preferences?.saveLastServiceFilter(filter));
  }

  void updateSearchQuery(String query) {
    if (query == _searchQuery) {
      return;
    }

    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    if (_selectedFilter == filterOptions.first && _searchQuery.isEmpty) {
      return;
    }

    _selectedFilter = filterOptions.first;
    _searchQuery = '';
    notifyListeners();
    unawaited(preferences?.removeLastServiceFilter());
  }

  void selectService(ServiceModel service) {
    if (identical(service, _selectedService)) {
      return;
    }

    _selectedService = service;
    notifyListeners();
    unawaited(loadServiceDetail(service.id));
  }

  /// Fetches the facility list for [serviceId] once and enriches the cached
  /// service so the detail page can show `benefits`.
  Future<void> loadServiceDetail(String serviceId) async {
    final api = _detailApi;
    if (api == null || _loadedDetails.contains(serviceId)) return;
    _loadedDetails.add(serviceId);
    try {
      final detailed = await api.fetchDetail(serviceId);
      if (detailed == null || detailed.detail == null) return;
      _allServices = _allServices
          .map((service) => service.id == detailed.id ? detailed : service)
          .toList(growable: false);
      if (_selectedService?.id == detailed.id) _selectedService = detailed;
      notifyListeners();
    } catch (_) {
      _loadedDetails.remove(serviceId);
    }
  }

  void _applyServices(List<ServiceModel> services) {
    if (services.isEmpty) return;
    final selectedId = _selectedService?.id;
    _allServices = List<ServiceModel>.from(services);
    _selectedService = findServiceById(selectedId);
    if (!filterOptions.contains(_selectedFilter)) {
      _selectedFilter = filterOptions.first;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
