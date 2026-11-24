import '../../../domain/entities/answers/student_saved_answer.dart';
import '../../../domain/repositories/answers/student_answer_repository.dart';
import '../../datasources/remote/answers/student_answer_remote_data_source.dart';

class StudentAnswerRepositoryImpl implements StudentAnswerRepository {
  const StudentAnswerRepositoryImpl({required this.remoteDataSource});

  final StudentAnswerRemoteDataSource remoteDataSource;

  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) {
    return remoteDataSource.save(
      sessionToken: sessionToken,
      questionId: questionId,
      answer: answer,
    );
  }
}
