/// A service category ranked by how many bookings it received.
class PopularCategoryModel {
  const PopularCategoryModel({
    required this.id,
    required this.name,
    required this.serviceId,
    this.orderCount = 0,
    this.serviceCount = 0,
  });

  final String id;
  final String name;

  /// First active service in this category, used when the category is tapped.
  final String? serviceId;
  final int orderCount;
  final int serviceCount;

  factory PopularCategoryModel.fromJson(Map<String, dynamic> json) {
    return PopularCategoryModel(
      id: '${json['id'] ?? ''}',
      name: json['name'] as String? ?? '',
      serviceId: json['firstServiceId']?.toString(),
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      serviceCount: (json['serviceCount'] as num?)?.toInt() ?? 0,
    );
  }
}
