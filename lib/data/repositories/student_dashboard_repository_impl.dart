import '../../domain/entities/student_dashboard.dart';
import '../../domain/repositories/student_dashboard_repository.dart';
import '../datasources/remote/student_dashboard_remote_data_source.dart';

class StudentDashboardRepositoryImpl implements StudentDashboardRepository {
  const StudentDashboardRepositoryImpl({required this.remoteDataSource});

  final StudentDashboardRemoteDataSource remoteDataSource;

  @override
  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  }) {
    return remoteDataSource.load(folio: folio, accessCode: accessCode);
  }
}
