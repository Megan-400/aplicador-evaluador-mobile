import 'package:aplicador_evaluador_mobile/data/models/finish/student_finished_attempt_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentFinishedAttemptModel', () {
    test('convierte una confirmación de entrega válida', () {
      final result = StudentFinishedAttemptModel.fromJson({
        'data': {
          'intento_id': 123,
          'estado': 'finalizado',
          'fecha_entrega': '2026-11-23T18:30:00-06:00',
        },
      });

      expect(result.id, 123);
      expect(result.status, 'finalizado');
      expect(result.isFinished, isTrue);

      expect(result.submittedAt, DateTime.parse('2026-11-23T18:30:00-06:00'));
    });

    test('acepta intento_id representado como texto', () {
      final result = StudentFinishedAttemptModel.fromJson({
        'data': {
          'intento_id': '123',
          'estado': 'finalizado',
          'fecha_entrega': '2026-11-23T18:30:00-06:00',
        },
      });

      expect(result.id, 123);
    });

    test('normaliza el estado antes de validarlo', () {
      final result = StudentFinishedAttemptModel.fromJson({
        'data': {
          'intento_id': 123,
          'estado': ' FINALIZADO ',
          'fecha_entrega': '2026-11-23T18:30:00-06:00',
        },
      });

      expect(result.status, 'finalizado');
      expect(result.isFinished, isTrue);
    });

    test('preserva la fecha original en una respuesta idempotente', () {
      const originalDate = '2026-11-23T18:30:00-06:00';

      final firstResult = StudentFinishedAttemptModel.fromJson({
        'data': {
          'intento_id': 123,
          'estado': 'finalizado',
          'fecha_entrega': originalDate,
        },
      });

      final repeatedResult = StudentFinishedAttemptModel.fromJson({
        'data': {
          'intento_id': 123,
          'estado': 'finalizado',
          'fecha_entrega': originalDate,
        },
      });

      expect(repeatedResult.id, firstResult.id);

      expect(repeatedResult.submittedAt, firstResult.submittedAt);
    });

    test('rechaza una respuesta sin data', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson(<String, dynamic>{}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza un identificador ausente', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson({
          'data': {
            'estado': 'finalizado',
            'fecha_entrega': '2026-11-23T18:30:00-06:00',
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('identificador'),
          ),
        ),
      );
    });

    test('rechaza un identificador no positivo', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson({
          'data': {
            'intento_id': 0,
            'estado': 'finalizado',
            'fecha_entrega': '2026-11-23T18:30:00-06:00',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza un identificador no numérico', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson({
          'data': {
            'intento_id': 'intento-invalido',
            'estado': 'finalizado',
            'fecha_entrega': '2026-11-23T18:30:00-06:00',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza un estado distinto de finalizado', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson({
          'data': {
            'intento_id': 123,
            'estado': 'en_progreso',
            'fecha_entrega': '2026-11-23T18:30:00-06:00',
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('finalizado'),
          ),
        ),
      );
    });

    test('rechaza un estado ausente', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson({
          'data': {
            'intento_id': 123,
            'fecha_entrega': '2026-11-23T18:30:00-06:00',
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza una fecha de entrega inválida', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson({
          'data': {
            'intento_id': 123,
            'estado': 'finalizado',
            'fecha_entrega': 'fecha-invalida',
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('fecha'),
          ),
        ),
      );
    });

    test('rechaza una fecha de entrega ausente', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson({
          'data': {'intento_id': 123, 'estado': 'finalizado'},
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza data con un tipo incorrecto', () {
      expect(
        () => StudentFinishedAttemptModel.fromJson({
          'data': 'contenido-inválido',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
