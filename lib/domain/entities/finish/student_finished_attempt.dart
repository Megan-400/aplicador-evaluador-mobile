/// Confirmación de un intento finalizado por el backend.
class StudentFinishedAttempt {
  const StudentFinishedAttempt({
    required this.id,
    required this.status,
    required this.submittedAt,
  });

  /// Identificador del intento entregado.
  final int id;

  /// Estado confirmado por el backend.
  /// Para una entrega exitosa debe ser `finalizado`.
  final String status;

  /// Fecha de entrega determinada por el servidor.
  final DateTime submittedAt;

  bool get isFinished => status == 'finalizado';
}
