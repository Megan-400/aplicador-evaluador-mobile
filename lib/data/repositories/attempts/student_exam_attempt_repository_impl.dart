import '../../../domain/entities/attempts/student_exam_attempt.dart';
import '../../../domain/repositories/attempts/student_exam_attempt_repository.dart';
import '../../datasources/remote/attempts/student_exam_attempt_remote_data_source.dart';

class StudentExamAttemptRepositoryImpl implements StudentExamAttemptRepository {
  const StudentExamAttemptRepositoryImpl({required this.remoteDataSource});

  final StudentExamAttemptRemoteDataSource remoteDataSource;

  @override
  Future<StudentExamAttempt> start({
    required String folio,
    required String accessCode,
    required int examId,
  }) {
    return remoteDataSource.start(
      folio: folio,
      accessCode: accessCode,
      examId: examId,
    );
  }
}
