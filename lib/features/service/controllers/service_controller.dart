import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/storage/app_preferences.dart';
import '../data/service_data.dart';
import '../data/service_repository.dart';
import '../domain/models/service_model.dart';

class ServiceController extends ChangeNotifier {
  ServiceController({
    ServiceRepository? repository,
    this.preferences,
    List<ServiceModel>? initialServices,
    String? initialFilter,
  }) : _allServices = List<ServiceModel>.from(
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

  static const List<String> filters = ServiceData.filters;

  final AppPreferences? preferences;
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
              _selectedFilter == filters.first ||
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
    if (!filters.contains(filter) || filter == _selectedFilter) {
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
    if (_selectedFilter == filters.first && _searchQuery.isEmpty) {
      return;
    }

    _selectedFilter = filters.first;
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
  }

  void _applyServices(List<ServiceModel> services) {
    if (services.isEmpty) return;
    final selectedId = _selectedService?.id;
    _allServices = List<ServiceModel>.from(services);
    _selectedService = findServiceById(selectedId);
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
