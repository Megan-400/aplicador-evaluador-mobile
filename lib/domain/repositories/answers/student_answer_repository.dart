import '../../entities/answers/student_saved_answer.dart';

/// Contrato para guardar respuestas de un intento activo.
abstract interface class StudentAnswerRepository {
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  });
}
