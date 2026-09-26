class ServiceCategoryModel {
  const ServiceCategoryModel({
    required this.iconPath,
    required this.label,
    this.accentText,
    this.serviceId,
  });

  final String iconPath;
  final String label;
  final String? accentText;
  final String? serviceId;
}
