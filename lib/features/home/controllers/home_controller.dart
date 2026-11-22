import 'package:flutter/foundation.dart';

import '../data/customer_banner_api.dart';
import '../data/customer_category_api.dart';
import '../domain/models/popular_category_model.dart';

enum BannerStatus { loading, success, error }

/// Banner dan kategori memiliki siklus request serta kegagalan independen.
class HomeController extends ChangeNotifier {
  HomeController({this.bannerApi, this.categoryApi})
    : _bannerStatus = bannerApi == null
          ? BannerStatus.error
          : BannerStatus.loading,
      _bannerError = bannerApi == null ? 'Promo belum tersedia' : null;

  final CustomerBannerApi? bannerApi;
  final CustomerCategoryApi? categoryApi;
  List<PopularCategoryModel> _popularCategories = const [];
  List<String> _banners = const [];
  BannerStatus _bannerStatus;
  String? _bannerError;
  String? _categoryError;
  bool _bannerLoading = false;
  bool _categoryLoading = false;
  bool _disposed = false;

  bool get hasBannerApi => bannerApi != null;
  bool get hasCategoryApi => categoryApi != null;
  bool get hasApi => hasBannerApi || hasCategoryApi;
  List<String> get banners => List.unmodifiable(_banners);
  List<PopularCategoryModel> get popularCategories =>
      List.unmodifiable(_popularCategories);
  BannerStatus get bannerStatus => _bannerStatus;
  String? get bannerError => _bannerError;
  String? get categoryError => _categoryError;
  String? get error => (hasBannerApi ? _bannerError : null) ?? _categoryError;
  bool get loading => _bannerLoading || _categoryLoading;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadBanners() async {
    final api = bannerApi;
    if (_disposed || _bannerLoading || api == null) return;
    _bannerLoading = true;
    _bannerStatus = BannerStatus.loading;
    _bannerError = null;
    _notify();
    try {
      final banners = await api.fetchBanners();
      if (_disposed) return;
      _banners = List.of(banners);
      _bannerStatus = BannerStatus.success;
    } catch (error) {
      if (_disposed) return;
      _bannerError = error.toString();
      _bannerStatus = BannerStatus.error;
    } finally {
      _bannerLoading = false;
      _notify();
    }
  }

  Future<void> _loadCategories() async {
    final api = categoryApi;
    if (_disposed || _categoryLoading || api == null) return;
    _categoryLoading = true;
    _categoryError = null;
    _notify();
    try {
      final categories = await api.fetchPopularCategories();
      if (!_disposed) _popularCategories = categories;
    } catch (error) {
      if (!_disposed) _categoryError = error.toString();
    } finally {
      _categoryLoading = false;
      _notify();
    }
  }

  Future<void> loadFromApi() async {
    await Future.wait([loadBanners(), _loadCategories()]);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
