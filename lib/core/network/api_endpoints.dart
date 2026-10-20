abstract final class ApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3101/api',
  );

  static const etaPreview = '/tracking/eta-preview';
}
