import '../entities/student_dashboard.dart';

abstract interface class StudentDashboardRepository {
  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  });
}
