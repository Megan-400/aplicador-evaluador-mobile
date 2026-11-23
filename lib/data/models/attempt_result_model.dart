import '../../domain/entities/attempt_result.dart';

/// Resultado de intento tal como lo entrega la API.
class AttemptResultModel extends AttemptResult {
  const AttemptResultModel({
    required super.attemptId,
    required super.studentId,
    required super.studentName,
    required super.status,
    required super.gradedQuestions,
    required super.totalQuestions,
    required super.grade,
    required super.isComplete,
  });

  factory AttemptResultModel.fromJson(Map<String, dynamic> json) {
    final completo = json['completo'];

    return AttemptResultModel(
      attemptId: (json['intento_id'] as num).toInt(),
      studentId: (json['alumno_id'] as num).toInt(),
      studentName: (json['nombre'] as String?) ?? '',
      status: (json['estado'] as String?) ?? '',
      gradedQuestions: (json['calificadas'] as num).toInt(),
      totalQuestions: (json['total_preguntas'] as num).toInt(),
      grade: (json['calificacion'] as num?)?.toDouble(),
      isComplete: completo == true || completo == 1,
    );
  }
}