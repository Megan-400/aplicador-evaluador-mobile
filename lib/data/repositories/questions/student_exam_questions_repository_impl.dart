import '../../../domain/entities/questions/student_exam_questions.dart';
import '../../../domain/repositories/questions/student_exam_questions_repository.dart';
import '../../datasources/remote/questions/student_exam_questions_remote_data_source.dart';

class StudentExamQuestionsRepositoryImpl
    implements StudentExamQuestionsRepository {
  const StudentExamQuestionsRepositoryImpl({required this.remoteDataSource});

  final StudentExamQuestionsRemoteDataSource remoteDataSource;

  @override
  Future<StudentExamQuestions> load({required String sessionToken}) {
    return remoteDataSource.load(sessionToken: sessionToken);
  }
}
