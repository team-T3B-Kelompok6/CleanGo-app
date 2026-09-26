enum PopularServiceBadgeStyle { primary, soft, dark }

class PopularServiceModel {
  const PopularServiceModel({
    required this.serviceId,
    required this.imagePath,
    required this.badge,
    required this.badgeStyle,
    required this.rating,
    required this.reviewCount,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
    this.unit,
  });

  final String serviceId;
  final String imagePath;
  final String badge;
  final PopularServiceBadgeStyle badgeStyle;
  final String rating;
  final String reviewCount;
  final String title;
  final String description;
  final String duration;
  final String price;
  final String? unit;
}
