import 'package:cleango_app/features/service/data/customer_service_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomerServiceRemoteDataSource.toServiceModel', () {
    test('maps backend service JSON into the existing ServiceModel shape', () {
      final service = CustomerServiceRemoteDataSource.toServiceModel({
        'id': 7,
        'name': 'Basic Home Cleaning',
        'description': 'Pembersihan rutin',
        'price': 100000,
        'durationMinutes': 120,
        'categoryName': 'Rumah',
        'imageUrl': null,
      });

      expect(service.id, '7');
      expect(service.title, 'Basic Home Cleaning');
      expect(service.price, 'Rp100.000');
      expect(service.duration, '2 jam');
      expect(service.category, 'Rumah');
      expect(service.iconPath, 'assets/icons/home.svg');
      expect(service.imagePath, isNull);
    });

    test('normalises the Sofa category label used by the mobile filter', () {
      final service = CustomerServiceRemoteDataSource.toServiceModel({
        'id': 9,
        'name': 'Sofa Cleaning',
        'price': 150000,
        'durationMinutes': 90,
        'categoryName': 'Sofa dan Kasur',
      });

      expect(service.category, 'Sofa');
      expect(service.duration, '1 jam 30 menit');
      expect(service.iconPath, 'assets/icons/deep_cleaning.svg');
    });

    test('keeps bundled asset images and falls back to an icon otherwise', () {
      final withAsset = CustomerServiceRemoteDataSource.toServiceModel({
        'id': 1,
        'name': 'X',
        'price': 1000,
        'durationMinutes': 60,
        'categoryName': 'AC',
        'imageUrl': 'assets/images/service_ac.jpeg',
      });
      final withRemote = CustomerServiceRemoteDataSource.toServiceModel({
        'id': 2,
        'name': 'Y',
        'price': 1000,
        'durationMinutes': 60,
        'categoryName': 'AC',
        'imageUrl': '/uploads/ac.png',
      });

      expect(withAsset.imagePath, 'assets/images/service_ac.jpeg');
      expect(withRemote.imagePath, isNull);
      expect(withRemote.iconPath, 'assets/icons/ac_wash.svg');
    });

    test('handles unknown categories and zero duration safely', () {
      final service = CustomerServiceRemoteDataSource.toServiceModel({
        'id': 3,
        'name': 'Mystery',
        'price': 0,
        'durationMinutes': 0,
        'categoryName': 'Lainnya',
      });

      expect(service.category, 'Lainnya');
      expect(service.duration, '-');
      expect(service.price, 'Rp0');
      expect(service.iconPath, 'assets/icons/services.svg');
    });
  });
}
