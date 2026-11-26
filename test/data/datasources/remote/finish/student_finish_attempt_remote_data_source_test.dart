import 'dart:convert';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/data/datasources/remote/finish/student_finish_attempt_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('StudentFinishAttemptRemoteDataSource', () {
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
              'intento_id': 123,
              'estado': 'finalizado',
              'fecha_entrega': '2026-11-23T18:30:00-06:00',
            },
          }),
          200,
        );
      });

      final dataSource = StudentFinishAttemptRemoteDataSource(client: client);

      final result = await dataSource.finish(sessionToken: 'token-sintetico');

      expect(receivedUri.path, '/api/v1/student/attempts/finish');

      expect(receivedBody, {'token_sesion': 'token-sintetico'});

      expect(receivedBody, hasLength(1));
      expect(result.id, 123);
      expect(result.isFinished, isTrue);

      dataSource.close();
    });

    test('acepta una confirmación idempotente', () async {
      final dataSource = StudentFinishAttemptRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'intento_id': 123,
                'estado': 'finalizado',
                'fecha_entrega': '2026-11-23T18:30:00-06:00',
              },
            }),
            200,
          );
        }),
      );

      final firstResult = await dataSource.finish(
        sessionToken: 'token-sintetico',
      );

      final repeatedResult = await dataSource.finish(
        sessionToken: 'token-sintetico',
      );

      expect(repeatedResult.id, firstResult.id);

      expect(repeatedResult.submittedAt, firstResult.submittedAt);

      dataSource.close();
    });

    test('convierte HTTP 403 en intento no disponible', () async {
      final dataSource = StudentFinishAttemptRemoteDataSource(
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
        () => dataSource.finish(sessionToken: 'token-sintetico'),
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
      final dataSource = StudentFinishAttemptRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'message': 'No fue posible entregar el examen.',
              'code': 'REQUEST_FAILED',
            }),
            422,
          );
        }),
      );

      expect(
        () => dataSource.finish(sessionToken: 'token-sintetico'),
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

    test('convierte validación 422 en error controlado', () async {
      final dataSource = StudentFinishAttemptRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'message': 'The token session field is required.',
              'errors': {
                'token_sesion': ['The token session field is required.'],
              },
            }),
            422,
          );
        }),
      );

      expect(
        () => dataSource.finish(sessionToken: 'token-sintetico'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiFailureType.validation,
          ),
        ),
      );

      dataSource.close();
    });

    test('convierte HTTP 429 en límite de solicitudes', () async {
      final dataSource = StudentFinishAttemptRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Too Many Attempts.'}),
            429,
          );
        }),
      );

      expect(
        () => dataSource.finish(sessionToken: 'token-sintetico'),
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
      final dataSource = StudentFinishAttemptRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'intento_id': 123,
                'estado': 'en_progreso',
                'fecha_entrega': '2026-11-23T18:30:00-06:00',
              },
            }),
            200,
          );
        }),
      );

      expect(
        () => dataSource.finish(sessionToken: 'token-sintetico'),
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
