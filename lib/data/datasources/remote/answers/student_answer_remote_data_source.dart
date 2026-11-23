import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../domain/entities/answers/student_saved_answer.dart';
import '../../../models/answers/student_saved_answer_model.dart';

/// Registra una respuesta perteneciente a un intento activo.
class StudentAnswerRemoteDataSource {
  StudentAnswerRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/student/attempts/answers'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'token_sesion': sessionToken,
              'examen_pregunta_id': questionId,
              'respuesta_texto': answer,
            }),
          )
          .timeout(ApiConfig.timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode == 200) {
        return StudentSavedAnswerModel.fromJson(body, questionId: questionId);
      }

      throw _exceptionFor(response.statusCode, body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'El servicio tardó demasiado en guardar la respuesta.',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'No fue posible guardar la respuesta. Revisa tu conexión.',
      );
    } on FormatException {
      throw const ApiException(
        type: ApiFailureType.invalidResponse,
        message: 'La confirmación de guardado no tiene un formato válido.',
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
        message: message ?? 'La sesión del examen ya no está disponible.',
      ),
      (422, 'REQUEST_FAILED') => ApiException(
        type: ApiFailureType.requestFailed,
        statusCode: 422,
        message: message ?? 'No fue posible guardar la respuesta.',
      ),
      (422, _) => const ApiException(
        type: ApiFailureType.validation,
        statusCode: 422,
        message: 'La respuesta no tiene un formato válido.',
      ),
      (429, _) => const ApiException(
        type: ApiFailureType.rateLimited,
        statusCode: 429,
        message: 'Espera un momento antes de volver a intentarlo.',
      ),
      _ => ApiException(
        type: ApiFailureType.serviceUnavailable,
        statusCode: statusCode,
        message: message ?? 'El servicio de respuestas no está disponible.',
      ),
    };
  }

  void close() {
    _client.close();
  }
}
