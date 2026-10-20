import 'package:cleango_app/features/home/data/home_catalog.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

ServiceModel _service(String id, String category, {String? rating, String? image}) =>
    ServiceModel(
      id: id,
      title: 'Layanan $id',
      description: 'Deskripsi $id',
      duration: '2 jam',
      price: 'Rp100.000',
      category: category,
      iconPath: 'assets/icons/$category.svg',
      imagePath: image,
      rating: rating,
    );

void main() {
  group('HomeCatalog.categories', () {
    test('creates one entry per category, in catalogue order', () {
      final categories = HomeCatalog.categories([
        _service('1', 'Rumah'),
        _service('2', 'Rumah'),
        _service('3', 'Gudang'),
      ]);

      expect(categories.map((c) => c.label), ['Rumah', 'Gudang']);
      expect(categories.first.iconPath, 'assets/icons/Rumah.svg');
    });

    test('links each category to its first service', () {
      final categories = HomeCatalog.categories([
        _service('7', 'Rumah'),
        _service('9', 'Rumah'),
      ]);

      expect(categories.single.serviceId, '7');
    });

    test('ignores blank categories', () {
      final categories = HomeCatalog.categories([
        _service('1', '   '),
        _service('2', 'AC'),
      ]);

      expect(categories.map((c) => c.label), ['AC']);
    });

    test('returns an empty list for an empty catalogue', () {
      expect(HomeCatalog.categories(const []), isEmpty);
    });
  });

  group('HomeCatalog.popularServices', () {
    test('maps the catalogue into cards', () {
      final popular = HomeCatalog.popularServices([
        _service('1', 'Rumah', rating: '4.9'),
      ]);

      expect(popular.single.serviceId, '1');
      expect(popular.single.title, 'Layanan 1');
      expect(popular.single.price, 'Rp100.000');
      expect(popular.single.duration, '2 jam');
      expect(popular.single.rating, '4.9');
    });

    test('limits the number of cards', () {
      final services = List.generate(8, (i) => _service('$i', 'Rumah'));

      expect(HomeCatalog.popularServices(services).length, 5);
      expect(HomeCatalog.popularServices(services, limit: 2).length, 2);
    });

    test('falls back to the icon when there is no image', () {
      final popular = HomeCatalog.popularServices([_service('1', 'AC')]);

      expect(popular.single.imagePath, 'assets/icons/AC.svg');
    });

    test('prefers the service image when present', () {
      final popular = HomeCatalog.popularServices([
        _service('1', 'AC', image: 'assets/images/ac.jpeg'),
      ]);

      expect(popular.single.imagePath, 'assets/images/ac.jpeg');
    });
  });
}
