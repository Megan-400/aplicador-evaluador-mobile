import 'exam.dart';

/// Resumen de la actividad del docente para la pantalla de inicio.
class TeacherSummary {
  const TeacherSummary({
    required this.totalGroups,
    required this.activeGroups,
    required this.draftExams,
    required this.publishedExams,
    required this.closedExams,
    required this.awaitingGrading,
    required this.nextClosingExam,
    required this.nextClosingSubject,
  });

  final int totalGroups;
  final int activeGroups;
  final int draftExams;
  final int publishedExams;
  final int closedExams;

  /// Intentos finalizados sin calificación definitiva; `null` si no se pudo
  /// consultar.
  final int? awaitingGrading;

  /// Examen publicado que cierra primero, y la materia de su grupo.
  final Exam? nextClosingExam;
  final String? nextClosingSubject;
}