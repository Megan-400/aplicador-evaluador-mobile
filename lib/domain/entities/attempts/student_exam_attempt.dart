/// Intento creado por el backend para resolver un examen.
class StudentExamAttempt {
  const StudentExamAttempt({
    required this.id,
    required this.sessionToken,
    required this.startedAt,
  });

  final int id;

  /// Credencial asociada exclusivamente al intento.
  /// No debe imprimirse, mostrarse en la interfaz ni enviarse a analíticas.
  final String sessionToken;

  /// Fecha de inicio oficial proporcionada por el servidor.
  final DateTime startedAt;
}
