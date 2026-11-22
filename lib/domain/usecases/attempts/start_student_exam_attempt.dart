import '../../entities/attempts/student_exam_attempt.dart';
import '../../repositories/attempts/student_exam_attempt_repository.dart';

class StartStudentExamAttempt {
  const StartStudentExamAttempt({required this.repository});

  final StudentExamAttemptRepository repository;

  Future<StudentExamAttempt> call({
    required String folio,
    required String accessCode,
    required int examId,
  }) {
    final normalizedFolio = folio.trim().toUpperCase();
    final normalizedAccessCode = accessCode.trim().toUpperCase();

    if (normalizedFolio.isEmpty) {
      throw const FormatException('El folio del grupo no está disponible.');
    }

    if (normalizedAccessCode.isEmpty) {
      throw const FormatException('El código personal no está disponible.');
    }

    if (examId <= 0) {
      throw const FormatException('El examen seleccionado no es válido.');
    }

    return repository.start(
      folio: normalizedFolio,
      accessCode: normalizedAccessCode,
      examId: examId,
    );
  }
}
