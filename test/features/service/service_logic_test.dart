import 'package:cleango_app/features/service/controllers/review_sort.dart';
import 'package:cleango_app/features/service/controllers/service_controller.dart';
import 'package:cleango_app/features/service/controllers/service_sort.dart';
import 'package:cleango_app/features/service/data/service_data.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sortServices', () {
    test('sorts alphabetically without mutating the source list', () {
      final source = ServiceData.services.toList();
      final originalIds = source.map((service) => service.id).toList();

      final ascending = sortServices(source, ServiceSort.az);
      final descending = sortServices(source, ServiceSort.za);

      expect(source.map((service) => service.id), originalIds);
      expect(ascending.first.title.toLowerCase(), 'cleaning harian (reguler)');
      expect(descending.first.title.toLowerCase(), 'deep cleaning');
    });

    test('sorts popular and newest using existing metadata', () {
      final popular = sortServices(ServiceData.services, ServiceSort.popular);
      final newest = sortServices(ServiceData.services, ServiceSort.newest);

      expect(popular.first.popularity, 95);
      expect(newest.first.releaseOrder, 5);
    });
  });

  group('ReviewSort', () {
    const reviews = [
      ServiceReviewModel(name: 'A', comment: 'A', rating: 3, date: 'Hari ini'),
      ServiceReviewModel(name: 'B', comment: 'B', rating: 5, date: 'Kemarin'),
      ServiceReviewModel(
        name: 'C',
        comment: 'C',
        rating: 4,
        date: '2 hari lalu',
      ),
    ];

    test('keeps current order for Semua and Terbaru', () {
      expect(ReviewSort.apply(reviews, 'Semua'), reviews);
      expect(ReviewSort.apply(reviews, 'Terbaru'), reviews);
    });

    test('sorts by highest and lowest rating', () {
      expect(
        ReviewSort.apply(reviews, 'Tertinggi').map((review) => review.rating),
        [5, 4, 3],
      );
      expect(
        ReviewSort.apply(reviews, 'Terendah').map((review) => review.rating),
        [3, 4, 5],
      );
    });
  });

  group('ServiceController search state', () {
    test('distinguishes a no-result search and restores data after reset', () {
      final controller = ServiceController();

      controller.updateSearchQuery('xyz999tidakada');
      expect(controller.visibleServices, isEmpty);

      controller.resetFilters();
      expect(controller.visibleServices, isNotEmpty);
    });
  });
}
