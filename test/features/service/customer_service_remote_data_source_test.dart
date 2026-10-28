import 'package:cleango_app/core/network/api_config.dart';
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
      expect(service.iconPath, 'assets/icons/service_rumah.png');
      expect(service.imagePath, isNull);
    });

    test('keeps the backend category label for the mobile filter', () {
      final service = CustomerServiceRemoteDataSource.toServiceModel({
        'id': 9,
        'name': 'Sofa Cleaning',
        'price': 150000,
        'durationMinutes': 90,
        'categoryName': 'Sofa dan Kasur',
      });

      expect(service.category, 'Sofa dan Kasur');
      expect(service.duration, '1 jam 30 menit');
      expect(service.iconPath, 'assets/icons/service_sofa.png');
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
      expect(withRemote.imagePath, '${ApiConfig.baseUrl}/uploads/ac.png');
      expect(withRemote.iconPath, 'assets/icons/service_ac.png');
    });

    test('reads inclusions from the backend object shape', () {
      final inclusions = CustomerServiceDetailApi.inclusionsFrom({
        'inclusions': [
          {
            'id': 62,
            'description': 'Menyapu dan mengepel lantai',
            'sortOrder': 1,
          },
          {'id': 63, 'description': '  Membersihkan debu  ', 'sortOrder': 2},
          {'id': 64, 'description': '   ', 'sortOrder': 3},
        ],
      });

      expect(inclusions, ['Menyapu dan mengepel lantai', 'Membersihkan debu']);
    });

    test('still accepts plain string inclusions', () {
      final inclusions = CustomerServiceDetailApi.inclusionsFrom({
        'inclusions': ['Alat kebersihan', 'Cairan pembersih'],
      });

      expect(inclusions, ['Alat kebersihan', 'Cairan pembersih']);
    });

    test('returns an empty list when inclusions are missing', () {
      expect(CustomerServiceDetailApi.inclusionsFrom(const {}), isEmpty);
    });

    test('maps public reviews with avatar and photos', () {
      final reviews = CustomerServiceDetailApi.reviewsFrom({
        'reviews': [
          {
            'name': 'Budi Santoso',
            'avatarUrl': '/uploads/avatars/a.png',
            'rating': 5,
            'comment': 'Bersih sekali',
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 2))
                .toIso8601String(),
            'photos': [
              '/uploads/review-photos/1.jpg',
              'https://cdn.example.com/2.jpg',
            ],
          },
        ],
      });

      expect(reviews, hasLength(1));
      expect(reviews.first.name, 'Budi Santoso');
      expect(
        reviews.first.avatarUrl,
        '${ApiConfig.baseUrl}/uploads/avatars/a.png',
      );
      expect(reviews.first.date, '2 hari lalu');
      expect(reviews.first.imagePaths, [
        '${ApiConfig.baseUrl}/uploads/review-photos/1.jpg',
        'https://cdn.example.com/2.jpg',
      ]);
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
