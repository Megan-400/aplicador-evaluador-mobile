import '../entities/group.dart';
import '../entities/student.dart';

/// Contrato de consulta de grupos del docente.
abstract interface class GroupsRepository {
  Future<List<Group>> getGroups();

  Future<List<Student>> getStudents(int groupId);
}