/// Resultado de un intento de examen presentado por un alumno.
///
/// `grade` es `null` mientras el intento no esté completo: el servidor no
/// publica notas parciales como definitivas.
class AttemptResult {
  const AttemptResult({
    required this.attemptId,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.gradedQuestions,
    required this.totalQuestions,
    required this.grade,
    required this.isComplete,
  });

  final int attemptId;
  final int studentId;
  final String studentName;
  final String status;
  final int gradedQuestions;
  final int totalQuestions;
  final double? grade;
  final bool isComplete;
}