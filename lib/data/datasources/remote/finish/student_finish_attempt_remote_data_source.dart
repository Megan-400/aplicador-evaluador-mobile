import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../domain/entities/finish/student_finished_attempt.dart';
import '../../../models/finish/student_finished_attempt_model.dart';

/// Finaliza un intento mediante la API del alumno.
class StudentFinishAttemptRemoteDataSource {
  StudentFinishAttemptRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<StudentFinishedAttempt> finish({required String sessionToken}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/student/attempts/finish'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'token_sesion': sessionToken}),
          )
          .timeout(ApiConfig.timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200) {
        return StudentFinishedAttemptModel.fromJson(body);
      }

      throw _exceptionFor(response.statusCode, body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'El servicio tardó demasiado en confirmar la entrega.',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'No fue posible entregar el examen. Revisa tu conexión.',
      );
    } on FormatException {
      throw const ApiException(
        type: ApiFailureType.invalidResponse,
        message: 'La confirmación de entrega no tiene un formato válido.',
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
    final code = body['code']?.toString();
    final message = body['message']?.toString();

    return switch ((statusCode, code)) {
      (403, 'EXAM_UNAVAILABLE') => ApiException(
        type: ApiFailureType.examUnavailable,
        statusCode: 403,
        message: message ?? 'El intento ya no está disponible.',
      ),
      (422, 'REQUEST_FAILED') => ApiException(
        type: ApiFailureType.requestFailed,
        statusCode: 422,
        message: message ?? 'No fue posible entregar el examen.',
      ),
      (422, _) => const ApiException(
        type: ApiFailureType.validation,
        statusCode: 422,
        message: 'La sesión del intento no es válida.',
      ),
      (429, _) => const ApiException(
        type: ApiFailureType.rateLimited,
        statusCode: 429,
        message: 'Espera un momento antes de volver a intentarlo.',
      ),
      _ => ApiException(
        type: ApiFailureType.serviceUnavailable,
        statusCode: statusCode,
        message: message ?? 'El servicio de entrega no está disponible.',
      ),
    };
  }

  void close() {
    _client.close();
  }
}
