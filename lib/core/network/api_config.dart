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
}
