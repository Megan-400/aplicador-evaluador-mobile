import '../../domain/entities/exam.dart';
import '../../domain/repositories/exams_repository.dart';
import '../datasources/remote/exams_remote_datasource.dart';

class ExamsRepositoryImpl implements ExamsRepository {
  ExamsRepositoryImpl({ExamsRemoteDataSource? remote})
    : _remote = remote ?? ExamsRemoteDataSource();

  final ExamsRemoteDataSource _remote;

  @override
  Future<List<Exam>> getExams({int? groupId}) {
    return _remote.fetchExams(groupId: groupId);
  }
}