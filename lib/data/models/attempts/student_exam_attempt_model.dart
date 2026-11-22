import '../../../domain/entities/attempts/student_exam_attempt.dart';

/// Convierte la respuesta de inicio o reanudación del intento.
abstract final class StudentExamAttemptModel {
  static StudentExamAttempt fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'La respuesta no contiene los datos del intento.',
      );
    }

    final attemptId = _parseId(data['intento_id']);
    final examId = _parseId(data['examen_id']);
    final sessionToken = data['token_sesion']?.toString().trim() ?? '';
    final startedAt = DateTime.tryParse(data['fecha_inicio']?.toString() ?? '');
    final wasResumed = data['reanudado'];

    if (attemptId <= 0) {
      throw const FormatException('El identificador del intento no es válido.');
    }

    if (examId <= 0) {
      throw const FormatException('El identificador del examen no es válido.');
    }

    if (sessionToken.isEmpty) {
      throw const FormatException('El intento no contiene token de sesión.');
    }

    if (startedAt == null) {
      throw const FormatException('La fecha de inicio no es válida.');
    }

    if (wasResumed is! bool) {
      throw const FormatException('El estado de reanudación no es válido.');
    }

    return StudentExamAttempt(
      id: attemptId,
      examId: examId,
      sessionToken: sessionToken,
      startedAt: startedAt,
      wasResumed: wasResumed,
    );
  }

  static int _parseId(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
