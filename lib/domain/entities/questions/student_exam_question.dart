import 'student_matching_pair.dart';
import 'student_question_option.dart';
import 'student_question_type.dart';

/// Pregunta perteneciente a un intento de examen.
class StudentExamQuestion {
  const StudentExamQuestion({
    required this.id,
    required this.sectionId,
    required this.type,
    required this.prompt,
    required this.timeSeconds,
    this.options = const [],
    this.matchingPairs = const [],
  });

  /// Identificador `examen_pregunta_id` utilizado para guardar respuestas.
  final int id;

  /// Identificador del apartado al que pertenece la pregunta.
  final int sectionId;

  /// Tipo de control que debe mostrarse al alumno.
  final StudentQuestionType type;

  /// Enunciado visible de la pregunta.
  final String prompt;

  /// Tiempo asignado a la pregunta por el backend.
  final int timeSeconds;

  /// Opciones disponibles para una pregunta de opción múltiple.
  ///
  /// [StudentQuestionOption.value] es el valor que debe enviarse al backend,
  /// por ejemplo `A` o `B`.
  ///
  /// [StudentQuestionOption.label] es el texto mostrado al alumno.
  final List<StudentQuestionOption> options;

  /// Pares disponibles para una pregunta de relación de columnas.
  final List<StudentMatchingPair> matchingPairs;

  bool get isOpen => type == StudentQuestionType.open;

  bool get isMultipleChoice {
    return type == StudentQuestionType.multipleChoice;
  }

  bool get isMatching {
    return type == StudentQuestionType.matching;
  }

  bool get isProgramming {
    return type == StudentQuestionType.programming;
  }

  int get timeMinutes {
    if (timeSeconds <= 0) {
      return 0;
    }

    return (timeSeconds / 60).ceil();
  }
}
