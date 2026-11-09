import '../entities/exam.dart';

/// Contrato de consulta de exámenes del docente.
abstract interface class ExamsRepository {
  Future<List<Exam>> getExams({int? groupId});
}
