import 'package:cleango_app/core/network/api_config.dart';
import 'package:cleango_app/features/home/controllers/home_controller.dart';
import 'package:cleango_app/features/home/data/customer_banner_api.dart';
import 'package:cleango_app/features/home/data/home_data.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBannerApi extends CustomerBannerApi {
  _FakeBannerApi({this.banners = const [], this.fail = false});

  final List<String> banners;
  final bool fail;
  int calls = 0;

  @override
  Future<List<String>> fetchBanners() async {
    calls++;
    if (fail) throw StateError('jaringan mati');
    return banners;
  }
}

void main() {
  group('CustomerBannerApi.resolveImageUrl', () {
    test('keeps bundled assets untouched', () {
      expect(
        CustomerBannerApi.resolveImageUrl('assets/images/promo_banner.png'),
        'assets/images/promo_banner.png',
      );
    });

    test('keeps absolute http(s) urls', () {
      expect(
        CustomerBannerApi.resolveImageUrl('https://cdn.example.com/a.png'),
        'https://cdn.example.com/a.png',
      );
    });

    test('resolves backend /uploads paths against the base url', () {
      expect(
        CustomerBannerApi.resolveImageUrl('/uploads/banner.png'),
        '${ApiConfig.baseUrl}/uploads/banner.png',
      );
    });

    test('rejects empty and unsupported values', () {
      expect(CustomerBannerApi.resolveImageUrl(null), '');
      expect(CustomerBannerApi.resolveImageUrl('   '), '');
      expect(CustomerBannerApi.resolveImageUrl('uploads/banner.png'), '');
    });
  });

  group('HomeController.loadFromApi', () {
    test('uses the banners from the backend', () async {
      final api = _FakeBannerApi(banners: ['http://x/a.png', 'http://x/b.png']);
      final controller = HomeController(bannerApi: api);

      await controller.loadFromApi();

      expect(api.calls, 1);
      expect(controller.banners, ['http://x/a.png', 'http://x/b.png']);
      expect(controller.error, isNull);
    });

    test('keeps the bundled banners when the backend returns none', () async {
      final controller = HomeController(bannerApi: _FakeBannerApi());

      await controller.loadFromApi();

      expect(controller.banners, HomeData.promoBanners);
    });

    test('keeps the bundled banners and records the error on failure', () async {
      final controller = HomeController(bannerApi: _FakeBannerApi(fail: true));

      await controller.loadFromApi();

      expect(controller.banners, HomeData.promoBanners);
      expect(controller.error, isNotNull);
    });

    test('does nothing without a configured api', () async {
      final controller = HomeController();

      await controller.loadFromApi();

      expect(controller.banners, HomeData.promoBanners);
    });
  });
}
