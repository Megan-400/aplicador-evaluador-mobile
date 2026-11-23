import 'package:aplicador_evaluador_mobile/data/models/questions/student_exam_questions_model.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentExamQuestionsModel', () {
    test('convierte la respuesta completa del intento', () {
      final result = StudentExamQuestionsModel.fromJson({
        'data': {
          'nombre': 'Evaluación de programación',
          'preguntas': [
            {
              'examen_pregunta_id': 1,
              'apartado_id': 10,
              'tipo': 'abierta',
              'enunciado': 'Define una variable.',
              'opciones': null,
              'tiempo_segundos': 60,
            },
            {
              'examen_pregunta_id': 2,
              'apartado_id': 20,
              'tipo': 'opcion_multiple',
              'enunciado': 'Selecciona una opción.',
              'opciones': ['Primera opción', 'Segunda opción'],
              'tiempo_segundos': 90,
            },
            {
              'examen_pregunta_id': 3,
              'apartado_id': 30,
              'tipo': 'relacion_columnas',
              'enunciado': 'Relaciona los elementos.',
              'opciones': [
                {'izquierda': 'a | b', 'derecha': 'Operador OR'},
                {'izquierda': 'a & b', 'derecha': 'Operador AND'},
              ],
              'tiempo_segundos': 120,
            },
            {
              'examen_pregunta_id': 4,
              'apartado_id': 40,
              'tipo': 'programacion',
              'enunciado': 'Escribe un programa.',
              'opciones': null,
              'tiempo_segundos': 300,
            },
          ],
          'respuestas': {
            '1': 'Una respuesta abierta.',
            '2': 'Segunda opción',
            '4': 'print("México");\n// Código guardado',
          },
        },
      });

      expect(result.examName, 'Evaluación de programación');

      expect(result.questions, hasLength(4));

      expect(result.questions[0].type, StudentQuestionType.open);

      expect(result.questions[1].type, StudentQuestionType.multipleChoice);

      expect(result.questions[1].options, hasLength(2));

      expect(result.questions[1].options[0].value, 'A');

      expect(result.questions[1].options[0].label, 'Primera opción');

      expect(result.questions[1].options[1].value, 'B');

      expect(result.questions[1].options[1].label, 'Segunda opción');

      expect(result.questions[2].type, StudentQuestionType.matching);

      expect(result.questions[2].matchingPairs, hasLength(2));

      expect(result.questions[3].type, StudentQuestionType.programming);

      expect(result.questions[3].isProgramming, isTrue);

      expect(result.savedAnswers[1], 'Una respuesta abierta.');

      expect(result.savedAnswers[2], 'Segunda opción');

      expect(result.savedAnswers[4], 'print("México");\n// Código guardado');
    });

    test('acepta respuestas guardadas vacías', () {
      final result = StudentExamQuestionsModel.fromJson({
        'data': {
          'nombre': 'Examen',
          'preguntas': <Object>[],
          'respuestas': <String, dynamic>{},
        },
      });

      expect(result.examName, 'Examen');
      expect(result.questions, isEmpty);
      expect(result.savedAnswers, isEmpty);
    });

    test('acepta respuestas guardadas ausentes', () {
      final result = StudentExamQuestionsModel.fromJson({
        'data': {'nombre': 'Examen', 'preguntas': <Object>[]},
      });

      expect(result.questions, isEmpty);
      expect(result.savedAnswers, isEmpty);
    });

    test('acepta identificadores representados como texto', () {
      final result = StudentExamQuestionsModel.fromJson({
        'data': {
          'nombre': 'Examen',
          'preguntas': [
            {
              'examen_pregunta_id': '1',
              'apartado_id': '10',
              'tipo': 'abierta',
              'enunciado': 'Define una variable.',
              'opciones': null,
              'tiempo_segundos': '60',
            },
          ],
          'respuestas': {'1': 'Respuesta guardada.'},
        },
      });

      expect(result.questions.single.id, 1);
      expect(result.questions.single.sectionId, 10);
      expect(result.questions.single.timeSeconds, 60);

      expect(result.savedAnswers[1], 'Respuesta guardada.');
    });

    test('convierte opciones recibidas como mapa', () {
      final result = StudentExamQuestionsModel.fromJson({
        'data': {
          'nombre': 'Examen',
          'preguntas': [
            {
              'examen_pregunta_id': 2,
              'apartado_id': 20,
              'tipo': 'opcion_multiple',
              'enunciado': 'Selecciona una opción.',
              'opciones': {'A': 'Uno', 'B': 'Dos'},
              'tiempo_segundos': 60,
            },
          ],
          'respuestas': {'2': 'B'},
        },
      });

      final options = result.questions.single.options;

      expect(options, hasLength(2));

      expect(options[0].value, 'A');
      expect(options[0].label, 'Uno');

      expect(options[1].value, 'B');
      expect(options[1].label, 'Dos');

      expect(result.savedAnswers[2], 'B');
    });

    test('preserva código con Unicode y saltos de línea', () {
      const sourceCode =
          'print("México");\n'
          '// Código guardado sin cambios';

      final result = StudentExamQuestionsModel.fromJson({
        'data': {
          'nombre': 'Examen',
          'preguntas': [
            {
              'examen_pregunta_id': 3,
              'apartado_id': 30,
              'tipo': 'programacion',
              'enunciado': 'Escribe código.',
              'opciones': null,
              'tiempo_segundos': 120,
            },
          ],
          'respuestas': {'3': sourceCode},
        },
      });

      expect(result.questions.single.type, StudentQuestionType.programming);

      expect(result.savedAnswers[3], sourceCode);
    });

    test('rechaza una respuesta sin data', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza una respuesta sin preguntas', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({
          'data': {'nombre': 'Examen', 'respuestas': <String, dynamic>{}},
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza un tipo desconocido', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({
          'data': {
            'nombre': 'Examen',
            'preguntas': [
              {
                'examen_pregunta_id': 1,
                'apartado_id': 10,
                'tipo': 'verdadero_falso',
                'enunciado': 'Selecciona.',
                'opciones': ['Verdadero', 'Falso'],
                'tiempo_segundos': 60,
              },
            ],
            'respuestas': <String, dynamic>{},
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('verdadero_falso'),
          ),
        ),
      );
    });

    test('rechaza una opción múltiple sin opciones', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({
          'data': {
            'nombre': 'Examen',
            'preguntas': [
              {
                'examen_pregunta_id': 2,
                'apartado_id': 20,
                'tipo': 'opcion_multiple',
                'enunciado': 'Selecciona.',
                'opciones': <Object>[],
                'tiempo_segundos': 60,
              },
            ],
            'respuestas': <String, dynamic>{},
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza una relación sin pares', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({
          'data': {
            'nombre': 'Examen',
            'preguntas': [
              {
                'examen_pregunta_id': 3,
                'apartado_id': 30,
                'tipo': 'relacion_columnas',
                'enunciado': 'Relaciona.',
                'opciones': null,
                'tiempo_segundos': 60,
              },
            ],
            'respuestas': <String, dynamic>{},
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza un identificador de pregunta inválido', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({
          'data': {
            'nombre': 'Examen',
            'preguntas': [
              {
                'examen_pregunta_id': 0,
                'apartado_id': 10,
                'tipo': 'abierta',
                'enunciado': 'Define una variable.',
                'opciones': null,
                'tiempo_segundos': 60,
              },
            ],
            'respuestas': <String, dynamic>{},
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza un tiempo negativo', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({
          'data': {
            'nombre': 'Examen',
            'preguntas': [
              {
                'examen_pregunta_id': 1,
                'apartado_id': 10,
                'tipo': 'abierta',
                'enunciado': 'Define una variable.',
                'opciones': null,
                'tiempo_segundos': -1,
              },
            ],
            'respuestas': <String, dynamic>{},
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza respuestas con identificadores inválidos', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({
          'data': {
            'nombre': 'Examen',
            'preguntas': <Object>[],
            'respuestas': {'pregunta-invalida': 'Respuesta.'},
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza respuestas con estructura inválida', () {
      expect(
        () => StudentExamQuestionsModel.fromJson({
          'data': {
            'nombre': 'Examen',
            'preguntas': <Object>[],
            'respuestas': ['Respuesta inválida'],
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('asigna claves estables a opciones recibidas como lista', () {
      final result = StudentExamQuestionsModel.fromJson({
        'data': {
          'nombre': 'Examen',
          'preguntas': [
            {
              'examen_pregunta_id': 2,
              'apartado_id': 20,
              'tipo': 'opcion_multiple',
              'enunciado': 'Selecciona una opción.',
              'opciones': [
                'Primera opción',
                'Segunda opción',
                'Tercera opción',
              ],
              'tiempo_segundos': 60,
            },
          ],
          'respuestas': <String, dynamic>{},
        },
      });

      final options = result.questions.single.options;

      expect(options.map((option) => option.value).toList(), ['A', 'B', 'C']);

      expect(options.map((option) => option.label).toList(), [
        'Primera opción',
        'Segunda opción',
        'Tercera opción',
      ]);
    });
  });
}
