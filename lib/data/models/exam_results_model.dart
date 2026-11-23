import '../../domain/entities/exam_results.dart';
import 'attempt_result_model.dart';

/// Resultados de un examen tal como los entrega la API.
class ExamResultsModel extends ExamResults {
  const ExamResultsModel({
    required super.examId,
    required super.examName,
    required super.scale,
    required super.attempts,
  });

  factory ExamResultsModel.fromJson(Map<String, dynamic> json) {
    final examen = json['examen'] as Map<String, dynamic>;
    final resultados = json['resultados'] as List<dynamic>;

    return ExamResultsModel(
      examId: (examen['id'] as num).toInt(),
      examName: (examen['nombre'] as String?) ?? '',
      scale: (examen['escala'] as String?) ?? '',
      attempts: resultados
          .map(
            (item) =>
                AttemptResultModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}