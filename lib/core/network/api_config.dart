import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3101';
    }
    return 'http://127.0.0.1:3101';
  }

  static const String apiPrefix = '/api';
  static String get customerAuth => '$apiPrefix/customer/auth';
  static String get customerProfile => '$apiPrefix/customer/profile';
  static String get customerAddresses => '$apiPrefix/customer/addresses';
  static String get customerFaqs => '$apiPrefix/customer/faqs';
  static String get customerServices => '$apiPrefix/customer/services';
  static String get customerBookings => '$apiPrefix/customer/bookings';
  static String get customerChat => '$apiPrefix/customer/chat';
  static String get trackingEtaPreview => '$apiPrefix/tracking/eta-preview';
  static String get customerBanners => '$apiPrefix/customer/banners';
  static String get customerPromos => '$apiPrefix/customer/promos';
  static String get customerPromoValidate => '$apiPrefix/customer/promos/validate';
}
