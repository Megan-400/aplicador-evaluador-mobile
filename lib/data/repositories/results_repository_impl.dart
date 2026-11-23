import '../../domain/entities/exam_results.dart';
import '../../domain/repositories/results_repository.dart';
import '../datasources/remote/results_remote_datasource.dart';

class ResultsRepositoryImpl implements ResultsRepository {
  ResultsRepositoryImpl({ResultsRemoteDataSource? remote})
    : _remote = remote ?? ResultsRemoteDataSource();

  final ResultsRemoteDataSource _remote;

  @override
  Future<ExamResults> getExamResults(int examId) {
    return _remote.fetchExamResults(examId);
  }
}