class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? errorCode;

  ApiException(
      {required this.message, required this.statusCode, this.errorCode});

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}
