import 'dart:convert';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/data/datasources/remote/answers/student_answer_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('StudentAnswerRemoteDataSource', () {
    test('envía la respuesta y convierte HTTP 200', () async {
      late Uri receivedUri;
      late Map<String, dynamic> receivedBody;

      final client = MockClient((request) async {
        receivedUri = request.url;

        receivedBody = Map<String, dynamic>.from(
          jsonDecode(request.body) as Map,
        );

        return http.Response(
          jsonEncode({
            'data': {'respuesta_id': 123},
          }),
          200,
        );
      });

      final dataSource = StudentAnswerRemoteDataSource(client: client);

      const sourceCode =
          'print("México");\n'
          '// Código guardado';

      final result = await dataSource.save(
        sessionToken: 'token-sintetico',
        questionId: 25,
        answer: sourceCode,
      );

      expect(receivedUri.path, '/api/v1/student/attempts/answers');

      expect(receivedBody, {
        'token_sesion': 'token-sintetico',
        'examen_pregunta_id': 25,
        'respuesta_texto': sourceCode,
      });

      expect(result.id, 123);
      expect(result.questionId, 25);

      dataSource.close();
    });

    test('convierte HTTP 403 en sesión no disponible', () async {
      final dataSource = StudentAnswerRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'message': 'Solicitud no autorizada o examen no disponible.',
              'code': 'EXAM_UNAVAILABLE',
            }),
            403,
          );
        }),
      );

      expect(
        () => dataSource.save(
          sessionToken: 'token-sintetico',
          questionId: 25,
          answer: 'Respuesta.',
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiFailureType.examUnavailable,
          ),
        ),
      );

      dataSource.close();
    });

    test('convierte REQUEST_FAILED en error controlado', () async {
      final dataSource = StudentAnswerRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'message': 'No fue posible guardar la respuesta.',
              'code': 'REQUEST_FAILED',
            }),
            422,
          );
        }),
      );

      expect(
        () => dataSource.save(
          sessionToken: 'token-sintetico',
          questionId: 25,
          answer: 'Respuesta.',
        ),
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
      final dataSource = StudentAnswerRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Too Many Attempts.'}),
            429,
          );
        }),
      );

      expect(
        () => dataSource.save(
          sessionToken: 'token-sintetico',
          questionId: 25,
          answer: 'Respuesta.',
        ),
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
  });
}
