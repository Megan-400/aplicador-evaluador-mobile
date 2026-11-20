import 'package:aplicador_evaluador_mobile/domain/entities/student_dashboard.dart';

/// Dashboard vacío utilizado exclusivamente en pruebas automatizadas.
const emptyStudentDashboard = StudentDashboard(
  student: StudentProfile(id: 1, name: 'Alumno de prueba', selectedGroupId: 1),
  groups: [],
  exams: [],
  grades: [],
);
