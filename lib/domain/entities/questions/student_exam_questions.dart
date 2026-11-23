import 'student_exam_question.dart';

/// Contenido recuperado para un intento activo.
class StudentExamQuestions {
  const StudentExamQuestions({
    required this.examName,
    required this.questions,
    required this.savedAnswers,
  });

  final String examName;
  final List<StudentExamQuestion> questions;

  /// Respuestas guardadas, indexadas por `examen_pregunta_id`.
  final Map<int, String> savedAnswers;
}
