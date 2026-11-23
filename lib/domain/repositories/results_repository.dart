import '../entities/exam_results.dart';

/// Contrato de consulta de resultados de exámenes.
abstract interface class ResultsRepository {
  Future<ExamResults> getExamResults(int examId);
}