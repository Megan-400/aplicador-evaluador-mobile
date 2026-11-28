import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../domain/entities/enrollment/student_enrollment.dart';
import '../../../models/enrollment/student_enrollment_model.dart';

/// Crea un perfil de alumno y lo inscribe en un grupo.
class StudentEnrollmentRemoteDataSource {
  StudentEnrollmentRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/grupos/unirse'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'folio_codigo': groupFolio,
              'nombre': studentName,
            }),
          )
          .timeout(ApiConfig.timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 201) {
        return StudentEnrollmentModel.fromJson(body);
      }

      throw _exceptionFor(response.statusCode, body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message:
            'El servicio tardó demasiado en crear '
            'el perfil.',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message:
            'No fue posible crear el perfil. '
            'Revisa tu conexión.',
      );
    } on FormatException catch (error) {
      throw ApiException(
        type: ApiFailureType.invalidResponse,
        message: error.message.isEmpty
            ? 'La confirmación de inscripción no '
                  'tiene un formato válido.'
            : error.message,
      );
    } on http.ClientException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'No fue posible comunicarse con el servicio.',
      );
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('La respuesta no es un objeto JSON.');
    }

    return decoded;
  }

  ApiException _exceptionFor(int statusCode, Map<String, dynamic> body) {
    final serverMessage = body['message']?.toString();

    return switch (statusCode) {
      401 => ApiException(
        type: ApiFailureType.invalidCredentials,
        statusCode: statusCode,
        message: serverMessage ?? 'No se reconoció el código personal.',
      ),
      402 => ApiException(
        type: ApiFailureType.groupUnavailable,
        statusCode: statusCode,
        message: serverMessage ?? 'El grupo alcanzó su límite de alumnos.',
      ),
      404 => ApiException(
        type: ApiFailureType.groupUnavailable,
        statusCode: statusCode,
        message: serverMessage ?? 'El folio o el grupo no están disponibles.',
      ),
      422 => ApiException(
        type: ApiFailureType.validation,
        statusCode: statusCode,
        message: serverMessage ?? 'Revisa el folio y tu nombre.',
      ),
      429 => const ApiException(
        type: ApiFailureType.rateLimited,
        statusCode: 429,
        message:
            'Se realizaron demasiados intentos. '
            'Espera un momento.',
      ),
      500 || 503 => ApiException(
        type: ApiFailureType.serviceUnavailable,
        statusCode: statusCode,
        message:
            serverMessage ??
            'No fue posible crear el perfil. '
                'Inténtalo más tarde.',
      ),
      _ => ApiException(
        type: ApiFailureType.serviceUnavailable,
        statusCode: statusCode,
        message:
            serverMessage ??
            'El servicio de inscripción no está '
                'disponible.',
      ),
    };
  }

  void close() {
    _client.close();
  }
}
