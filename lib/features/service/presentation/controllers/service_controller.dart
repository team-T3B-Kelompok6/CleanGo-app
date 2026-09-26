import 'package:flutter/foundation.dart';

import '../../data/service_data.dart';
import '../../domain/models/service_model.dart';

class ServiceController extends ChangeNotifier {
  static const List<String> filters = ServiceData.filters;
  static const List<ServiceModel> _allServices = ServiceData.services;

  String _selectedFilter = filters.first;
  String _searchQuery = '';
  ServiceModel? _selectedService;

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
  }

  void selectService(ServiceModel service) {
    if (identical(service, _selectedService)) {
      return;
    }

    _selectedService = service;
    notifyListeners();
  }
}
