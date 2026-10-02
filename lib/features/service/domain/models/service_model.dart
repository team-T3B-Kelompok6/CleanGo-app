class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
    required this.category,
    this.imagePath,
    this.iconPath,
    this.badge,
    this.rating,
    this.detail,
    this.popularity = 0,
    this.releaseOrder = 0,
  }) : assert(imagePath != null || iconPath != null);

  final String id;
  final String title;
  final String description;
  final String duration;
  final String price;
  final String category;
  final String? imagePath;
  final String? iconPath;
  final String? badge;
  final String? rating;
  final ServiceDetailModel? detail;
  final int popularity;
  final int releaseOrder;
}

class ServiceDetailModel {
  const ServiceDetailModel({
    required this.heroImagePath,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.satisfactionPercentage,
    required this.benefits,
    required this.reviews,
  });

  final String heroImagePath;
  final String description;
  final String rating;
  final String reviewCount;
  final int satisfactionPercentage;
  final List<String> benefits;
  final List<ServiceReviewModel> reviews;
}

class ServiceReviewModel {
  const ServiceReviewModel({
    required this.name,
    required this.comment,
    required this.rating,
    required this.date,
    this.imagePaths = const [],
  });

  final String name;
  final String comment;
  final int rating;
  final String date;
  final List<String> imagePaths;
}
