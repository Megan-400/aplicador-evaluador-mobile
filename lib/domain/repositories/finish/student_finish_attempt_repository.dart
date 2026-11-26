import '../../entities/finish/student_finished_attempt.dart';

/// Contrato para finalizar un intento activo.
abstract interface class StudentFinishAttemptRepository {
  Future<StudentFinishedAttempt> finish({required String sessionToken});
}
