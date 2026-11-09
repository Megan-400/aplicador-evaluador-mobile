import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/dio_error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../models/group_model.dart';
import '../../models/student_model.dart';

/// Llamadas HTTP de los grupos del docente.
class GroupsRemoteDataSource {
  Future<List<GroupModel>> fetchGroups() async {
    try {
      final respuesta = await ApiClient.dio.get(ApiConstants.grupos);
      final cuerpo = respuesta.data as Map<String, dynamic>;
      final datos = cuerpo['data'] as List<dynamic>;

      return datos
          .map((item) => GroupModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    } on TypeError {
      throw const AppException('La respuesta del servidor no es válida.');
    }
  }

  Future<List<StudentModel>> fetchStudents(int groupId) async {
    try {
      final respuesta = await ApiClient.dio.get(
        ApiConstants.alumnosDeGrupo(groupId),
      );
      final cuerpo = respuesta.data as Map<String, dynamic>;
      final datos = cuerpo['data'] as List<dynamic>;

      return datos
          .map((item) => StudentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    } on TypeError {
      throw const AppException('La respuesta del servidor no es válida.');
    }
  }
}