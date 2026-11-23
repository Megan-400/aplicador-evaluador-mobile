import 'package:aplicador_evaluador_mobile/domain/entities/student_dashboard.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_exam_summary.dart';

/// Dashboard vacío utilizado exclusivamente en pruebas.
const emptyStudentDashboard = StudentDashboard(
  student: StudentProfile(id: 1, name: 'Alumno de prueba', selectedGroupId: 1),
  groups: [],
  exams: [],
  grades: [],
);

/// Dashboard sintético con un examen disponible.
const dashboardWithAvailableExam = StudentDashboard(
  student: StudentProfile(id: 1, name: 'Alumno de prueba', selectedGroupId: 1),
  groups: [],
  exams: [
    StudentExamSummary(
      id: '25',
      title: 'Evaluación de prueba',
      subject: 'Matemáticas',
      status: StudentExamStatus.available,
      durationMinutes: 30,
      questionCount: 3,
    ),
  ],
  grades: [],
);
