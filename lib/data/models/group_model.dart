import '../../domain/entities/group.dart';

/// Grupo tal como lo entrega la API (`materia`, `folio_codigo`, `activo`).
class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.subject,
    required super.folio,
    required super.isActive,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final activo = json['activo'];

    return GroupModel(
      id: (json['id'] as num).toInt(),
      subject: json['materia'] as String,
      folio: json['folio_codigo'] as String,
      isActive: activo == true || activo == 1,
    );
  }
}