import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/dio_error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../models/exam_results_model.dart';

/// Llamadas HTTP de los resultados de exámenes.
class ResultsRemoteDataSource {
  Future<ExamResultsModel> fetchExamResults(int examId) async {
    try {
      final respuesta = await ApiClient.dio.get(
        ApiConstants.resultadosDeExamen(examId),
      );
      final cuerpo = respuesta.data as Map<String, dynamic>;

      return ExamResultsModel.fromJson(cuerpo['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    } on TypeError {
      throw const AppException('La respuesta del servidor no es válida.');
    }
  }
}