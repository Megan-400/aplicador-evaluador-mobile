import 'student_exam_summary.dart';
import 'student_grade_summary.dart';
import 'student_group_summary.dart';

/// Información del alumno que inició la sesión local.
class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.selectedGroupId,
  });

  final int id;
  final String name;
  final int selectedGroupId;
}

/// Contenido completo del panel móvil del alumno.
class StudentDashboard {
  const StudentDashboard({
    required this.student,
    required this.groups,
    required this.exams,
    required this.grades,
  });

  final StudentProfile student;
  final List<StudentGroupSummary> groups;
  final List<StudentExamSummary> exams;
  final List<StudentGradeSummary> grades;
}
