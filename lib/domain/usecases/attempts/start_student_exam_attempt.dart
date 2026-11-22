import '../../entities/attempts/student_exam_attempt.dart';
import '../../repositories/attempts/student_exam_attempt_repository.dart';

class StartStudentExamAttempt {
  const StartStudentExamAttempt({
    required this.repository,
  });

  final StudentExamAttemptRepository repository;

  Future<StudentExamAttempt> call({
    required String grant,
  }) {
    final normalizedGrant = grant.trim();

    if (normalizedGrant.isEmpty) {
      throw const FormatException(
        'La autorización del examen está vacía.',
      );
    }

    if (normalizedGrant.length > 4096) {
      throw const FormatException(
        'La autorización del examen no es válida.',
      );
    }

    return repository.start(
      grant: normalizedGrant,
    );
  }
}