/// Confirmación de una respuesta registrada por el backend.
class StudentSavedAnswer {
  const StudentSavedAnswer({required this.id, required this.questionId});

  /// Identificador de la respuesta asignado por el backend.
  final int id;

  /// Pregunta a la que pertenece la respuesta.
  final int questionId;
}
