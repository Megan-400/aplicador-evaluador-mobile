import '../../entities/finish/student_finished_attempt.dart';
import '../../repositories/finish/student_finish_attempt_repository.dart';

/// Valida la sesión y solicita la entrega definitiva del examen.
class FinishStudentExamAttempt {
  const FinishStudentExamAttempt({required this.repository});

  final StudentFinishAttemptRepository repository;

  Future<StudentFinishedAttempt> call({required String sessionToken}) {
    final normalizedToken = sessionToken.trim();

    if (normalizedToken.isEmpty) {
      throw const FormatException('La sesión del intento no está disponible.');
    }

    return repository.finish(sessionToken: normalizedToken);
  }
}
