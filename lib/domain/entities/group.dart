/// Grupo (materia) de un docente.
class Group {
  const Group({
    required this.id,
    required this.subject,
    required this.folio,
    required this.isActive,
  });

  final int id;
  final String subject;
  final String folio;
  final bool isActive;
}