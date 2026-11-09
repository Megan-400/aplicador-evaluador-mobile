/// Estado visible de un examen asignado al alumno.
enum StudentExamStatus { available, upcoming, completed, closed }

/// Información resumida necesaria para mostrar un examen en una lista.
class StudentExamSummary {
  const StudentExamSummary({
    required this.id,
    required this.title,
    required this.subject,
    required this.status,
    required this.durationMinutes,
    required this.questionCount,
    this.availableAt,
    this.dueAt,
  });

  final String id;
  final String title;
  final String subject;
  final StudentExamStatus status;
  final int durationMinutes;
  final int questionCount;
  final DateTime? availableAt;
  final DateTime? dueAt;
}
