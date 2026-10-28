import 'package:cleango_app/features/home/controllers/home_controller.dart';
import 'package:cleango_app/features/home/data/customer_category_api.dart';
import 'package:cleango_app/features/home/data/home_catalog.dart';
import 'package:cleango_app/features/home/data/home_data.dart';
import 'package:cleango_app/features/home/domain/models/popular_category_model.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCategoryApi extends CustomerCategoryApi {
  _FakeCategoryApi({this.categories = const [], this.fail = false});
  final List<PopularCategoryModel> categories;
  final bool fail;
  int calls = 0;

  @override
  Future<List<PopularCategoryModel>> fetchPopularCategories({
    int limit = 8,
  }) async {
    calls++;
    if (fail) throw StateError('jaringan mati');
    return categories;
  }
}

ServiceModel _service(String id, String category, {String? icon}) =>
    ServiceModel(
      id: id,
      title: 'Layanan $id',
      description: 'D',
      duration: '1 jam',
      price: 'Rp1.000',
      category: category,
      iconPath: icon ?? 'assets/icons/$category.svg',
    );

void main() {
  group('PopularCategoryModel.fromJson', () {
    test('maps the backend payload', () {
      final model = PopularCategoryModel.fromJson({
        'id': '3',
        'name': 'Kantor',
        'serviceCount': 2,
        'orderCount': 7,
        'firstServiceId': '12',
      });

      expect(model.id, '3');
      expect(model.name, 'Kantor');
      expect(model.serviceId, '12');
      expect(model.orderCount, 7);
    });

    test('handles a category without services', () {
      final model = PopularCategoryModel.fromJson({
        'id': '5',
        'name': 'AC',
        'firstServiceId': null,
      });

      expect(model.serviceId, isNull);
    });
  });

  group('HomeCatalog.fromPopularCategories', () {
    test('keeps the backend ranking and links each category', () {
      final models = HomeCatalog.fromPopularCategories(
        const [
          PopularCategoryModel(id: '3', name: 'Kantor', serviceId: '12'),
          PopularCategoryModel(id: '1', name: 'Rumah', serviceId: '7'),
        ],
        [_service('7', 'Rumah'), _service('12', 'Kantor')],
      );

      expect(models.map((c) => c.label), ['Kantor', 'Rumah']);
      expect(models.first.serviceId, '12');
      expect(models.first.iconPath, 'assets/icons/Kantor.svg');
    });

    test('shows at most eight categories', () {
      final popular = [
        for (var i = 0; i < 12; i++)
          PopularCategoryModel(id: '$i', name: 'Kat$i', serviceId: '$i'),
      ];

      expect(HomeCatalog.fromPopularCategories(popular, const []).length, 8);
    });

    test('uses the category icon when no service matches', () {
      final models = HomeCatalog.fromPopularCategories(const [
        PopularCategoryModel(id: '5', name: 'AC', serviceId: null),
      ], const []);

      expect(models.single.iconPath, 'assets/icons/service_ac.png');
      expect(models.single.serviceId, isNull);
    });

    test('falls back to the default icon for an unknown category', () {
      final models = HomeCatalog.fromPopularCategories(const [
        PopularCategoryModel(id: '9', name: 'Gudang', serviceId: null),
      ], const []);

      expect(models.single.iconPath, 'assets/icons/services.svg');
    });
  });

  group('HomeController popular categories', () {
    test('loads the ranking from the backend', () async {
      final api = _FakeCategoryApi(
        categories: const [
          PopularCategoryModel(
            id: '3',
            name: 'Kantor',
            serviceId: '12',
            orderCount: 9,
          ),
        ],
      );
      final controller = HomeController(categoryApi: api);

      await controller.loadFromApi();

      expect(api.calls, 1);
      expect(controller.popularCategories.single.name, 'Kantor');
      expect(controller.error, isNull);
    });

    test('keeps an empty ranking when the request fails', () async {
      final controller = HomeController(
        categoryApi: _FakeCategoryApi(fail: true),
      );

      await controller.loadFromApi();

      expect(controller.popularCategories, isEmpty);
      expect(controller.error, isNotNull);
      expect(controller.banners, HomeData.promoBanners);
    });
  });
}
