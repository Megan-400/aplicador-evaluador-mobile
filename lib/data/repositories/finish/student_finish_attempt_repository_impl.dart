import '../../../domain/entities/finish/student_finished_attempt.dart';
import '../../../domain/repositories/finish/student_finish_attempt_repository.dart';
import '../../datasources/remote/finish/student_finish_attempt_remote_data_source.dart';

class StudentFinishAttemptRepositoryImpl
    implements StudentFinishAttemptRepository {
  const StudentFinishAttemptRepositoryImpl({required this.remoteDataSource});

  final StudentFinishAttemptRemoteDataSource remoteDataSource;

  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) {
    return remoteDataSource.finish(sessionToken: sessionToken);
  }
}
