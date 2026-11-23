import 'student_matching_pair.dart';
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
  /// Debe estar vacío en preguntas abiertas o de relación de columnas.
  final List<String> options;

  /// Pares recibidos para una pregunta de relación de columnas.
  ///
  /// Debe estar vacío en preguntas abiertas o de opción múltiple.
  final List<StudentMatchingPair> matchingPairs;

  /// Indica si la pregunta permite una respuesta de texto libre.
  bool get isOpen => type == StudentQuestionType.open;

  /// Indica si la pregunta presenta opciones seleccionables.
  bool get isMultipleChoice {
    return type == StudentQuestionType.multipleChoice;
  }

  /// Indica si la pregunta relaciona elementos de dos columnas.
  bool get isMatching => type == StudentQuestionType.matching;

  bool get isProgramming {
    return type == StudentQuestionType.programming;
  }

  /// Duración aproximada expresada en minutos.
  ///
  /// Se redondea hacia arriba para no mostrar cero minutos cuando el tiempo
  /// asignado sea menor de sesenta segundos.
  int get timeMinutes {
    if (timeSeconds <= 0) {
      return 0;
    }

    return (timeSeconds / 60).ceil();
  }
}
