import 'package:cleango_app/features/service/data/customer_service_reviews_api.dart';
import 'package:cleango_app/features/service/domain/models/service_model.dart';
import 'package:cleango_app/features/service/pages/all_reviews_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReviewsApi extends CustomerServiceReviewsApi {
  _FakeReviewsApi({this.pages = const {}});

  final Map<int, ServiceReviewsPage> pages;

  @override
  Future<ServiceReviewsPage> fetchReviews(
    String serviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    return pages[page] ??
        const ServiceReviewsPage(
          rating: 0,
          reviewCount: 0,
          satisfactionPercentage: 0,
          reviews: [],
          page: 1,
          hasMore: false,
        );
  }
}

const _service = ServiceModel(
  id: '7',
  title: 'Deep Cleaning',
  description: 'Bersih menyeluruh',
  duration: '2 jam',
  price: 'Rp150.000',
  category: 'Rumah',
  iconPath: 'assets/icons/home.svg',
);

void main() {
  testWidgets('loads public reviews and shows a load-more button', (
    tester,
  ) async {
    final api = _FakeReviewsApi(
      pages: {
        1: const ServiceReviewsPage(
          rating: 4.5,
          reviewCount: 11,
          satisfactionPercentage: 90,
          reviews: [
            ServiceReviewModel(
              name: 'Budi Santoso',
              comment: 'Bersih dan rapi',
              rating: 5,
              date: 'Hari ini',
            ),
          ],
          page: 1,
          hasMore: true,
        ),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AllReviewsPage(service: _service, api: api),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Bersih dan rapi'), findsOneWidget);
    expect(find.text('Muat Lebih Banyak'), findsOneWidget);
  });
}
