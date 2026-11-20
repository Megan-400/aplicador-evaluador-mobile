import '../entities/student_dashboard.dart';
import '../repositories/student_dashboard_repository.dart';

class LoadStudentDashboard {
  const LoadStudentDashboard({required this.repository});

  final StudentDashboardRepository repository;

  Future<StudentDashboard> call({
    required String folio,
    required String accessCode,
  }) {
    return repository.load(
      folio: folio.trim().toUpperCase(),
      accessCode: accessCode.trim().toUpperCase(),
    );
  }
}
