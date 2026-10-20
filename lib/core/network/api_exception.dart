class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
  });

  const ApiException.simple(this.message)
      : statusCode = 500,
        code = null;

  final int statusCode;
  final String message;
  final String? code;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
