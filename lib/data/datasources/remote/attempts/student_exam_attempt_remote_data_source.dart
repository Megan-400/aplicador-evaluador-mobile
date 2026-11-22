import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../domain/entities/attempts/student_exam_attempt.dart';
import '../../../models/attempts/student_exam_attempt_model.dart';

class StudentExamAttemptRemoteDataSource {
  StudentExamAttemptRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<StudentExamAttempt> start({
    required String folio,
    required String accessCode,
    required int examId,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/student/exams/$examId/start'),
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StudentExamAttemptModel.fromJson(body);
      }

      throw _exceptionFor(response.statusCode, body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'El servicio tardó demasiado en responder.',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'No fue posible conectarse. Revisa tu conexión.',
      );
    } on FormatException {
      throw const ApiException(
        type: ApiFailureType.invalidResponse,
        message: 'La respuesta de inicio no tiene un formato válido.',
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
      (401, 'INVALID_CREDENTIAL') => ApiException(
        type: ApiFailureType.invalidCredentials,
        statusCode: 401,
        message: message ?? 'El código personal no es válido.',
      ),
      (404, 'EXAM_UNAVAILABLE') => ApiException(
        type: ApiFailureType.examUnavailable,
        statusCode: 404,
        message: message ?? 'El examen no está disponible para este grupo.',
      ),
      (409, 'ATTEMPT_CLOSED') => ApiException(
        type: ApiFailureType.attemptClosed,
        statusCode: 409,
        message:
            message ?? 'Ya entregaste este examen o el intento fue anulado.',
      ),
      (503, 'MIGRATION_REQUIRED') => const ApiException(
        type: ApiFailureType.migrationRequired,
        statusCode: 503,
        message: 'El inicio de exámenes móviles aún no está habilitado.',
      ),
      (503, 'REQUEST_FAILED') => ApiException(
        type: ApiFailureType.requestFailed,
        statusCode: 503,
        message: message ?? 'No se pudo iniciar el examen. Inténtalo de nuevo.',
      ),
      (422, _) => const ApiException(
        type: ApiFailureType.validation,
        statusCode: 422,
        message: 'Revisa el folio y el código personal.',
      ),
      (429, _) => const ApiException(
        type: ApiFailureType.rateLimited,
        statusCode: 429,
        message: 'Espera un momento antes de volver a intentarlo.',
      ),
      _ => ApiException(
        type: ApiFailureType.serviceUnavailable,
        statusCode: statusCode,
        message: message ?? 'El servicio de exámenes no está disponible.',
      ),
    };
  }

  void close() {
    _client.close();
  }
}
