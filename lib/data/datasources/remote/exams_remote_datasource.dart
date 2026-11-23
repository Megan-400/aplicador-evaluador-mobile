import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/dio_error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../models/exam_model.dart';

/// Llamadas HTTP de los exámenes del docente.
class ExamsRemoteDataSource {
  Future<List<ExamModel>> fetchExams({int? groupId}) async {
    try {
      final respuesta = await ApiClient.dio.get(
        ApiConstants.examenes,
        queryParameters: {'grupo_id': ?groupId},
      );
      final cuerpo = respuesta.data as Map<String, dynamic>;
      final datos = cuerpo['data'] as List<dynamic>;

      return datos
          .map((item) => ExamModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    } on TypeError {
      throw const AppException('La respuesta del servidor no es válida.');
    }
  }
}