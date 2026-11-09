import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Agrega el token a cada petición y avisa cuando la sesión ya no es válida.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenProvider, this.onUnauthorized});

  final Future<String?> Function() tokenProvider;
  final VoidCallback? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final llevabaToken = err.requestOptions.headers.containsKey(
      'Authorization',
    );

    if (err.response?.statusCode == 401 && llevabaToken) {
      onUnauthorized?.call();
    }

    handler.next(err);
  }
}