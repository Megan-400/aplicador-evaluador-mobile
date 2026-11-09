/// Estado visible de un grupo asociado al alumno.
enum StudentGroupStatus { active, completed }

/// Información resumida de un grupo asociado al alumno.
class StudentGroupSummary {
  const StudentGroupSummary({
    required this.id,
    required this.name,
    required this.subject,
    required this.period,
    required this.status,
    this.teacherName,
  });

  final String id;
  final String name;
  final String subject;
  final String period;
  final StudentGroupStatus status;
  final String? teacherName;
}
