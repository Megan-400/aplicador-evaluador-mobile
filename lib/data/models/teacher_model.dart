import '../../domain/entities/teacher.dart';

/// Docente tal como lo entrega la API (`nombre`, `correo`).
class TeacherModel extends Teacher {
  const TeacherModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String,
      name: (json['nombre'] as String?) ?? '',
      email: (json['correo'] as String?) ?? '',
    );
  }

  factory TeacherModel.fromEntity(Teacher teacher) {
    return TeacherModel(
      id: teacher.id,
      name: teacher.name,
      email: teacher.email,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': name, 'correo': email};
  }
}