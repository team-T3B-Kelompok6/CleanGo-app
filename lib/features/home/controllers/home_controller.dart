import 'package:flutter/foundation.dart';

import '../data/customer_banner_api.dart';
import '../data/customer_category_api.dart';
import '../data/home_data.dart';
import '../domain/models/popular_category_model.dart';

/// Home screen data that comes from the backend (promo banners today,
/// categories and popular services next). Falls back to the bundled demo data
/// when there is no session or the request fails.
class HomeController extends ChangeNotifier {
  HomeController({CustomerBannerApi? bannerApi, CustomerCategoryApi? categoryApi})
      : _bannerApi = bannerApi,
        _categoryApi = categoryApi;

  final CustomerBannerApi? _bannerApi;
  final CustomerCategoryApi? _categoryApi;
  List<PopularCategoryModel> _popularCategories = const [];
  List<String> _banners = HomeData.promoBanners;
  String? _error;
  bool _loading = false;

  List<String> get banners => List.unmodifiable(_banners);

  /// Service categories ranked by bookings (home "Layanan" grid).
  List<PopularCategoryModel> get popularCategories =>
      List.unmodifiable(_popularCategories);
  String? get error => _error;
  bool get loading => _loading;

  Future<void> loadFromApi() async {
    if (_bannerApi == null && _categoryApi == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Each call is independent: one failing must not hide the other.
      if (_bannerApi != null) {
        try {
          final banners = await _bannerApi.fetchBanners();
          if (banners.isNotEmpty) _banners = banners;
        } catch (error) {
          _error = error.toString();
        }
      }
      if (_categoryApi != null) {
        try {
          _popularCategories = await _categoryApi.fetchPopularCategories();
        } catch (error) {
          _error = error.toString();
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
