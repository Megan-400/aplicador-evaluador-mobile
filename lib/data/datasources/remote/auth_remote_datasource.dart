import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../models/auth_session_model.dart';

/// Llamadas HTTP de autenticación contra la API.
class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final respuesta = await ApiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthSessionModel.fromLoginJson(
        respuesta.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final codigo = e.response?.statusCode;
      throw AppException(_mensajeDeError(codigo), statusCode: codigo);
    } on TypeError {
      throw const AppException('La respuesta del servidor no es válida.');
    }
  }

  String _mensajeDeError(int? codigo) {
    return switch (codigo) {
      401 || 422 => 'Correo o contraseña incorrectos.',
      403 => 'Tu cuenta no está registrada como docente.',
      429 => 'Demasiados intentos. Espera un minuto e inténtalo de nuevo.',
      503 => 'El servicio no está disponible. Inténtalo más tarde.',
      null => 'No se pudo conectar. Revisa tu internet e inténtalo de nuevo.',
      _ => 'No se pudo iniciar sesión. Inténtalo de nuevo.',
    };
  }
}