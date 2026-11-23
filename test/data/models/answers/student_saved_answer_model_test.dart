import 'package:aplicador_evaluador_mobile/data/models/answers/student_saved_answer_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentSavedAnswerModel', () {
    test('convierte una confirmación válida', () {
      final answer = StudentSavedAnswerModel.fromJson({
        'data': {'respuesta_id': 123},
      }, questionId: 25);

      expect(answer.id, 123);
      expect(answer.questionId, 25);
    });

    test('acepta respuesta_id representado como texto', () {
      final answer = StudentSavedAnswerModel.fromJson({
        'data': {'respuesta_id': '123'},
      }, questionId: 25);

      expect(answer.id, 123);
    });

    test('rechaza una respuesta sin data', () {
      expect(
        () => StudentSavedAnswerModel.fromJson({}, questionId: 25),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza respuesta_id inválido', () {
      expect(
        () => StudentSavedAnswerModel.fromJson({
          'data': {'respuesta_id': 0},
        }, questionId: 25),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza questionId inválido', () {
      expect(
        () => StudentSavedAnswerModel.fromJson({
          'data': {'respuesta_id': 123},
        }, questionId: 0),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
