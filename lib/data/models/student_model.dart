import '../../core/utils/date_format.dart';
import '../../domain/entities/student.dart';

/// Alumno tal como lo entrega la API (`nombre`, `fecha_union`).
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.joinedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: (json['id'] as num).toInt(),
      name: (json['nombre'] as String?) ?? '',
      joinedAt: parseApiDate(json['fecha_union']),
    );
  }
}