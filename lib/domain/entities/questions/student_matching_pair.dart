/// Par de elementos utilizado por una pregunta de relación de columnas.
class StudentMatchingPair {
  const StudentMatchingPair({required this.left, required this.right});

  /// Elemento presentado en la columna izquierda.
  final String left;

  /// Elemento disponible en la columna derecha.
  final String right;
}
