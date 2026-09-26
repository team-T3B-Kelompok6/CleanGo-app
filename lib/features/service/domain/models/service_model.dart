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
}

class ServiceDetailModel {
  const ServiceDetailModel({
    required this.heroImagePath,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.benefits,
    required this.reviews,
  });

  final String heroImagePath;
  final String description;
  final String rating;
  final String reviewCount;
  final List<String> benefits;
  final List<ServiceReviewModel> reviews;
}

class ServiceReviewModel {
  const ServiceReviewModel({
    required this.name,
    required this.comment,
    required this.rating,
  });

  final String name;
  final String comment;
  final int rating;
}
