import 'package:aplicador_evaluador_mobile/data/models/attempts/student_exam_attempt_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentExamAttemptModel', () {
    test('convierte una respuesta válida', () {
      final attempt = StudentExamAttemptModel.fromJson({
        'data': {
          'intento_id': 25,
          'token_sesion': '3e58ddc7-1e5a-42d9-a476-d31ab63293e5',
          'fecha_inicio': '2026-11-20T17:30:00-06:00',
        },
      });

      expect(attempt.id, 25);
      expect(attempt.sessionToken, isNotEmpty);
      expect(attempt.startedAt.year, 2026);
    });

    test('acepta un identificador representado como texto', () {
      final attempt = StudentExamAttemptModel.fromJson({
        'data': {
          'intento_id': '25',
          'token_sesion': '3e58ddc7-1e5a-42d9-a476-d31ab63293e5',
          'fecha_inicio': '2026-11-20T17:30:00-06:00',
        },
      });

      expect(attempt.id, 25);
    });

    test('rechaza una respuesta sin token de sesión', () {
      expect(
        () => StudentExamAttemptModel.fromJson({
          'data': {
            'intento_id': 25,
            'fecha_inicio': '2026-11-20T17:30:00-06:00',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza una fecha de inicio inválida', () {
      expect(
        () => StudentExamAttemptModel.fromJson({
          'data': {
            'intento_id': 25,
            'token_sesion': 'token-de-prueba',
            'fecha_inicio': 'fecha-invalida',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
