import '../../entities/answers/student_saved_answer.dart';
import '../../repositories/answers/student_answer_repository.dart';

/// Valida y registra una respuesta en el intento activo.
class SaveStudentAnswer {
  const SaveStudentAnswer({required this.repository});

  static const int maximumAnswerLength = 20000;

  final StudentAnswerRepository repository;

  Future<StudentSavedAnswer> call({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) {
    final normalizedToken = sessionToken.trim();

    if (normalizedToken.isEmpty) {
      throw const FormatException('La sesión del intento no está disponible.');
    }

    if (questionId <= 0) {
      throw const FormatException('La pregunta seleccionada no es válida.');
    }

    if (answer.trim().isEmpty) {
      throw const FormatException('La respuesta está vacía.');
    }

    if (answer.length > maximumAnswerLength) {
      throw const FormatException(
        'La respuesta supera el límite de 20,000 caracteres.',
      );
    }

    return repository.save(
      sessionToken: normalizedToken,
      questionId: questionId,
      answer: answer,
    );
  }
}
