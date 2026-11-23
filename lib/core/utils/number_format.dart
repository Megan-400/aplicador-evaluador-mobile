/// Muestra una calificación con hasta dos decimales y sin ceros sobrantes
/// (85.00 se muestra como 85 y 8.50 como 8.5).
String formatGrade(double valor) {
  final texto = valor.toStringAsFixed(2);

  return texto.replaceFirst(RegExp(r'\.?0+$'), '');
}