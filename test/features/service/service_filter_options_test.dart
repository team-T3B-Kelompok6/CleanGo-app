import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

ServiceModel _service(String id, String category) => ServiceModel(
  id: id,
  title: 'Layanan $id',
  description: 'Deskripsi $id',
  duration: '2 jam',
  price: 'Rp100.000',
  category: category,
  iconPath: 'assets/icons/home.svg',
);

void main() {
  group('ServiceController.filterOptions', () {
    test('builds chips from the categories present in the loaded services', () {
      final controller = ServiceController(
        initialServices: [
          _service('1', 'Rumah'),
          _service('2', 'Kantor'),
          _service('3', 'Gudang'),
        ],
      );

      expect(controller.filterOptions, ['Semua', 'Gudang', 'Kantor', 'Rumah']);
    });

    test('deduplicates categories and sorts them', () {
      final controller = ServiceController(
        initialServices: [
          _service('1', 'Rumah'),
          _service('2', 'Rumah'),
          _service('3', 'AC'),
        ],
      );

      expect(controller.filterOptions, ['Semua', 'AC', 'Rumah']);
    });

    test('falls back to the default chips when no services are loaded', () {
      final controller = ServiceController(initialServices: const []);

      expect(controller.filterOptions, ServiceController.filters);
    });

    test('a newly added category can be selected and filters the list', () {
      final controller = ServiceController(
        initialServices: [
          _service('1', 'Rumah'),
          _service('2', 'Gudang'),
        ],
      );

      controller.selectFilter('Gudang');

      expect(controller.selectedFilter, 'Gudang');
      expect(controller.visibleServices.map((s) => s.id), ['2']);
    });

    test('rejects a category that is not in the current options', () {
      final controller = ServiceController(
        initialServices: [_service('1', 'Rumah')],
      );

      controller.selectFilter('Gudang');

      expect(controller.selectedFilter, 'Semua');
    });
  });
}
