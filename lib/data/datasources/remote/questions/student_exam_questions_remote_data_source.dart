import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../domain/entities/questions/student_exam_questions.dart';
import '../../../models/questions/student_exam_questions_model.dart';

/// Consume las preguntas y respuestas guardadas de un intento activo.
class StudentExamQuestionsRemoteDataSource {
  StudentExamQuestionsRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<StudentExamQuestions> load({required String sessionToken}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/student/attempts/questions'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'token_sesion': sessionToken}),
          )
          .timeout(ApiConfig.timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200) {
        return StudentExamQuestionsModel.fromJson(body);
      }

      throw _exceptionFor(response.statusCode, body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'El servicio tardó demasiado en cargar las preguntas.',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'No fue posible conectarse. Revisa tu conexión.',
      );
    } on FormatException {
      throw const ApiException(
        type: ApiFailureType.invalidResponse,
        message: 'La respuesta de preguntas no tiene un formato válido.',
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
    final serverMessage = body['message']?.toString();

    return switch ((statusCode, code)) {
      (403, 'EXAM_UNAVAILABLE') => ApiException(
        type: ApiFailureType.examUnavailable,
        statusCode: 403,
        message: serverMessage ?? 'La sesión del examen ya no está disponible.',
      ),
      (422, 'REQUEST_FAILED') => ApiException(
        type: ApiFailureType.requestFailed,
        statusCode: 422,
        message: serverMessage ?? 'No se pudieron cargar las preguntas.',
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
      (503, 'MIGRATION_REQUIRED') => const ApiException(
        type: ApiFailureType.migrationRequired,
        statusCode: 503,
        message: 'La consulta de preguntas todavía no está habilitada.',
      ),
      _ => ApiException(
        type: ApiFailureType.serviceUnavailable,
        statusCode: statusCode,
        message:
            serverMessage ?? 'El servicio de preguntas no está disponible.',
      ),
    };
  }

  void close() {
    _client.close();
  }
}
