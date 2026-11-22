import '../../../domain/entities/attempts/student_exam_attempt.dart';

/// Convierte la respuesta de inicio en una entidad de dominio.
abstract final class StudentExamAttemptModel {
  static StudentExamAttempt fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'La respuesta no contiene los datos del intento.',
      );
    }

    final id = _parseId(data['intento_id']);
    final sessionToken =
        data['token_sesion']?.toString().trim() ?? '';
    final startedAt = DateTime.tryParse(
      data['fecha_inicio']?.toString() ?? '',
    );

    if (id <= 0) {
      throw const FormatException(
        'El identificador del intento no es válido.',
      );
    }

    if (sessionToken.isEmpty) {
      throw const FormatException(
        'El intento no contiene token de sesión.',
      );
    }

    if (startedAt == null) {
      throw const FormatException(
        'La fecha de inicio no es válida.',
      );
    }

    return StudentExamAttempt(
      id: id,
      sessionToken: sessionToken,
      startedAt: startedAt,
    );
  }

  static int _parseId(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}