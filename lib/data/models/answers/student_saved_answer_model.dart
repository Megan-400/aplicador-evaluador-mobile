import '../../../domain/entities/answers/student_saved_answer.dart';

/// Convierte la confirmación del backend a una entidad de dominio.
abstract final class StudentSavedAnswerModel {
  static StudentSavedAnswer fromJson(
    Map<String, dynamic> json, {
    required int questionId,
  }) {
    final data = json['data'];

    if (data is! Map) {
      throw const FormatException(
        'La respuesta no contiene la confirmación del guardado.',
      );
    }

    final dataMap = Map<String, dynamic>.from(data);

    final answerId = _parsePositiveInt(dataMap['respuesta_id']);

    if (answerId <= 0) {
      throw const FormatException(
        'El identificador de la respuesta no es válido.',
      );
    }

    if (questionId <= 0) {
      throw const FormatException(
        'El identificador de la pregunta no es válido.',
      );
    }

    return StudentSavedAnswer(id: answerId, questionId: questionId);
  }

  static int _parsePositiveInt(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
