class MedusaApiException implements Exception {
  const MedusaApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'MedusaApiException($statusCode): $message';
}
