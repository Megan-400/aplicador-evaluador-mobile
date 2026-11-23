/// Opción seleccionable identificada mediante una clave estable.
class StudentQuestionOption {
  const StudentQuestionOption({required this.value, required this.label});

  /// Valor enviado al backend, por ejemplo `A` o `B`.
  final String value;

  /// Texto presentado al alumno.
  final String label;
}
