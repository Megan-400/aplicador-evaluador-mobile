/// Tipos de error reconocidos por el cliente móvil.
enum ApiFailureType {
  invalidCredentials,
  groupUnavailable,
  validation,
  rateLimited,
  serviceUnavailable,
  connection,
  invalidResponse,
}

/// Error controlado producido al consumir la API.
class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final ApiFailureType type;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
