import 'package:aplicador_evaluador_mobile/data/models/enrollment/student_enrollment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentEnrollmentModel', () {
    test('convierte una inscripción nueva válida', () {
      final result = StudentEnrollmentModel.fromJson({
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
        'message': 'Perfil creado. Guarda tu código de acceso.',
      });

      expect(result.studentId, 17);
      expect(result.groupId, 4);
      expect(result.subject, 'Historia');
      expect(result.studentName, 'Ana Pérez');
      expect(result.status, 'inscrito');
      expect(result.mode, 'nuevo');
      expect(result.credentialVersion, 1);
      expect(result.accessCode, 'ABCD27');
      expect(result.isNewEnrollment, isTrue);
      expect(result.isEnrolled, isTrue);
    });

    test('normaliza el estado, modo y código', () {
      final result = StudentEnrollmentModel.fromJson({
        'data': {
          'alumno_id': '17',
          'grupo_id': '4',
          'materia': ' Historia ',
          'nombre': ' Ana Pérez ',
          'estado': ' INSCRITO ',
          'modo': ' NUEVO ',
          'credencial_version': '1',
          'codigo_acceso': 'abcd27',
        },
      });

      expect(result.subject, 'Historia');
      expect(result.studentName, 'Ana Pérez');
      expect(result.status, 'inscrito');
      expect(result.mode, 'nuevo');
      expect(result.accessCode, 'ABCD27');
    });

    test('rechaza una respuesta sin data', () {
      expect(
        () => StudentEnrollmentModel.fromJson(<String, dynamic>{}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza un código personal inválido', () {
      expect(
        () => StudentEnrollmentModel.fromJson({
          'data': {
            'alumno_id': 17,
            'grupo_id': 4,
            'materia': 'Historia',
            'nombre': 'Ana Pérez',
            'estado': 'inscrito',
            'modo': 'nuevo',
            'credencial_version': 1,
            'codigo_acceso': '123456',
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('código personal'),
          ),
        ),
      );
    });

    test('rechaza una respuesta de reingreso', () {
      expect(
        () => StudentEnrollmentModel.fromJson({
          'data': {
            'alumno_id': 17,
            'grupo_id': 4,
            'materia': 'Historia',
            'nombre': 'Ana Pérez',
            'estado': 'inscrito',
            'modo': 'reingreso',
            'credencial_version': 1,
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza identificadores no positivos', () {
      expect(
        () => StudentEnrollmentModel.fromJson({
          'data': {
            'alumno_id': 0,
            'grupo_id': 4,
            'materia': 'Historia',
            'nombre': 'Ana Pérez',
            'estado': 'inscrito',
            'modo': 'nuevo',
            'credencial_version': 1,
            'codigo_acceso': 'ABCD27',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza una credencial sin versión válida', () {
      expect(
        () => StudentEnrollmentModel.fromJson({
          'data': {
            'alumno_id': 17,
            'grupo_id': 4,
            'materia': 'Historia',
            'nombre': 'Ana Pérez',
            'estado': 'inscrito',
            'modo': 'nuevo',
            'credencial_version': 0,
            'codigo_acceso': 'ABCD27',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
