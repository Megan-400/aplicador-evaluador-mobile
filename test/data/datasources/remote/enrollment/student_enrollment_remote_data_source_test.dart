import 'dart:convert';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/data/datasources/remote/enrollment/student_enrollment_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('StudentEnrollmentRemoteDataSource', () {
    test('envía folio y nombre y convierte HTTP 201', () async {
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
              'alumno_id': 17,
              'grupo_id': 4,
              'materia': 'Historia',
              'nombre': 'Ana Pérez',
              'estado': 'inscrito',
              'modo': 'nuevo',
              'credencial_version': 1,
              'codigo_acceso': 'ABCD27',
            },
            'message': 'Perfil creado. Guarda tu código.',
          }),
          201,
        );
      });

      final dataSource = StudentEnrollmentRemoteDataSource(client: client);

      final result = await dataSource.create(
        groupFolio: 'GRUPO1',
        studentName: 'Ana Pérez',
      );

      expect(receivedUri.path, '/api/v1/grupos/unirse');

      expect(receivedBody, {'folio_codigo': 'GRUPO1', 'nombre': 'Ana Pérez'});

      expect(receivedBody.containsKey('codigo_acceso'), isFalse);

      expect(result.studentId, 17);
      expect(result.groupId, 4);
      expect(result.accessCode, 'ABCD27');

      dataSource.close();
    });

    test('convierte HTTP 402 en grupo no disponible', () async {
      final dataSource = StudentEnrollmentRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'El grupo alcanzó su límite de alumnos.'}),
            402,
          );
        }),
      );

      expect(
        () => dataSource.create(groupFolio: 'GRUPO1', studentName: 'Ana Pérez'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiFailureType.groupUnavailable,
          ),
        ),
      );

      dataSource.close();
    });

    test('convierte HTTP 404 en grupo no disponible', () async {
      final dataSource = StudentEnrollmentRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Folio inválido o grupo no disponible.'}),
            404,
          );
        }),
      );

      expect(
        () => dataSource.create(groupFolio: 'GRUPO1', studentName: 'Ana Pérez'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiFailureType.groupUnavailable,
          ),
        ),
      );

      dataSource.close();
    });

    test('convierte HTTP 422 en validación', () async {
      final dataSource = StudentEnrollmentRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Revisa el folio y tu nombre.'}),
            422,
          );
        }),
      );

      expect(
        () => dataSource.create(groupFolio: 'GRUPO1', studentName: 'Ana Pérez'),
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

    test('convierte HTTP 429 en límite', () async {
      final dataSource = StudentEnrollmentRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Too Many Attempts.'}),
            429,
          );
        }),
      );

      expect(
        () => dataSource.create(groupFolio: 'GRUPO1', studentName: 'Ana Pérez'),
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

    test('rechaza HTTP 201 sin código válido', () async {
      final dataSource = StudentEnrollmentRemoteDataSource(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'data': {
                'alumno_id': 17,
                'grupo_id': 4,
                'materia': 'Historia',
                'nombre': 'Ana Pérez',
                'estado': 'inscrito',
                'modo': 'nuevo',
                'credencial_version': 1,
              },
            }),
            201,
          );
        }),
      );

      expect(
        () => dataSource.create(groupFolio: 'GRUPO1', studentName: 'Ana Pérez'),
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
