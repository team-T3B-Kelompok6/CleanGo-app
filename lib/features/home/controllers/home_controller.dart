import 'package:flutter/foundation.dart';

import '../data/customer_banner_api.dart';
import '../data/home_data.dart';

/// Home screen data that comes from the backend (promo banners today,
/// categories and popular services next). Falls back to the bundled demo data
/// when there is no session or the request fails.
class HomeController extends ChangeNotifier {
  HomeController({CustomerBannerApi? bannerApi}) : _bannerApi = bannerApi;

  final CustomerBannerApi? _bannerApi;
  List<String> _banners = HomeData.promoBanners;
  String? _error;
  bool _loading = false;

  List<String> get banners => List.unmodifiable(_banners);
  String? get error => _error;
  bool get loading => _loading;

  Future<void> loadFromApi() async {
    final api = _bannerApi;
    if (api == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final banners = await api.fetchBanners();
      if (banners.isNotEmpty) _banners = banners;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
