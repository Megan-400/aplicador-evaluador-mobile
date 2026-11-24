import '../../../domain/entities/finish/student_finished_attempt.dart';

/// Convierte la confirmación de entrega a una entidad de dominio.
abstract final class StudentFinishedAttemptModel {
  static StudentFinishedAttempt fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is! Map) {
      throw const FormatException(
        'La respuesta no contiene la confirmación de entrega.',
      );
    }

    final dataMap = Map<String, dynamic>.from(data);

    final attemptId = _positiveInt(dataMap['intento_id']);

    final status = dataMap['estado']?.toString().trim().toLowerCase() ?? '';

    final submittedAt = DateTime.tryParse(
      dataMap['fecha_entrega']?.toString() ?? '',
    );

    if (attemptId <= 0) {
      throw const FormatException('El identificador del intento no es válido.');
    }

    if (status != 'finalizado') {
      throw const FormatException(
        'El intento no fue confirmado como finalizado.',
      );
    }

    if (submittedAt == null) {
      throw const FormatException('La fecha de entrega no es válida.');
    }

    return StudentFinishedAttempt(
      id: attemptId,
      status: status,
      submittedAt: submittedAt,
    );
  }

  static int _positiveInt(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
