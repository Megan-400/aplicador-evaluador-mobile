import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

/// Cliente HTTP único para toda la aplicación.
class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static bool _authConfigurada = false;

  /// Activa el envío del token y el aviso de sesión vencida (una sola vez).
  static void configureAuth({
    required Future<String?> Function() tokenProvider,
    VoidCallback? onUnauthorized,
  }) {
    if (_authConfigurada) {
      return;
    }

    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: tokenProvider,
        onUnauthorized: onUnauthorized,
      ),
    );
    _authConfigurada = true;
  }
}