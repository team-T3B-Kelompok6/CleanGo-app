import '../domain/models/popular_service_model.dart';
import '../domain/models/service_category_model.dart';

abstract final class HomeData {
  static const List<String> promoBanners = [
    'assets/images/promo_banner.png',
    'assets/images/promo_banner.png',
    'assets/images/promo_banner.png',
  ];

  static const List<ServiceCategoryModel> categories = [
    ServiceCategoryModel(
      iconPath: 'assets/icons/daily_cleaning.svg',
      label: 'Cleaning',
      accentText: 'harian',
      serviceId: 'daily-cleaning',
    ),
    ServiceCategoryModel(
      iconPath: 'assets/icons/ac_wash.svg',
      label: 'Cuci AC',
      serviceId: 'ac-care',
    ),
    ServiceCategoryModel(
      iconPath: 'assets/icons/deep_cleaning.svg',
      label: 'Deep\nCleaning',
      serviceId: 'deep-cleaning',
    ),
    ServiceCategoryModel(
      iconPath: 'assets/icons/ironing.svg',
      label: 'Layanan\nSetrika',
    ),
    ServiceCategoryModel(
      iconPath: 'assets/icons/monthly_cleaning.svg',
      label: 'Cleaning',
      accentText: 'bulanan',
    ),
    ServiceCategoryModel(
      iconPath: 'assets/icons/sofa_mattress.svg',
      label: 'Sofa &\nKasur',
      serviceId: 'sofa-mattress',
    ),
    ServiceCategoryModel(
      iconPath: 'assets/icons/ac_installation.svg',
      label: 'Pasang AC',
    ),
    ServiceCategoryModel(
      iconPath: 'assets/icons/office.svg',
      label: 'Kantor',
      serviceId: 'office-cleaning',
    ),
  ];

  static const List<PopularServiceModel> popularServices = [
    PopularServiceModel(
      serviceId: 'deep-cleaning',
      imagePath: 'assets/images/deep_cleaning.jpeg',
      badge: 'Terlaris',
      badgeStyle: PopularServiceBadgeStyle.primary,
      rating: '4.9',
      reviewCount: '(1.2k)',
      title: 'Deep Cleaning',
      description: 'Sanitasi menyeluruh & debu vakum',
      duration: '2 - 3 Jam Pengerjaan',
      price: 'Rp150.000',
    ),
    PopularServiceModel(
      serviceId: 'sofa-mattress',
      imagePath: 'assets/images/sofa_cleaning.jpeg',
      badge: 'Promo',
      badgeStyle: PopularServiceBadgeStyle.soft,
      rating: '4.8',
      reviewCount: '(850)',
      title: 'Cuci Sofa & Springbed',
      description: 'Ekstraksi tungau & noda membandel',
      duration: '1 - 2 Jam Pengerjaan',
      price: 'Rp120.000',
    ),
    PopularServiceModel(
      serviceId: 'ac-care',
      imagePath: 'assets/images/ac_service.jpeg',
      badge: 'Cepat',
      badgeStyle: PopularServiceBadgeStyle.dark,
      rating: '4.9',
      reviewCount: '(2.1k)',
      title: 'Service & Cuci AC',
      description: 'Cuci unit, cek freon & antibakteri',
      duration: '45 - 60 Menit',
      price: 'Rp75.000',
      unit: '/unit',
    ),
  ];
}
