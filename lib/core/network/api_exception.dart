class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
  });

  final int statusCode;
  final String message;
  final String? code;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
