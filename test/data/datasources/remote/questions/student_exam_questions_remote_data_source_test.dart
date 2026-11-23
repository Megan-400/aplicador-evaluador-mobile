import 'dart:convert';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/data/datasources/remote/questions/student_exam_questions_remote_data_source.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('StudentExamQuestionsRemoteDataSource', () {
    test('envía únicamente token_sesion y convierte HTTP 200', () async {
      late Uri receivedUri;
      late Map<String, dynamic> receivedBody;

      final client = MockClient((request) async {
        receivedUri = request.url;
        receivedBody = Map<String, dynamic>.from(
          jsonDecode(request.body) as Map,
        );

        return http.Response(
          jsonEncode({
            'data': {
              'nombre': 'Examen de prueba',
              'preguntas': [
                {
                  'examen_pregunta_id': 1,
                  'apartado_id': 10,
                  'tipo': 'abierta',
                  'enunciado': 'Pregunta sintética.',
                  'opciones': null,
                  'tiempo_segundos': 60,
                },
              ],
              'respuestas': <String, dynamic>{},
            },
          }),
          200,
        );
      });

      final dataSource = StudentExamQuestionsRemoteDataSource(client: client);

      final result = await dataSource.load(sessionToken: 'token-sintetico');

      expect(receivedUri.path, '/api/v1/student/attempts/questions');
      expect(receivedBody, {'token_sesion': 'token-sintetico'});
      expect(receivedBody, hasLength(1));
      expect(result.questions, hasLength(1));
      expect(result.savedAnswers, isEmpty);
      expect(result.questions.single.type, StudentQuestionType.open);

      dataSource.close();
    });

    test('convierte HTTP 403 en examen no disponible', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'Solicitud no autorizada o examen no disponible.',
            'code': 'EXAM_UNAVAILABLE',
          }),
          403,
        );
      });

      final dataSource = StudentExamQuestionsRemoteDataSource(client: client);

      expect(
        () => dataSource.load(sessionToken: 'token-sintetico'),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.type,
                'type',
                ApiFailureType.examUnavailable,
              )
              .having((error) => error.statusCode, 'statusCode', 403),
        ),
      );

      dataSource.close();
    });

    test('convierte REQUEST_FAILED en error controlado', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'No se pudieron cargar las preguntas.',
            'code': 'REQUEST_FAILED',
          }),
          422,
        );
      });

      final dataSource = StudentExamQuestionsRemoteDataSource(client: client);

      expect(
        () => dataSource.load(sessionToken: 'token-sintetico'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiFailureType.requestFailed,
          ),
        ),
      );

      dataSource.close();
    });

    test('convierte HTTP 429 en límite de solicitudes', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Too Many Attempts.'}),
          429,
        );
      });

      final dataSource = StudentExamQuestionsRemoteDataSource(client: client);

      expect(
        () => dataSource.load(sessionToken: 'token-sintetico'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiFailureType.rateLimited,
          ),
        ),
      );

      dataSource.close();
    });

    test('rechaza una respuesta 200 con formato inválido', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {'preguntas': 'contenido-invalido'},
          }),
          200,
        );
      });

      final dataSource = StudentExamQuestionsRemoteDataSource(client: client);

      expect(
        () => dataSource.load(sessionToken: 'token-sintetico'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiFailureType.invalidResponse,
          ),
        ),
      );

      dataSource.close();
    });
  });
}
