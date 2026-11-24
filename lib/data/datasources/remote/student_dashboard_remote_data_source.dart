import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../domain/entities/student_dashboard.dart';
import '../../models/student_dashboard_model.dart';

/// Consume el dashboard móvil del alumno.
class StudentDashboardRemoteDataSource {
  StudentDashboardRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/student/dashboard'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'folio_codigo': folio,
              'codigo_acceso': accessCode,
            }),
          )
          .timeout(ApiConfig.timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200) {
        return StudentDashboardModel.fromJson(body);
      }

      throw _exceptionFor(response.statusCode, body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message:
            'El servicio tardó demasiado en responder. '
            'Inténtalo nuevamente.',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message:
            'No fue posible conectarse. '
            'Revisa tu conexión.',
      );
    } on FormatException catch (error) {
      throw ApiException(
        type: ApiFailureType.invalidResponse,
        message: error.message.isEmpty
            ? 'La respuesta del servicio no tiene '
                  'un formato válido.'
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
      throw const FormatException(
        'La respuesta del servicio no es un objeto JSON.',
      );
    }

    return decoded;
  }

  ApiException _exceptionFor(int statusCode, Map<String, dynamic> body) {
    final serverMessage = body['message']?.toString();

    return switch (statusCode) {
      401 => ApiException(
        type: ApiFailureType.invalidCredentials,
        statusCode: statusCode,
        message: serverMessage ?? 'El código personal no es válido.',
      ),
      404 => ApiException(
        type: ApiFailureType.groupUnavailable,
        statusCode: statusCode,
        message: serverMessage ?? 'El grupo no está disponible.',
      ),
      422 => const ApiException(
        type: ApiFailureType.validation,
        statusCode: 422,
        message: 'Revisa el folio y el código personal.',
      ),
      429 => const ApiException(
        type: ApiFailureType.rateLimited,
        statusCode: 429,
        message:
            'Se realizaron demasiados intentos. '
            'Espera un momento.',
      ),
      _ => ApiException(
        type: ApiFailureType.serviceUnavailable,
        statusCode: statusCode,
        message:
            serverMessage ??
            'No se pudieron cargar tus datos. '
                'Inténtalo nuevamente.',
      ),
    };
  }

  void close() {
    _client.close();
  }
}
