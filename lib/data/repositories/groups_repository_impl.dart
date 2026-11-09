import '../../domain/entities/group.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/remote/groups_remote_datasource.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  GroupsRepositoryImpl({GroupsRemoteDataSource? remote})
    : _remote = remote ?? GroupsRemoteDataSource();

  final GroupsRemoteDataSource _remote;

  @override
  Future<List<Group>> getGroups() => _remote.fetchGroups();

  @override
  Future<List<Student>> getStudents(int groupId) {
    return _remote.fetchStudents(groupId);
  }
}