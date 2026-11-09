/// Convierte una fecha de la API (texto) en hora local, o `null` si no es válida.
DateTime? parseApiDate(Object? valor) {
  if (valor is! String) {
    return null;
  }

  return DateTime.tryParse(valor)?.toLocal();
}

/// Formato DD/MM/AAAA.
String formatDate(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');

  return '$dia/$mes/${fecha.year}';
}

/// Formato DD/MM/AAAA HH:MM.
String formatDateTime(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');

  return '${formatDate(fecha)} $hora:$minuto';
}