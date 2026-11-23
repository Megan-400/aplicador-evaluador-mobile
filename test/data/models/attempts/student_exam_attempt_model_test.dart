import 'package:aplicador_evaluador_mobile/data/models/attempts/student_exam_attempt_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentExamAttemptModel', () {
    test('convierte un intento nuevo', () {
      final attempt = StudentExamAttemptModel.fromJson({
        'data': {
          'examen_id': 25,
          'intento_id': 123,
          'token_sesion': 'token-sintetico-de-prueba',
          'fecha_inicio': '2026-11-20T18:30:00-06:00',
          'reanudado': false,
        },
      });

      expect(attempt.id, 123);
      expect(attempt.examId, 25);
      expect(attempt.sessionToken, isNotEmpty);
      expect(attempt.startedAt.year, 2026);
      expect(attempt.wasResumed, isFalse);
    });

    test('convierte un intento reanudado', () {
      final attempt = StudentExamAttemptModel.fromJson({
        'data': {
          'examen_id': 25,
          'intento_id': 123,
          'token_sesion': 'token-sintetico-de-prueba',
          'fecha_inicio': '2026-11-20T18:30:00-06:00',
          'reanudado': true,
        },
      });

      expect(attempt.id, 123);
      expect(attempt.examId, 25);
      expect(attempt.wasResumed, isTrue);
    });

    test('acepta identificadores representados como texto', () {
      final attempt = StudentExamAttemptModel.fromJson({
        'data': {
          'examen_id': '25',
          'intento_id': '123',
          'token_sesion': 'token-sintetico-de-prueba',
          'fecha_inicio': '2026-11-20T18:30:00-06:00',
          'reanudado': false,
        },
      });

      expect(attempt.id, 123);
      expect(attempt.examId, 25);
    });

    test('rechaza una respuesta sin token', () {
      expect(
        () => StudentExamAttemptModel.fromJson({
          'data': {
            'examen_id': 25,
            'intento_id': 123,
            'fecha_inicio': '2026-11-20T18:30:00-06:00',
            'reanudado': false,
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza una fecha inválida', () {
      expect(
        () => StudentExamAttemptModel.fromJson({
          'data': {
            'examen_id': 25,
            'intento_id': 123,
            'token_sesion': 'token-sintetico-de-prueba',
            'fecha_inicio': 'fecha-invalida',
            'reanudado': false,
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza una respuesta sin reanudado', () {
      expect(
        () => StudentExamAttemptModel.fromJson({
          'data': {
            'examen_id': 25,
            'intento_id': 123,
            'token_sesion': 'token-sintetico-de-prueba',
            'fecha_inicio': '2026-11-20T18:30:00-06:00',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza un identificador de examen inválido', () {
      expect(
        () => StudentExamAttemptModel.fromJson({
          'data': {
            'examen_id': 0,
            'intento_id': 123,
            'token_sesion': 'token-sintetico-de-prueba',
            'fecha_inicio': '2026-11-20T18:30:00-06:00',
            'reanudado': false,
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
