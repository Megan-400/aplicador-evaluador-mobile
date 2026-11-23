import '../../../domain/entities/questions/student_exam_question.dart';
import '../../../domain/entities/questions/student_exam_questions.dart';
import '../../../domain/entities/questions/student_matching_pair.dart';
import '../../../domain/entities/questions/student_question_type.dart';
import '../../../domain/entities/questions/student_question_option.dart';

/// Convierte la respuesta del endpoint de preguntas a entidades de dominio.
/// La respuesta contiene:
/// - nombre del examen;
/// - preguntas del intento;
/// - respuestas guardadas del intento actual.
abstract final class StudentExamQuestionsModel {
  static StudentExamQuestions fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is! Map) {
      throw const FormatException(
        'La respuesta no contiene los datos de las preguntas.',
      );
    }

    final dataMap = Map<String, dynamic>.from(data);

    final questionsValue = dataMap['preguntas'];

    if (questionsValue is! List) {
      throw const FormatException(
        'La respuesta no contiene una lista de preguntas válida.',
      );
    }

    final questions = questionsValue
        .map((value) {
          if (value is! Map) {
            throw const FormatException(
              'Una pregunta no tiene un formato válido.',
            );
          }

          return _question(Map<String, dynamic>.from(value));
        })
        .toList(growable: false);

    return StudentExamQuestions(
      examName: _optionalString(dataMap['nombre']),
      questions: List.unmodifiable(questions),
      savedAnswers: _savedAnswers(dataMap['respuestas']),
    );
  }

  static StudentExamQuestion _question(Map<String, dynamic> json) {
    final id = _requiredPositiveInt(
      json['examen_pregunta_id'],
      field: 'examen_pregunta_id',
    );

    final sectionId = _requiredPositiveInt(
      json['apartado_id'],
      field: 'apartado_id',
    );

    final type = _questionType(_requiredString(json['tipo'], field: 'tipo'));

    final prompt = _requiredString(json['enunciado'], field: 'enunciado');

    final timeSeconds = _requiredNonNegativeInt(
      json['tiempo_segundos'],
      field: 'tiempo_segundos',
    );

    return switch (type) {
      StudentQuestionType.open => StudentExamQuestion(
        id: id,
        sectionId: sectionId,
        type: type,
        prompt: prompt,
        timeSeconds: timeSeconds,
      ),
      StudentQuestionType.multipleChoice => StudentExamQuestion(
        id: id,
        sectionId: sectionId,
        type: type,
        prompt: prompt,
        timeSeconds: timeSeconds,
        options: _multipleChoiceOptions(json['opciones']),
      ),
      StudentQuestionType.matching => StudentExamQuestion(
        id: id,
        sectionId: sectionId,
        type: type,
        prompt: prompt,
        timeSeconds: timeSeconds,
        matchingPairs: _matchingPairs(json['opciones']),
      ),
      StudentQuestionType.programming => StudentExamQuestion(
        id: id,
        sectionId: sectionId,
        type: type,
        prompt: prompt,
        timeSeconds: timeSeconds,
      ),
    };
  }

  static StudentQuestionType _questionType(String value) {
    return switch (value.trim().toLowerCase()) {
      'abierta' => StudentQuestionType.open,
      'opcion_multiple' => StudentQuestionType.multipleChoice,
      'relacion_columnas' => StudentQuestionType.matching,
      'programacion' => StudentQuestionType.programming,
      _ => throw FormatException('Tipo de pregunta desconocido: $value'),
    };
  }

  /// Convierte las opciones de selección.
  ///
  /// El backend puede entregar:
  ///
  /// Lista:
  /// `["Primera opción", "Segunda opción"]`
  ///
  /// O mapa:
  /// `{"A": "Primera opción", "B": "Segunda opción"}`
  ///
  /// En esta historia se presentan los textos visibles del mapa.
  static List<StudentQuestionOption> _multipleChoiceOptions(Object? value) {
    if (value is Map) {
      if (value.isEmpty) {
        throw const FormatException(
          'La pregunta de opción múltiple no contiene '
          'opciones válidas.',
        );
      }

      final options = <StudentQuestionOption>[];

      for (final entry in value.entries) {
        final optionValue = _requiredString(
          entry.key,
          field: 'valor de opción',
        );

        final optionLabel = _requiredString(
          entry.value,
          field: 'etiqueta de opción',
        );

        options.add(
          StudentQuestionOption(value: optionValue, label: optionLabel),
        );
      }

      return List.unmodifiable(options);
    }

    if (value is List) {
      if (value.isEmpty) {
        throw const FormatException(
          'La pregunta de opción múltiple no contiene '
          'opciones válidas.',
        );
      }

      if (value.length > 26) {
        throw const FormatException(
          'La pregunta de opción múltiple contiene '
          'demasiadas opciones.',
        );
      }

      return List.unmodifiable(
        value.asMap().entries.map((entry) {
          final optionLabel = _requiredString(
            entry.value,
            field: 'etiqueta de opción',
          );

          return StudentQuestionOption(
            value: _alphabeticOptionValue(entry.key),
            label: optionLabel,
          );
        }),
      );
    }

    throw const FormatException(
      'La pregunta de opción múltiple no contiene '
      'opciones válidas.',
    );
  }

  static String _alphabeticOptionValue(int index) {
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }

  static List<StudentMatchingPair> _matchingPairs(Object? value) {
    if (value is! List || value.isEmpty) {
      throw const FormatException(
        'La relación de columnas no contiene pares válidos.',
      );
    }

    return List.unmodifiable(
      value.map((pair) {
        if (pair is! Map) {
          throw const FormatException(
            'Un par de relación no tiene un formato válido.',
          );
        }

        final map = Map<String, dynamic>.from(pair);

        return StudentMatchingPair(
          left: _requiredString(map['izquierda'], field: 'izquierda'),
          right: _requiredString(map['derecha'], field: 'derecha'),
        );
      }),
    );
  }

  static Map<int, String> _savedAnswers(Object? value) {
    if (value == null) {
      return const {};
    }

    if (value is! Map) {
      throw const FormatException(
        'Las respuestas guardadas no tienen un formato válido.',
      );
    }

    final answers = <int, String>{};

    for (final entry in value.entries) {
      final questionId = int.tryParse(entry.key.toString());

      if (questionId == null || questionId <= 0) {
        throw const FormatException(
          'Una respuesta contiene un identificador inválido.',
        );
      }

      final answer = entry.value?.toString() ?? '';

      if (answer.isNotEmpty) {
        answers[questionId] = answer;
      }
    }

    return Map.unmodifiable(answers);
  }

  static String _requiredString(Object? value, {required String field}) {
    final result = value?.toString().trim() ?? '';

    if (result.isEmpty) {
      throw FormatException('El campo $field está vacío.');
    }

    return result;
  }

  static String _optionalString(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static int _requiredPositiveInt(Object? value, {required String field}) {
    final result = _parseInt(value);

    if (result <= 0) {
      throw FormatException('El campo $field no es válido.');
    }

    return result;
  }

  static int _requiredNonNegativeInt(Object? value, {required String field}) {
    final result = _parseInt(value);

    if (result < 0) {
      throw FormatException('El campo $field no es válido.');
    }

    return result;
  }

  static int _parseInt(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? -1;
  }
}
