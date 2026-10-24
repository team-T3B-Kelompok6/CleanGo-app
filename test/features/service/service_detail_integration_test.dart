import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/data/customer_service_remote_data_source.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDetailApi extends CustomerServiceDetailApi {
  _FakeDetailApi({this.result, this.fail = false});

  final ServiceModel? result;
  final bool fail;
  int calls = 0;

  @override
  Future<ServiceModel?> fetchDetail(String serviceId) async {
    calls++;
    if (fail) throw StateError('jaringan mati');
    return result;
  }
}

const _plain = ServiceModel(
  id: '7',
  title: 'Basic Home Cleaning',
  description: 'Pembersihan rutin',
  duration: '2 jam',
  price: 'Rp100.000',
  category: 'Rumah',
  iconPath: 'assets/icons/home.svg',
);

const _detailed = ServiceModel(
  id: '7',
  title: 'Basic Home Cleaning',
  description: 'Pembersihan rutin',
  duration: '2 jam',
  price: 'Rp100.000',
  category: 'Rumah',
  iconPath: 'assets/icons/home.svg',
  detail: ServiceDetailModel(
    heroImagePath: 'assets/icons/home.svg',
    description: 'Pembersihan rutin',
    rating: '-',
    reviewCount: '0',
    satisfactionPercentage: 0,
    benefits: ['Menyapu dan mengepel lantai'],
    reviews: [],
  ),
);

void main() {
  group('ServiceController.loadServiceDetail', () {
    test('enriches the selected service with backend inclusions', () async {
      final api = _FakeDetailApi(result: _detailed);
      final controller = ServiceController(
        initialServices: const [_plain],
        detailApi: api,
      );

      controller.selectService(_plain);
      await Future<void>.delayed(Duration.zero);

      expect(api.calls, 1);
      expect(controller.selectedService?.detail?.benefits, [
        'Menyapu dan mengepel lantai',
      ]);
      expect(controller.findServiceById('7')?.detail?.benefits, isNotEmpty);
    });

    test('only fetches a service detail once', () async {
      final api = _FakeDetailApi(result: _detailed);
      final controller = ServiceController(
        initialServices: const [_plain],
        detailApi: api,
      );

      controller.selectService(_plain);
      await Future<void>.delayed(Duration.zero);
      await controller.loadServiceDetail('7');

      expect(api.calls, 1);
    });

    test('keeps the plain service when the detail request fails', () async {
      final api = _FakeDetailApi(fail: true);
      final controller = ServiceController(
        initialServices: const [_plain],
        detailApi: api,
      );

      await controller.loadServiceDetail('7');

      expect(controller.findServiceById('7')?.detail, isNull);
    });

    test('does nothing without a configured detail api', () async {
      final controller = ServiceController(initialServices: const [_plain]);

      await controller.loadServiceDetail('7');

      expect(controller.findServiceById('7')?.detail, isNull);
    });
  });
}
