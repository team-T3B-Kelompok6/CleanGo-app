import 'dart:async';

import 'package:cleango_app/features/home/controllers/home_controller.dart';
import 'package:cleango_app/features/home/data/customer_banner_api.dart';
import 'package:cleango_app/features/home/data/customer_category_api.dart';
import 'package:cleango_app/features/home/domain/models/popular_category_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _BannerApi extends CustomerBannerApi {
  List<String> result = [];
  bool fail = false;
  Completer<List<String>>? pending;
  int calls = 0;

  @override
  Future<List<String>> fetchBanners() async {
    calls++;
    if (pending != null) return pending!.future;
    if (fail) throw StateError('offline');
    return result;
  }
}

class _CategoryApi extends CustomerCategoryApi {
  bool fail = false;
  Completer<List<PopularCategoryModel>>? pending;

  @override
  Future<List<PopularCategoryModel>> fetchPopularCategories({
    int limit = 8,
  }) async {
    if (pending != null) return pending!.future;
    if (fail) throw StateError('category offline');
    return const [PopularCategoryModel(id: '1', name: 'Rumah', serviceId: '1')];
  }
}

void main() {
  test('API tidak tersedia tidak boleh menayangkan promo dummy', () {
    final controller = HomeController();
    addTearDown(controller.dispose);
    expect(controller.banners, isEmpty);
    expect(controller.bannerStatus, BannerStatus.error);
  });

  test(
    'loading lalu sukses kosong; request ganda tidak menimpa hasil',
    () async {
      final api = _BannerApi()..pending = Completer<List<String>>();
      final controller = HomeController(bannerApi: api);
      addTearDown(controller.dispose);
      final loading = controller.loadFromApi();
      expect(controller.bannerStatus, BannerStatus.loading);
      expect(controller.loading, isTrue);
      await controller.loadFromApi();
      expect(api.calls, 1);
      api.pending!.complete([]);
      await loading;
      expect(controller.bannerStatus, BannerStatus.success);
      expect(controller.bannerError, isNull);
      expect(controller.banners, isEmpty);
      expect(controller.loading, isFalse);
    },
  );

  test('gagal lalu retry sukses satu dan banyak banner', () async {
    final api = _BannerApi()..fail = true;
    final controller = HomeController(bannerApi: api);
    addTearDown(controller.dispose);
    await controller.loadBanners();
    expect(controller.bannerStatus, BannerStatus.error);
    expect(controller.bannerError, isNotNull);
    expect(controller.banners, isEmpty);
    api.fail = false;
    api.result = ['https://example.test/real.png'];
    await controller.loadBanners();
    expect(controller.bannerStatus, BannerStatus.success);
    expect(controller.bannerError, isNull);
    expect(controller.banners, api.result);
    api.result = ['https://example.test/a.png', 'https://example.test/b.png'];
    await controller.loadBanners();
    expect(controller.banners, api.result);
    expect(() => controller.banners.add('dummy'), throwsUnsupportedError);
  });

  test('refresh gagal mempertahankan cache real serta status error', () async {
    final api = _BannerApi()..result = ['https://example.test/real.png'];
    final controller = HomeController(bannerApi: api);
    addTearDown(controller.dispose);
    await controller.loadBanners();
    api.fail = true;
    await controller.loadBanners();
    expect(controller.banners, api.result);
    expect(controller.bannerStatus, BannerStatus.error);
    expect(controller.bannerError, isNotNull);
  });

  test('banner kosong sukses tetap sukses saat kategori gagal', () async {
    final controller = HomeController(
      bannerApi: _BannerApi(),
      categoryApi: _CategoryApi()..fail = true,
    );
    addTearDown(controller.dispose);
    await controller.loadFromApi();
    expect(controller.banners, isEmpty);
    expect(controller.bannerStatus, BannerStatus.success);
    expect(controller.bannerError, isNull);
    expect(controller.categoryError, isNotNull);
  });

  test('kategori sukses tidak menghapus kegagalan banner', () async {
    final controller = HomeController(
      bannerApi: _BannerApi()..fail = true,
      categoryApi: _CategoryApi(),
    );
    addTearDown(controller.dispose);
    await controller.loadFromApi();
    expect(controller.bannerStatus, BannerStatus.error);
    expect(controller.categoryError, isNull);
    expect(controller.popularCategories.single.name, 'Rumah');
  });

  test('kategori tidak menunggu request banner selesai', () async {
    final api = _BannerApi()..pending = Completer<List<String>>();
    final controller = HomeController(
      bannerApi: api,
      categoryApi: _CategoryApi(),
    );
    addTearDown(controller.dispose);
    final load = controller.loadFromApi();
    await Future<void>.delayed(Duration.zero);
    expect(controller.popularCategories, isNotEmpty);
    expect(controller.bannerStatus, BannerStatus.loading);
    api.pending!.complete([]);
    await load;
  });

  test(
    'dispose saat request tertunda tidak mengirim notifikasi terlambat',
    () async {
      final api = _BannerApi()..pending = Completer<List<String>>();
      final categoryApi = _CategoryApi()
        ..pending = Completer<List<PopularCategoryModel>>();
      final controller = HomeController(
        bannerApi: api,
        categoryApi: categoryApi,
      );
      var notifications = 0;
      controller.addListener(() => notifications++);
      final load = controller.loadFromApi();
      controller.dispose();
      final before = notifications;
      api.pending!.complete(['late']);
      categoryApi.pending!.completeError(StateError('late'));
      await load;
      expect(notifications, before);
      expect(controller.banners, isEmpty);
    },
  );
}
