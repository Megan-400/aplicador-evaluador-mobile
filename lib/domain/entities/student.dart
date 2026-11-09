/// Alumno inscrito en un grupo.
class Student {
  const Student({required this.id, required this.name, required this.joinedAt});

  final int id;
  final String name;
  final DateTime? joinedAt;
}