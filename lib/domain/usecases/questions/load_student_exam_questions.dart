import '../../entities/questions/student_exam_questions.dart';
import '../../repositories/questions/student_exam_questions_repository.dart';

/// Consulta las preguntas y respuestas guardadas de un intento.
class LoadStudentExamQuestions {
  const LoadStudentExamQuestions({required this.repository});

  final StudentExamQuestionsRepository repository;

  Future<StudentExamQuestions> call({required String sessionToken}) {
    final normalizedToken = sessionToken.trim();

    if (normalizedToken.isEmpty) {
      throw const FormatException('La sesión del intento no está disponible.');
    }

    return repository.load(sessionToken: normalizedToken);
  }
}
