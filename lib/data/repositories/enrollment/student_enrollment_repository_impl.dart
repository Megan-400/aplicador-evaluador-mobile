import '../../../domain/entities/enrollment/student_enrollment.dart';
import '../../../domain/repositories/enrollment/student_enrollment_repository.dart';
import '../../datasources/remote/enrollment/student_enrollment_remote_data_source.dart';

class StudentEnrollmentRepositoryImpl implements StudentEnrollmentRepository {
  const StudentEnrollmentRepositoryImpl({required this.remoteDataSource});

  final StudentEnrollmentRemoteDataSource remoteDataSource;

  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) {
    return remoteDataSource.create(
      groupFolio: groupFolio,
      studentName: studentName,
    );
  }
}
