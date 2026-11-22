/// Intento creado o reanudado por el backend.
class StudentExamAttempt {
  const StudentExamAttempt({
    required this.id,
    required this.examId,
    required this.sessionToken,
    required this.startedAt,
    required this.wasResumed,
  });

  final int id;
  final int examId;

  /// Credencial exclusiva del intento.
  /// No debe mostrarse, registrarse ni enviarse a analíticas.
  final String sessionToken;

  final DateTime startedAt;
  final bool wasResumed;
}
