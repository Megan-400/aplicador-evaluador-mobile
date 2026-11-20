/// Configuración de la API utilizada por la aplicación.
abstract final class ApiConfig {
  static const String baseUrl =
      'https://bigbitbyte-staging-api.onrender.com/api/v1';

  static const Duration timeout = Duration(seconds: 30);
}
