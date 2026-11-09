import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Convierte un error de red en un mensaje comprensible para el usuario.
AppException appExceptionFromDio(DioException e) {
  final codigo = e.response?.statusCode;

  final mensaje = switch (codigo) {
    401 => 'Tu sesión expiró. Inicia sesión de nuevo.',
    403 => 'No tienes permiso para ver esta información.',
    404 => 'No se encontró la información solicitada.',
    429 => 'Demasiadas solicitudes. Espera un momento e inténtalo de nuevo.',
    503 => 'El servicio no está disponible. Inténtalo más tarde.',
    null => 'No se pudo conectar. Revisa tu internet e inténtalo de nuevo.',
    _ => 'No se pudo completar la operación. Inténtalo de nuevo.',
  };

  return AppException(mensaje, statusCode: codigo);
}