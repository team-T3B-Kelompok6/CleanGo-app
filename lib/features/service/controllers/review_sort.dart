import '../domain/models/service_model.dart';

abstract final class ReviewSort {
  static const List<String> filters = [
    'Semua',
    'Terbaru',
    'Tertinggi',
    'Terendah',
  ];

  static List<ServiceReviewModel> apply(
    Iterable<ServiceReviewModel> source,
    String filter,
  ) {
    final reviews = List<ServiceReviewModel>.of(source);

    switch (filter) {
      case 'Tertinggi':
        reviews.sort((first, second) => second.rating.compareTo(first.rating));
      case 'Terendah':
        reviews.sort((first, second) => first.rating.compareTo(second.rating));
    }

    return reviews;
  }
}
