import '../../core/utils/date_format.dart';
import '../../domain/entities/exam.dart';

/// Examen tal como lo entrega la API.
class ExamModel extends Exam {
  const ExamModel({
    required super.id,
    required super.groupId,
    required super.name,
    required super.opensAt,
    required super.closesAt,
    required super.order,
    required super.scale,
    required super.platform,
    required super.isPublished,
    required super.resultVisibility,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    final publicado = json['publicado'];

    return ExamModel(
      id: (json['id'] as num).toInt(),
      groupId: (json['grupo_id'] as num).toInt(),
      name: (json['nombre'] as String?) ?? '',
      opensAt: parseApiDate(json['fecha_apertura']),
      closesAt: parseApiDate(json['fecha_cierre']),
      order: (json['orden'] as String?) ?? '',
      scale: (json['escala'] as String?) ?? '',
      platform: (json['plataforma_permitida'] as String?) ?? '',
      isPublished: publicado == true || publicado == 1 || publicado == 't',
      resultVisibility: (json['resultado_visible'] as String?) ?? '',
    );
  }
}